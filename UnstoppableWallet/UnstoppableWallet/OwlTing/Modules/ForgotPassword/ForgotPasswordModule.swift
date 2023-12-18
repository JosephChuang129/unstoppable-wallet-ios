import UIKit

struct ForgotPasswordModule {

    static func viewController() -> UIViewController {
        let service = ForgotPasswordService(networkService: App.shared.networkService)
        let viewModel = ForgotPasswordViewModel(service: service)
        let viewController = ForgotPasswordViewController(viewModel: viewModel)
        return viewController
    }
}
