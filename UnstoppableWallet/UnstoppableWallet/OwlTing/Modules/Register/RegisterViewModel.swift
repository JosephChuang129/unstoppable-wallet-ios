import RxSwift
import Foundation
import RxCocoa

class RegisterViewModel {
    
    private let service: RegisterService
    private let disposeBag = DisposeBag()
    private let successRelay = PublishRelay<String>()
    private let loadingRelay = PublishRelay<(Bool)>()
    private let errorRelay = PublishRelay<String>()
    private var approveAllowedRelay = BehaviorRelay<Bool>(value: false)
    private let showBingFormRelay = PublishRelay<()>()
    
    init(service: RegisterService) {
        self.service = service
        
    }
    
    var email: String?
    var password: String?
    var confirmPassword: String?
    var name: String?
    var gender: String?
    var birthday: Date?
    var isPrivacyPolicySelected = false
    var genderCategory: GenderCategory?
    
    func start() {
        syncStates()
    }
    
}

extension RegisterViewModel {

    func register() {
        
        guard let name = name, let password = password, let date = birthday, let genderCategory = genderCategory else {
            return
        }
        
        loadingRelay.accept(true)
        
        var parameter = OTWalletRegisterRequest()
        parameter.name = name
        parameter.email = email
        parameter.password = password
        parameter.gender = GenderCategory.fetchRaw(genderCategory)
        parameter.birthday = DateHelper.instance.formatOTDate(from: date)
        
        service.networkService.request(networkClient: .otWalletRegister(parameter: parameter.toJSON()))
            .subscribe(onNext: { [weak self] (response: OTWalletRegisterResponse) in

                self?.handleRegisterResult(response: response)

            }, onError: { [weak self] error in

                self?.errorRelay.accept("alert.error.try_again_later".localized)

            }).disposed(by: disposeBag)
    }
    
    func handleRegisterResult(response: OTWalletRegisterResponse) {
        
        if response.status == true {

            successRelay.accept("alert.register_success".localized)
            service.storeUserData(response: response)
            showBingFormRelay.accept(())

        } else {
            errorRelay.accept("alert.register_failed".localized)
        }
    }
}


extension RegisterViewModel {
    
    func onChange(name: String?) {
        self.name = name
        syncStates()
    }
    
    func onChange(email: String?) {
        self.email = email
        syncStates()
    }
    
    func onChange(password: String?) {
        self.password = password
        syncStates()
    }
    
    func onChange(confirmPassword: String?) {
        self.confirmPassword = confirmPassword
        syncStates()
    }
    
    func onChange(birthday: Date?) {
        self.birthday = birthday
        syncStates()
    }
    
    func onChange(gender: GenderCategory?) {
        self.genderCategory = gender
        syncStates()
    }
    
    func onChange(isPrivacyPolicySelected: Bool) {
        
        self.isPrivacyPolicySelected = isPrivacyPolicySelected
        syncStates()
    }
    
    private func syncStates() {
        
        if let name = name, !name.isEmpty,
           let email = email, !email.isEmpty,
           email.isValidEmail,
           let password = password, !password.isEmpty, password.passwordValid(),
           let confirmPassword = confirmPassword, !confirmPassword.isEmpty, confirmPassword.passwordValid(),
           password == confirmPassword,
           let _ = birthday,
           let _ = genderCategory,
           isPrivacyPolicySelected {
            
            approveAllowedRelay.accept(true)
            
        } else {
            
            approveAllowedRelay.accept(false)
        }
    }
}


extension RegisterViewModel {

    var loadingSignal: Signal<(Bool)> {
        loadingRelay.asSignal()
    }
    
    var successSignal: Signal<String> {
        successRelay.asSignal()
    }
    
    var errorSignal: Signal<String> {
        errorRelay.asSignal()
    }
    
    var approveAllowedDriver: Driver<Bool> {
        approveAllowedRelay.asDriver()
    }
    
    var showBingFormSignal: Signal<()> {
        showBingFormRelay.asSignal()
    }
    
    var privacyPolicyUrl: String {
        "https://www.owlting.com/portal/about/privacy?lang=\(service.langCode)"
    }
}
