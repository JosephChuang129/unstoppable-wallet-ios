import UIKit

struct ManualInputVerificationCodeModule {

    static func viewController() -> UIViewController {
        let service = ManualInputVerificationCodeService()
        let viewModel = ManualInputVerificationCodeViewModel(service: service)
        let viewController = ManualInputVerificationCodeViewController(viewModel: viewModel)
        return viewController
    }
}
