import UIKit

struct LoginModule {

    static func viewController() -> UIViewController {
        let service = LoginService(networkService: App.shared.networkService, accountManager: App.shared.accountManager, walletManager: App.shared.walletManager, adapterManager: App.shared.adapterManager)
        let viewModel = LoginViewModel(service: service)
        let viewController = LoginViewController(viewModel: viewModel)
        return viewController
    }
}
