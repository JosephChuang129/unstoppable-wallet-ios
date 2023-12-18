import Foundation
import RxSwift
import RxCocoa

protocol BindingFormCellViewModelInput {}
protocol BindingFormCellViewModelOutput: AnyObject {
    var cellPressed: ((IndexPath) -> Void)? { get set }
    var syncState: (() -> Void)? { get set }
    var name: String? { get set }
    var birthday: Date? { get set }
    var selectedAmlCountry: AmlCountry? { get set }
    var selectedAmlCountrySignal: Signal<AmlCountry> { get }
    var status: AmlValidateStatus { get }
}
protocol BindingFormCellViewModelType {
    var inputs: BindingFormCellViewModelInput { get }
    var outputs: BindingFormCellViewModelOutput { get }
}

class BindingFormCellViewModel: RowViewModel, BindingFormCellViewModelType, BindingFormCellViewModelInput, BindingFormCellViewModelOutput, ViewModelPressible {
    
    // MARK: Input & Output
    var inputs: BindingFormCellViewModelInput { return self }
    var outputs: BindingFormCellViewModelOutput { return self }
    
    var cellPressed: ((IndexPath) -> Void)?
    var syncState: (() -> Void)?
    
    let status: AmlValidateStatus
    init(status: AmlValidateStatus) {
        self.status = status
        
        
        if status == .verified || status == .unfinished {
            
            let ssoUserMeta = App.shared.accountManager.amlUserMeta?.ssoUserMeta
            self.name = ssoUserMeta?.name
            selectedAmlCountry = ssoUserMeta?.country
            
            if let dateString = ssoUserMeta?.birthday {
                birthday = DateHelper.yyyyMMdd.date(from: dateString)
            }
        }
    }
    
    var name: String? { didSet { syncState?() } }
    var birthday: Date? { didSet { syncState?() } }
    var selectedAmlCountry: AmlCountry? {
        didSet {
            if let country = selectedAmlCountry {
                selectedAmlCountryRelay.accept(country)
            }
        }
    }
    
    private let selectedAmlCountryRelay = PublishRelay<AmlCountry>()
}

extension BindingFormCellViewModel {
    
    var selectedAmlCountrySignal: Signal<AmlCountry> {
        selectedAmlCountryRelay.asSignal()
    }
}
