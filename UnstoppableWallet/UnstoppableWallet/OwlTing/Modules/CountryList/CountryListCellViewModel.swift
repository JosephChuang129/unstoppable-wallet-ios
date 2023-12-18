import Foundation

protocol CountryListCellViewModelInput {}
protocol CountryListCellViewModelOutput: AnyObject {
    var cellPressed: ((IndexPath) -> Void)? { get set }
    var country: AmlCountry { get }
}
protocol CountryListCellViewModelType {
    var inputs: CountryListCellViewModelInput { get }
    var outputs: CountryListCellViewModelOutput { get }
}

class CountryListCellViewModel: RowViewModel, CountryListCellViewModelType, CountryListCellViewModelInput, CountryListCellViewModelOutput, ViewModelPressible {
    
    // MARK: Input & Output
    var inputs: CountryListCellViewModelInput { return self }
    var outputs: CountryListCellViewModelOutput { return self }
    
    init(country: AmlCountry) {
        self.country = country
    }
    
    let country: AmlCountry
    
    var cellPressed: ((IndexPath) -> Void)?
}
