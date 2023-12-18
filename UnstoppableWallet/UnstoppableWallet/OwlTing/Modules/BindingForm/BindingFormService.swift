import UIKit
import LanguageKit

enum AmlValidateStatus: String {
    case rejected
    case unfinished
    case unverified
    case verified
    case userNotFound
    
    func title() -> String {
        switch self {
        case .verified: return "aml_validate_status.verified".localized
        case .unverified: return "aml_validate_status.unverified".localized
        case .unfinished: return "aml_validate_status.unfinished".localized
        case .rejected: return "aml_validate_status.rejected".localized
        case .userNotFound: return "aml_validate_status.user_not_found".localized // 判斷 aml meta api code 10032 代表無此使用者
        }
    }
    
    func color() -> UIColor {
        switch self {
        case .verified: return .themeGreenD
        case .unverified: return .themeRedD
        case .unfinished: return .themeRedD
        case .rejected: return .themeRedD
        case .userNotFound: return .themeRedD
        }
    }
    
    func bindWording() -> String {
        switch self {
        case .verified, .unfinished: return "binding_wording.verified".localized
        case .unverified, .rejected, .userNotFound: return "binding_wording.default".localized
        }
    }
    
    func statusCode() -> Int {
        switch self {
        case .verified: return 3
        case .unverified: return 2
        case .unfinished: return 0
        case .rejected: return -1
        case .userNotFound: return 10032 // 判斷 aml meta api code 10032 代表無此使用者
        }
    }
    
    static func fetchRaw(_ theEnum: AmlValidateStatus) -> String {
        return theEnum.rawValue
    }
}



class BindingFormService {
    
    private let walletManager: WalletManager
    private let accountManager: AccountManager
    let networkService: NetworkService
    
    private(set) var activeItems: [Item] = []
    var activeSsoUserChain: [SSOUserChain] = []
    var unbindUserChains: [UserChain] = []
    
    init(walletManager: WalletManager, networkService: NetworkService, accountManager: AccountManager) {
        self.walletManager = walletManager
        self.networkService = networkService
        self.accountManager = accountManager
        
        _sync(wallets: walletManager.activeWallets)
    }

    deinit {
//        Dprint("\(type(of: self)) \(#function)")
    }
    
    var activeWallets: [Wallet] {
        walletManager.activeWallets
    }
    
    var customer: Customer? {
        accountManager.customer
    }
    
    var amlUserMeta: AmlUserMeta? {
        accountManager.amlUserMeta
    }
    
    var amlValidateStatus: AmlValidateStatus {
        accountManager.amlValidateStatus
    }
    
    private func _sync(wallets: [Wallet]) {
        
        let items: [Item] = wallets.map { wallet in
            let item = Item(wallet: wallet)
            return item
        }
        activeItems = items
        
        // 此錢包所有法幣 chain
        activeSsoUserChain = walletManager.activeWallets.compactMap { wallet in
            generateChain(wallet: wallet)
        }
        
        // 已在 aml 審核過的 chain
        unbindUserChains = (amlUserMeta?.ssoUserChains ?? []).compactMap { chain in
            generateUnbindUserChain(ssoUserChain: chain)
        }
    }
}

extension BindingFormService {

    struct Item {
        let wallet: Wallet
        var isSelected: Bool = false

        init(wallet: Wallet) {
            self.wallet = wallet
        }
    }

}

extension BindingFormService {
    
    private func generateChain(wallet: Wallet) -> SSOUserChain? {
        
        guard let adapter = App.shared.adapterManager.depositAdapter(for: wallet) else { return nil }
        var chain = SSOUserChain()
        chain.chainAddress = adapter.receiveAddress.address
        chain.chainAsset = wallet.token.coin.code
        chain.chainNetwork = wallet.token.blockchain.name
        return chain
    }
    
    private func getChainStatus(chain: SSOUserChain) -> ChainStatus {
        guard activeSsoUserChain.contains(chain) else {
            return .notInThisWallet
        }
        return chain.chainIsBinding == true ? .binding : .unBinding
    }
    
    func generateUnbindUserChain(ssoUserChain: SSOUserChain) -> UserChain? {
        
        guard getChainStatus(chain: ssoUserChain) == .binding else {
            return nil
        }
        
        var chain = UserChain()
        chain.address = ssoUserChain.chainAddress
        chain.asset = ssoUserChain.chainAsset
        chain.network = ssoUserChain.chainNetwork
        chain.isBinding = false
        
        return chain
    }
}

extension BindingFormService {

    var langCode: String {
        LanguageManager.shared.currentLanguage.langCode
    }
}
