import UIKit

protocol CountryListSelectDelegate: AnyObject {
    func didSelect(country: AmlCountry)
}

struct CountryListModule {

    static func viewController(delegate: CountryListSelectDelegate) -> UIViewController {
        let service = CountryListService(networkService: App.shared.networkService)
        let viewModel = CountryListViewModel(service: service)
        let viewController = CountryListViewController(viewModel: viewModel, delegate: delegate)
        return viewController
    }
}
