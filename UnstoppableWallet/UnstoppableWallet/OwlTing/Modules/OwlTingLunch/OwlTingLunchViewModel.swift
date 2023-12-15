import Foundation
import RxSwift

protocol OwlTingLunchViewModelInputs {
    func start()
}

protocol OwlTingLunchViewModelOutputs: AnyObject {
    var isLoading: ((Bool) -> Void)? { get set }
    var onErrorHandling: ((ErrorResult) -> Void)? { get set }
    var updateHandler: (() -> Void)? { get set }
    var agreementUrl: String { get }
}

protocol OwlTingLunchViewModelType {
    var inputs: OwlTingLunchViewModelInputs { get }
    var outputs: OwlTingLunchViewModelOutputs { get }
}

class OwlTingLunchViewModel: BaseViewModel, OwlTingLunchViewModelType, OwlTingLunchViewModelInputs, OwlTingLunchViewModelOutputs {
    
    public var inputs: OwlTingLunchViewModelInputs { return self }
    public var outputs: OwlTingLunchViewModelOutputs { return self }
    
    init(service: OwlTingLunchService) {
        self.service = service
        
    }

    private let service: OwlTingLunchService
    
    //MARK: Outputs
    
    private let disposeBag = DisposeBag()
}

extension OwlTingLunchViewModel {
    
    //MARK: Inputs
    func start() {
        
    }
}

extension OwlTingLunchViewModel {
    
    var agreementUrl: String {
        "https://www.owlting.com/owlpay/wallet-terms?lang=\(service.langCode)"
    }
}
