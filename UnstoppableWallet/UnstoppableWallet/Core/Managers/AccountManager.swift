import Combine
import RxRelay
import RxSwift
import ObjectMapper
import Foundation

class AccountManager {
    private let passcodeManager: PasscodeManager
    private let storage: AccountCachedStorage
    private var cancellables = Set<AnyCancellable>()

    private let activeAccountRelay = PublishRelay<Account?>()
    private let accountsRelay = PublishRelay<[Account]>()
    private let accountUpdatedRelay = PublishRelay<Account>()
    private let accountDeletedRelay = PublishRelay<Account>()
    private let accountsLostRelay = BehaviorRelay<Bool>(value: false)

    private var lastCreatedAccount: Account?

    private static let currentLoginStateKey = "current_login_state"
    private static let otWalletTokenDefaultsKey = "ot_wallet_token"
    private static let customerDefaultsKey = "ot_customer"
    private static let amlUserMetaDefaultsKey = "aml_userMeta"
    private static let amlValidateStatusDefaultsKey = "aml_validate_status"

    init(passcodeManager: PasscodeManager, accountStorage: AccountStorage, activeAccountStorage: ActiveAccountStorage) {
        self.passcodeManager = passcodeManager

        storage = AccountCachedStorage(level: passcodeManager.currentPasscodeLevel, accountStorage: accountStorage, activeAccountStorage: activeAccountStorage)
        
        currentLoginState = AccountManager.storedCurrentLoginState
        otWalletToken = AccountManager.storedOTWalletToken
        amlUserMeta = AccountManager.storedAmlUserMeta
        customer = AccountManager.storedOTCustomer
        amlValidateStatus = AccountManager.storedAmlValidateStatus

        passcodeManager.$currentPasscodeLevel
            .sink { [weak self] level in
                self?.handle(level: level)
            }
            .store(in: &cancellables)

        passcodeManager.$isDuressPasscodeSet
            .sink { [weak self] isSet in
                if !isSet {
                    self?.handleDisableDuress()
                }
            }
            .store(in: &cancellables)
    }

    private func handle(level: Int) {
        storage.set(level: level)

        accountsRelay.accept(storage.accounts)
        activeAccountRelay.accept(storage.activeAccount)
    }

    private func handleDisableDuress() {
        let currentLevel = passcodeManager.currentPasscodeLevel

        for account in storage.accounts {
            if account.level > currentLevel {
                account.level = currentLevel
                storage.save(account: account)
            }
        }

        accountsRelay.accept(storage.accounts)
    }

    private func clearAccounts(ids: [String]) {
        ids.forEach {
            storage.delete(accountId: $0)
        }

        if storage.allAccounts.isEmpty {
            accountsLostRelay.accept(true)
        }
    }

    
    public var currentLoginState: Bool {
        didSet {
            setCurrentLoginState()
        }
    }
    
    public var otWalletToken: OTWalletToken? {
        didSet {
            setOTWalletToken()
        }
    }
    
    var customer : Customer? {
        didSet {
            setOTCustomer()
        }
    }
    
    var amlUserMeta : AmlUserMeta? {
        didSet {
            setAmlUserMeta()
        }
    }
    
    var amlValidateStatus: AmlValidateStatus {
        didSet {
            setAmlValidateStatus()
        }
    }
}

extension AccountManager {
    var activeAccountObservable: Observable<Account?> {
        activeAccountRelay.asObservable()
    }

    var accountsObservable: Observable<[Account]> {
        accountsRelay.asObservable()
    }

    var accountUpdatedObservable: Observable<Account> {
        accountUpdatedRelay.asObservable()
    }

    var accountDeletedObservable: Observable<Account> {
        accountDeletedRelay.asObservable()
    }

    var accountsLostObservable: Observable<Bool> {
        accountsLostRelay.asObservable()
    }

    var currentLevel: Int {
        passcodeManager.currentPasscodeLevel
    }

    var activeAccount: Account? {
        storage.activeAccount
    }

    func set(activeAccountId: String?) {
        guard storage.activeAccount?.id != activeAccountId else {
            return
        }

        storage.set(activeAccountId: activeAccountId)
        activeAccountRelay.accept(storage.activeAccount)
    }

    var accounts: [Account] {
        storage.accounts
    }

    func account(id: String) -> Account? {
        storage.account(id: id)
    }

    func update(account: Account) {
        storage.save(account: account)

        accountsRelay.accept(storage.accounts)
        accountUpdatedRelay.accept(account)
    }

    func save(account: Account) {
        storage.save(account: account)

        accountsRelay.accept(storage.accounts)

        set(activeAccountId: account.id)
    }

    func save(accounts: [Account]) {
        accounts.forEach { account in
            storage.save(account: account)
        }

        accountsRelay.accept(storage.accounts)
        if let first = accounts.first {
            set(activeAccountId: first.id)
        }
    }

    func delete(account: Account) {
        storage.delete(account: account)

        accountsRelay.accept(storage.accounts)
        accountDeletedRelay.accept(account)

        if account == storage.activeAccount {
            set(activeAccountId: storage.accounts.first?.id)
        }
    }

    func clear() {
        storage.clear()

        accountsRelay.accept(storage.accounts)

        set(activeAccountId: nil)
    }

    func handleLaunch() {
        let lostAccountIds = storage.lostAccountIds
        guard !lostAccountIds.isEmpty else {
            return
        }

        clearAccounts(ids: lostAccountIds)
    }

    func handleForeground() {
        let oldAccounts = storage.accounts

        let lostAccountIds = storage.lostAccountIds
        guard !lostAccountIds.isEmpty else {
            return
        }

        clearAccounts(ids: lostAccountIds)

        let lostAccounts = oldAccounts.filter { account in
            lostAccountIds.contains(account.id)
        }

        lostAccounts.forEach { account in
            accountDeletedRelay.accept(account)
        }

        accountsRelay.accept(storage.accounts)
    }

    func set(lastCreatedAccount: Account) {
        self.lastCreatedAccount = lastCreatedAccount
    }

    func popLastCreatedAccount() -> Account? {
        let account = lastCreatedAccount
        lastCreatedAccount = nil
        return account
    }

    func setDuress(accountIds: [String]) {
        let currentLevel = passcodeManager.currentPasscodeLevel

        for account in storage.accounts {
            if accountIds.contains(account.id) {
                account.level = currentLevel + 1
                storage.save(account: account)
            }
        }

        accountsRelay.accept(storage.accounts)
    }
}

class AccountCachedStorage {
    private let accountStorage: AccountStorage
    private let activeAccountStorage: ActiveAccountStorage

    private var _allAccounts: [String: Account]

    private var level: Int
    private var _accounts = [String: Account]()
    private var _activeAccount: Account?

    init(level: Int, accountStorage: AccountStorage, activeAccountStorage: ActiveAccountStorage) {
        self.level = level
        self.accountStorage = accountStorage
        self.activeAccountStorage = activeAccountStorage

        _allAccounts = accountStorage.allAccounts.reduce(into: [String: Account]()) { $0[$1.id] = $1 }

        syncAccounts()
    }

    private func syncAccounts() {
        _accounts = _allAccounts.filter { _, account in account.level >= level }
        _activeAccount = activeAccountStorage.activeAccountId(level: level).flatMap { _accounts[$0] } ?? _accounts.first?.value
    }

    var allAccounts: [Account] {
        Array(_allAccounts.values)
    }

    var accounts: [Account] {
        Array(_accounts.values)
    }

    var activeAccount: Account? {
        _activeAccount
    }

    var lostAccountIds: [String] {
        accountStorage.lostAccountIds
    }

    func set(level: Int) {
        self.level = level
        syncAccounts()
    }

    func account(id: String) -> Account? {
        _allAccounts[id]
    }

    func set(activeAccountId: String?) {
        activeAccountStorage.save(activeAccountId: activeAccountId, level: level)
        _activeAccount = activeAccountId.flatMap { _accounts[$0] }
    }

    func save(account: Account) {
        accountStorage.save(account: account)
        _allAccounts[account.id] = account

        if account.level >= level {
            _accounts[account.id] = account
        } else {
            _accounts.removeValue(forKey: account.id)
        }
    }

    func delete(account: Account) {
        accountStorage.delete(account: account)
        _allAccounts.removeValue(forKey: account.id)
        _accounts.removeValue(forKey: account.id)
    }

    func delete(accountId: String) {
        accountStorage.delete(accountId: accountId)
        _allAccounts.removeValue(forKey: accountId)
        _accounts.removeValue(forKey: accountId)
    }

    func clear() {
        accountStorage.clear()
        _allAccounts = [:]
        _accounts = [:]
    }
}

extension AccountManager {
    
    private func setCurrentLoginState() {
        UserDefaults.standard.set(currentLoginState, forKey: AccountManager.currentLoginStateKey)
    }

    private func setOTWalletToken() {
        UserDefaults.standard.set(otWalletToken?.toJSONString(), forKey: AccountManager.otWalletTokenDefaultsKey)
    }
    
    private func setOTCustomer() {
        UserDefaults.standard.set(customer?.toJSONString(), forKey: AccountManager.customerDefaultsKey)
    }
    
    private func setAmlUserMeta() {
        UserDefaults.standard.set(amlUserMeta?.toJSONString(), forKey: AccountManager.amlUserMetaDefaultsKey)
    }
    
    private func setAmlValidateStatus() {
        UserDefaults.standard.set(amlValidateStatus.rawValue, forKey: AccountManager.amlValidateStatusDefaultsKey)
    }
    
    func saveAmlUserMeta(response: AmlUserMetaResponse) {
        
        amlUserMeta = response.data
        
        if response.code == AmlValidateStatus.userNotFound.statusCode() {
            amlValidateStatus = .userNotFound
        } else {
            
            let status = AmlValidateStatus(rawValue: response.data?.integratedStatus ?? "") ?? .userNotFound
            amlValidateStatus = status
        }
    }
    
    func otAccountLogout() {
        currentLoginState = false
        otWalletToken = nil
        customer = nil
        amlUserMeta = nil
        amlValidateStatus = .userNotFound
    }
}

extension AccountManager {
    
    private static var storedCurrentLoginState: Bool {
        
        guard let state = UserDefaults.standard.value(forKey: currentLoginStateKey) as? Bool else {
            return false
        }
        
        return state
    }
    
    private static var storedOTWalletToken: OTWalletToken? {
        guard let jsonString = UserDefaults.standard.value(forKey: otWalletTokenDefaultsKey) as? String else { return nil }
        return Mapper<OTWalletToken>().map(JSONString: jsonString)
    }
    
    private static var storedOTCustomer: Customer? {
        guard let jsonString = UserDefaults.standard.value(forKey: customerDefaultsKey) as? String else { return nil }
        return Mapper<Customer>().map(JSONString: jsonString)
    }
    
    private static var storedAmlUserMeta: AmlUserMeta? {
        guard let jsonString = UserDefaults.standard.value(forKey: amlUserMetaDefaultsKey) as? String else { return nil }
        return Mapper<AmlUserMeta>().map(JSONString: jsonString)
    }
    
    private static var storedAmlValidateStatus: AmlValidateStatus {
        guard let string = UserDefaults.standard.value(forKey: amlValidateStatusDefaultsKey) as? String, let status = AmlValidateStatus(rawValue: string) else { return .userNotFound }
        
        return status
    }
}
