import RxSwift
import RxCocoa

class ForgotPasswordViewModel {
    
    private let service: ForgotPasswordService
    private let disposeBag = DisposeBag()
    private let successRelay = PublishRelay<String>()
    private let loadingRelay = PublishRelay<(Bool)>()
    private let errorRelay = PublishRelay<String>()

    init(service: ForgotPasswordService) {
        self.service = service
        
    }
    
    func start() {
        
    }
    
    func passwordForgot(email: String?) {
        
        loadingRelay.accept(true)
        
        var parameter = SSOPasswordForgotRequest()
        parameter.email = email
        
        service.networkService.request(networkClient: .passwordForgot(parameter: parameter.toJSON()))
            .subscribe(onNext: { [weak self] (response: SSOPasswordForgotResponse) in

                if response.status == true {
                    self?.successRelay.accept("alert.send_password_reset_email".localized)
                } else {
                    self?.errorRelay.accept(response.msg ?? "")
                }

            }, onError: { [weak self] error in

                self?.errorRelay.accept("alert.error.try_again_later".localized)

            }).disposed(by: disposeBag)
    }
    
}

extension ForgotPasswordViewModel {

    var loadingSignal: Signal<(Bool)> {
        loadingRelay.asSignal()
    }
    
    var successSignal: Signal<String> {
        successRelay.asSignal()
    }
    
    var errorSignal: Signal<String> {
        errorRelay.asSignal()
    }
}
