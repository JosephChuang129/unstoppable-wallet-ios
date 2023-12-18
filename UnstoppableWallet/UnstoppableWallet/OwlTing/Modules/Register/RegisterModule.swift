import UIKit

struct RegisterModule {

    static func viewController() -> UIViewController {
        let service = RegisterService(networkService: App.shared.networkService, accountManager: App.shared.accountManager)
        let viewModel = RegisterViewModel(service: service)
        let viewController = RegisterViewController(viewModel: viewModel, urlManager: UrlManager(inApp: true))
        return viewController
    }
}
