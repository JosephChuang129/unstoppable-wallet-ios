import RxSwift
import PromiseKit
import ComponentKit
import RxRelay
import RxCocoa

class ManualInputVerificationCodeViewModel {
    
    private let service: ManualInputVerificationCodeService
    private let disposeBag = DisposeBag()

    init(service: ManualInputVerificationCodeService) {
        self.service = service
        
    }
    
    func start() {
        
    }
    
}
