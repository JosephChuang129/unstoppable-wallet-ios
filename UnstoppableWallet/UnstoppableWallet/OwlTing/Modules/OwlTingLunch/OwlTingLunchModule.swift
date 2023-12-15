import UIKit

struct OwlTingLunchModule {

    static func viewController() -> UIViewController {
        let service = OwlTingLunchService()
        let viewModel = OwlTingLunchViewModel(service: service)
        let viewController = OwlTingLunchViewController(viewModel: viewModel, urlManager: UrlManager(inApp: true))
        return viewController
    }
}
