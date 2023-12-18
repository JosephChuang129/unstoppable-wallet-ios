import UIKit

struct BindingStatusModule {

    static func viewController() -> BindingStatusViewController {
        let service = BindingStatusService(walletManager: App.shared.walletManager, accountManager: App.shared.accountManager, networkService: App.shared.networkService, marketKit: App.shared.marketKit)
        let viewModel = BindingStatusViewModel(service: service)
        let viewController = BindingStatusViewController(viewModel: viewModel)
        return viewController
    }
}
