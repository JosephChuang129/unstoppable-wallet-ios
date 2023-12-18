import UIKit

protocol ScanVerificationCodeDelegate: AnyObject {
    func didScan(string: String)
}

struct ScanVerificationCodeModule {

    static func viewController(delegate: ScanVerificationCodeDelegate) -> UIViewController {
        let service = ScanVerificationCodeService()
        let viewModel = ScanVerificationCodeViewModel(service: service)
        let viewController = ScanVerificationCodeViewController(viewModel: viewModel, delegate: delegate)
        return viewController
    }
}
