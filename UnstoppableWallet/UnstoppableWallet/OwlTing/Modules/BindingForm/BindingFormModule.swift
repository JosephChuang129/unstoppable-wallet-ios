import UIKit

struct BindingFormModule {

    static func viewController(action: BindingFormModule.Action = .default) -> BindingFormViewController {
        let service = BindingFormService(walletManager: App.shared.walletManager, networkService: App.shared.networkService, accountManager: App.shared.accountManager)
        let viewModel = BindingFormViewModel(service: service, action: action)
        let viewController = BindingFormViewController(viewModel: viewModel, urlManager: UrlManager(inApp: true))
        return viewController
    }
}

extension BindingFormModule {

    enum Action {
        case `default`
        case newRoot
    }
}
