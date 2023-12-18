import RxSwift
import PromiseKit
import ComponentKit
import RxRelay
import RxCocoa

class ScanVerificationCodeViewModel {
    
    private let service: ScanVerificationCodeService
    private let disposeBag = DisposeBag()

    init(service: ScanVerificationCodeService) {
        self.service = service
        
    }
    
    func start() {
        
    }
    
}
