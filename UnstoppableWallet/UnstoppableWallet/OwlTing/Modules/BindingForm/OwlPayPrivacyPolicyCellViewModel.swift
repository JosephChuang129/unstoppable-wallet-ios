import Foundation

protocol OwlPayPrivacyPolicyCellViewModelInput {
    func updateSelection(isSelected: Bool)
}
protocol OwlPayPrivacyPolicyCellViewModelOutput: AnyObject {
    var cellPressed: ((IndexPath) -> Void)? { get set }
    var syncState: (() -> Void)? { get set }
    var isSelected: Bool { get }
}
protocol OwlPayPrivacyPolicyCellViewModelType {
    var inputs: OwlPayPrivacyPolicyCellViewModelInput { get }
    var outputs: OwlPayPrivacyPolicyCellViewModelOutput { get }
}

class OwlPayPrivacyPolicyCellViewModel: RowViewModel, OwlPayPrivacyPolicyCellViewModelType, OwlPayPrivacyPolicyCellViewModelInput, OwlPayPrivacyPolicyCellViewModelOutput, ViewModelPressible {
    
    // MARK: Input & Output
    var inputs: OwlPayPrivacyPolicyCellViewModelInput { return self }
    var outputs: OwlPayPrivacyPolicyCellViewModelOutput { return self }
    
    var isSelected: Bool = false
    var cellPressed: ((IndexPath) -> Void)?
    var syncState: (() -> Void)?
}

extension OwlPayPrivacyPolicyCellViewModel {
    
    func updateSelection(isSelected: Bool) {
        self.isSelected = isSelected
        syncState?()
    }
}
