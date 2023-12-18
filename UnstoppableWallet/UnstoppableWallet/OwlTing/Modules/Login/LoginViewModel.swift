import RxSwift
import PromiseKit
import ComponentKit
import RxRelay
import RxCocoa
import ObjectMapper

import Foundation

class LoginViewModel {
    
    private let service: LoginService
    private let disposeBag = DisposeBag()
    private let successRelay = PublishRelay<String>()
    private let loadingRelay = PublishRelay<(Bool)>()
    private let errorRelay = PublishRelay<String>()
    private let showBingFormRelay = PublishRelay<()>()
    private let tokenExpiredRelay = PublishRelay<()>()
    
    init(service: LoginService) {
        self.service = service
        
    }
    
    func start() {
        
    }
}

extension LoginViewModel {
    
    func login(email: String?, password: String?) {
        
        loadingRelay.accept(true)
        
        var parameter = OTWalletLoginRequest()
        parameter.email = email
        parameter.password = password
        
        service.networkService.request(networkClient: .otWalletLogin(parameter: parameter.toJSON()))
            .subscribe(onNext: { [weak self] (response: OTWalletLoginResponse) in
                
                self?.handleLoginResult(response: response)
                
            }, onError: { [weak self] error in
                
                self?.errorRelay.accept("alert.error.try_again_later".localized)
                
            }).disposed(by: disposeBag)
    }
    
    func fetchAmlMeta() {
        
        var parameter = BaseRequest()
        parameter.lang = service.langCode
        
        service.networkService.request(networkClient: .amlMeta(parameter: parameter.toJSON()))
            .subscribe(onNext: { [weak self] (response: AmlUserMetaResponse) in
                
                self?.handleAmlMetaResult(response: response)
                
            }, onError: { [weak self] error in
                
                self?.successRelay.accept("alert.login_success".localized)
                self?.service.finishFlow()
                
            }).disposed(by: disposeBag)
    }
    
    func fetchScanLogin(qrcode: String) {
        
        loadingRelay.accept(true)
        
        let owlPayQrcodeResponse = Mapper<OwlPayQrcodeResponse>().map(JSONString: qrcode)
        
        var parameter = CustomerProfileRequest()
        parameter.token = owlPayQrcodeResponse?.token

        service.networkService.request(networkClient: .otCustomerProfile(uuid: owlPayQrcodeResponse?.owltingUUID ?? "", parameter: parameter.toJSON()))
            .subscribe(onNext: { [weak self] (response: OTWalletLoginResponse) in
                
                self?.handleScanLoginResult(response: response)

            }, onError: { [weak self] error in
                
                self?.errorRelay.accept("alert.error.try_again_later".localized)

            }).disposed(by: disposeBag)
    }
    
}

extension LoginViewModel {
    
    func handleLoginResult(response: OTWalletLoginResponse) {
        
        guard response.status == true else {
            
            switch response.code {
            case "30003":
                errorRelay.accept("login_account_deleted_error".localized)
            default:
                errorRelay.accept("alert.error.try_again_later".localized)
            }
            
            return
        }
        
        service.storeUserData(response: response)
        fetchAmlMeta()
    }
    
    
    func handleScanLoginResult(response: OTWalletLoginResponse) {
        
        guard response.status == true else {
            
            switch response.code {
            case "30003":
                errorRelay.accept("login_account_deleted_error".localized)
            case "00003":
                tokenExpiredRelay.accept(())
                
            default:
                errorRelay.accept("alert.error.try_again_later".localized)
            }
            
            return
        }
        
        service.storeUserData(response: response)
        fetchAmlMeta()
    }
    
    func handleAmlMetaResult(response: AmlUserMetaResponse) {
        
        service.storeAmlMeta(response: response)
        successRelay.accept("alert.login_success".localized)
        response.code == AmlValidateStatus.userNotFound.statusCode() ? showBingFormRelay.accept(()) : service.finishFlow()
    }
}

extension LoginViewModel {
    
    var loadingSignal: Signal<(Bool)> {
        loadingRelay.asSignal()
    }
    
    var successSignal: Signal<String> {
        successRelay.asSignal()
    }
    
    var errorSignal: Signal<String> {
        errorRelay.asSignal()
    }
    
    var showBingFormSignal: Signal<()> {
        showBingFormRelay.asSignal()
    }
    
    var tokenExpiredSignal: Signal<()> {
        tokenExpiredRelay.asSignal()
    }
}

extension LoginViewModel {
    
    func loginSso(email: String?, password: String?) {
        
        loadingRelay.accept(true)
        
        var parameter = SSOProviderRequest()
        parameter.password = password
        parameter.email = email
        
        var ssoProviderResponse = SSOProviderResponse()
        
        firstly {
            fetchUserSecretPromise(parameter: parameter)
            
        }.done { [weak self] (response) in
            ssoProviderResponse = response
            
        }.then {
            self.otWalletLoginPromise(ssoProviderResponse)
            
        }.done { [weak self] (response) in
            self?.handleLoginResult(response: response)
            
        }.ensure {
            
        }.catch { [weak self] (error) in
            self?.errorRelay.accept("alert.login_failed".localized)
        }
    }
    
    func fetchUserSecretPromise(parameter: SSOProviderRequest) -> Promise<SSOProviderResponse> {
        
        return Promise(resolver: { body in
            service.networkService.request(networkClient: .fetchUserSecret(parameter: parameter.toJSON()))
                .subscribe(onNext: {
                    body.fulfill($0)
                }, onError: {
                    body.reject($0)
                })
                .disposed(by: disposeBag)
        })
    }
    
    func otWalletLoginPromise(_ ssoProviderResponse: SSOProviderResponse) -> Promise<OTWalletLoginResponse> {
        
        var parameter = OTWalletLoginRequest()
        parameter.secret = ssoProviderResponse.secret
        parameter.uuid = ssoProviderResponse.uuid
        //        parameter.expire = 0.5*2*24*60
        //        parameter.expire = 0.0166666667
        
        return Promise(resolver: { body in
            service.networkService.request(networkClient: .otWalletLogin(parameter: parameter.toJSON()))
                .subscribe(onNext: {
                    body.fulfill($0)
                }, onError: {
                    body.reject($0)
                })
                .disposed(by: disposeBag)
        })
    }
}
