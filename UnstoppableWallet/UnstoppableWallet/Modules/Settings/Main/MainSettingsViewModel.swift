import Combine
import RxCocoa
import RxRelay
import RxSwift
import ThemeKit
import WalletConnectV1

class MainSettingsViewModel {
    private let service: MainSettingsService
    private let disposeBag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()

    private let manageWalletsAlertRelay: BehaviorRelay<Bool>
    private let securityCenterAlertRelay: BehaviorRelay<Bool>
    private let iCloudSyncAlertRelay: BehaviorRelay<Bool>
    private let walletConnectCountRelay: BehaviorRelay<(highlighted: Bool, text: String)?>
    private let baseCurrencyRelay: BehaviorRelay<String>
    private let aboutAlertRelay: BehaviorRelay<Bool>
    private let openWalletConnectRelay = PublishRelay<WalletConnectOpenMode>()
    private let openLinkRelay = PublishRelay<String>()
    private let successRelay = PublishRelay<()>()
    private let loadingRelay = PublishRelay<(Bool)>()
    private let errorRelay = PublishRelay<()>()
    private let updateUserStatusRelay = PublishRelay<()>()
    private let authTerminateSuccessRelay = PublishRelay<()>()

    init(service: MainSettingsService) {
        self.service = service

        manageWalletsAlertRelay = BehaviorRelay(value: !service.noWalletRequiredActions)
        securityCenterAlertRelay = BehaviorRelay(value: !service.isPasscodeSet)
        iCloudSyncAlertRelay = BehaviorRelay(value: service.isCloudAvailableError)
        walletConnectCountRelay = BehaviorRelay(value: Self.convert(walletConnectSessionCount: service.walletConnectSessionCount, walletConnectPendingRequestCount: service.walletConnectPendingRequestCount))
        baseCurrencyRelay = BehaviorRelay(value: service.baseCurrency.code)
        aboutAlertRelay = BehaviorRelay(value: !service.termsAccepted)

        service.noWalletRequiredActionsObservable
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onNext: { [weak self] noWalletRequiredActions in
                self?.manageWalletsAlertRelay.accept(!noWalletRequiredActions)
            })
            .disposed(by: disposeBag)

        service.isPasscodeSetPublisher
            .sink { [weak self] isPinSet in
                self?.securityCenterAlertRelay.accept(!isPinSet)
            }
            .store(in: &cancellables)

        service.iCloudAvailableErrorObservable
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onNext: { [weak self] hasError in
                self?.iCloudSyncAlertRelay.accept(hasError)
            })
            .disposed(by: disposeBag)

        service.walletConnectSessionCountObservable
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onNext: { [weak self] count in
                self?.walletConnectCountRelay.accept(Self.convert(walletConnectSessionCount: count, walletConnectPendingRequestCount: self?.service.walletConnectPendingRequestCount ?? 0))
            })
            .disposed(by: disposeBag)

        service.walletConnectPendingRequestCountObservable
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onNext: { [weak self] count in
                self?.walletConnectCountRelay.accept(Self.convert(walletConnectSessionCount: self?.service.walletConnectSessionCount ?? 0, walletConnectPendingRequestCount: count))
            })
            .disposed(by: disposeBag)

        service.baseCurrencyPublisher
            .sink { [weak self] currency in
                self?.baseCurrencyRelay.accept(currency.code)
            }
            .store(in: &cancellables)

        service.termsAcceptedPublisher
            .sink { [weak self] accepted in
                self?.aboutAlertRelay.accept(!accepted)
            }
            .store(in: &cancellables)
    }

    private static func convert(walletConnectSessionCount: Int, walletConnectPendingRequestCount: Int) -> (highlighted: Bool, text: String)? {
        if walletConnectPendingRequestCount != 0 {
            return (highlighted: true, text: "\(walletConnectPendingRequestCount)")
        }
        return walletConnectSessionCount > 0 ? (highlighted: false, text: "\(walletConnectSessionCount)") : nil
    }
}

extension MainSettingsViewModel {
    var openWalletConnectSignal: Signal<WalletConnectOpenMode> {
        openWalletConnectRelay.asSignal()
    }

    var openLinkSignal: Signal<String> {
        openLinkRelay.asSignal()
    }

    var manageWalletsAlertDriver: Driver<Bool> {
        manageWalletsAlertRelay.asDriver()
    }

    var securityCenterAlertDriver: Driver<Bool> {
        securityCenterAlertRelay.asDriver()
    }

    var iCloudSyncAlertDriver: Driver<Bool> {
        iCloudSyncAlertRelay.asDriver()
    }

    var walletConnectCountDriver: Driver<(highlighted: Bool, text: String)?> {
        walletConnectCountRelay.asDriver()
    }

    var baseCurrencyDriver: Driver<String> {
        baseCurrencyRelay.asDriver()
    }

    var aboutAlertDriver: Driver<Bool> {
        aboutAlertRelay.asDriver()
    }

    var currentLanguage: String? {
        service.currentLanguageDisplayName
    }

    var appVersion: String {
        service.appVersion
    }

    var analyticsLink: String {
        service.analyticsLink
    }

    var isAuthenticated: Bool {
        service.isAuthenticated
    }

    func onTapWalletConnect() {
        switch service.walletConnectState {
        case .noAccount: openWalletConnectRelay.accept(.errorDialog(error: .noAccount))
        case .backedUp: openWalletConnectRelay.accept(.list)
        case let .nonSupportedAccountType(accountType): openWalletConnectRelay.accept(.errorDialog(error: .nonSupportedAccountType(accountTypeDescription: accountType.description)))
        case let .unBackedUpAccount(account): openWalletConnectRelay.accept(.errorDialog(error: .unbackupedAccount(account: account)))
        }
    }

    func onTapCompanyLink() {
        openLinkRelay.accept(AppConfig.companyWebPageLink)
    }

    func onTapRateApp() {
        service.rateApp()
    }
}

extension MainSettingsViewModel {
    enum WalletConnectOpenMode {
        case list
        case errorDialog(error: WalletConnectAppShowView.WalletConnectOpenError)
    }
}

extension MainSettingsViewModel {
    
    func logout() {

        loadingRelay.accept(true)
        
        App.shared.networkService.request(networkClient: .otWalletLogout)
            .subscribe(onNext: { [weak self] (response: OTWalletResponse) in

                self?.service.storeCurrentLoginStateLogout()
                self?.successRelay.accept(())

            }, onError: { [weak self] error in

                self?.service.storeCurrentLoginStateLogout()
                self?.errorRelay.accept(())

            }).disposed(by: disposeBag)
    }
    
    func fetchAmlMeta() {

        guard service.currentLoginState else { return }
        
        var parameter = BaseRequest()
        parameter.lang = service.langCode
        
        App.shared.networkService.request(networkClient: .amlMeta(parameter: parameter.toJSON()))
            .subscribe(onNext: { [weak self] (response: AmlUserMetaResponse) in
                
                self?.service.storeAmlMeta(response: response)
                self?.updateUserStatusRelay.accept(())

            }, onError: { [weak self] error in

            }).disposed(by: disposeBag)
    }
    
    func authTerminate() {
        
        loadingRelay.accept(true)
        
        App.shared.networkService.request(networkClient: .authTerminate)
            .subscribe(onNext: { [weak self] (response: AmlUserMetaResponse) in
                
                guard response.status == true else {
                    self?.errorRelay.accept(())
                    return
                }
                
                self?.successRelay.accept(())
                self?.authTerminateSuccessRelay.accept(())

            }, onError: { [weak self] error in
                
                self?.errorRelay.accept(())
                
            }).disposed(by: disposeBag)
    }

    func authTerminateLogout() {
        service.storeCurrentLoginStateLogout()
    }
}

extension MainSettingsViewModel {

    var currentLoginState: Bool {
        service.currentLoginState
    }
    
    var activeWallets: [Wallet] {
        service.activeWallets
    }
    
    var enableBlockchainType: Bool {
        
        let blockchains = service.activeWallets.map { wallet in
            
            let blockchainType = wallet.token.blockchainType
            return blockchainType == .polygon || blockchainType == .avalanche || blockchainType == .ethereum
        }
        
        return blockchains.contains(true)
    }
    
    var amlValidateStatus: AmlValidateStatus {
        service.amlValidateStatus
    }
}

extension MainSettingsViewModel {

    var loadingSignal: Signal<(Bool)> {
        loadingRelay.asSignal()
    }
    
    var successSignal: Signal<()> {
        successRelay.asSignal()
    }
    
    var errorSignal: Signal<()> {
        errorRelay.asSignal()
    }
    
    var updateUserStatusSignal: Signal<()> {
        updateUserStatusRelay.asSignal()
    }
    
    var authTerminateSuccessSignal: Signal<()> {
        authTerminateSuccessRelay.asSignal()
    }
}
