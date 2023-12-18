import Foundation
import RxSwift

protocol CountryListViewModelInputs {
    func start()
    func apply(filter: String?)
}

protocol CountryListViewModelOutputs: AnyObject {
    var isLoading: ((Bool) -> Void)? { get set }
    var onErrorHandling: ((ErrorResult) -> Void)? { get set }
    var updateHandler: (() -> Void)? { get set }
    var cellPressed: (() -> Void)? { get set }
    var countryListCellPressed: ((AmlCountry) -> Void)? { get set }
    func numberOfSections() -> Int
    func numberOfItemsInSection(_ section: Int) -> Int
    func cellIdentifier(for viewModel: RowViewModel) -> String
    func getCellViewModel(at indexPath: IndexPath) -> RowViewModel
}

protocol CountryListViewModelType {
    var inputs: CountryListViewModelInputs { get }
    var outputs: CountryListViewModelOutputs { get }
}

class CountryListViewModel: BaseViewModel, CountryListViewModelType, CountryListViewModelInputs, CountryListViewModelOutputs {
    
    public var inputs: CountryListViewModelInputs { return self }
    public var outputs: CountryListViewModelOutputs { return self }
    
    init(service: CountryListService) {
        self.service = service
        
    }

    private let service: CountryListService
    
    //MARK: Outputs
    
    private let disposeBag = DisposeBag()
    var sectionRowViewModels: [SectionRowViewModel] = []
    var cellPressed: (() -> Void)?
    var countryListCellPressed: ((AmlCountry) -> Void)?
    private var countries: [AmlCountry] = []

    private var filter: String = ""
    
    func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is CountryListCellViewModel:
            return CountryListCell.cellIdentifier()
        
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> RowViewModel {
        let section = sectionRowViewModels[indexPath.section]
        let rowViewModel = section.rowViewModels[indexPath.item]
        return rowViewModel
    }
    
    func numberOfSections() -> Int {
        return sectionRowViewModels.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return sectionRowViewModels[section].rowViewModels.count
    }
}

extension CountryListViewModel {
    
    //MARK: Inputs
    func start() {
        
        fetchAmlCountry()
    }
    func apply(filter: String?) {
        
        self.filter = filter ?? ""
        buildCellViewModels()
    }
}

extension CountryListViewModel {
    
    func fetchAmlCountry() {
        
        var parameter = AmlCountryRequest()
        parameter.lang = service.langCode
        
        service.networkService.request(networkClient: .amlCountry(parameter: parameter.toJSON()))
            .subscribe(onNext: { [weak self] (response: AmlCountryResponse) in
                
                self?.countries = response.data ?? []
                self?.buildCellViewModels()

            }, onError: { [weak self] error in

            }).disposed(by: disposeBag)
    }
}

extension CountryListViewModel {

    private func buildCellViewModels() {
        
        let cellViewModels = filterCountries.map { country -> CountryListCellViewModel in
            let vm = CountryListCellViewModel(country: country)
            vm.outputs.cellPressed = { [weak self] indexPath in
                self?.countryListCellPressed?(country)
            }
            return vm
        }
        
        sectionRowViewModels = [SectionRowViewModel(rowViewModels: cellViewModels)]
        updateHandler?()
    }
    
    var filterCountries: [AmlCountry] {
        
        guard filter.isEmpty else {
            return countries.filter {
                ($0.name ?? "").localizedCaseInsensitiveContains(filter)
            }
        }
        
        return self.countries
    }
}
