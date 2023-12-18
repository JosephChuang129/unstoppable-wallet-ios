import Foundation

protocol BindingStatusActionCellViewModelInput {}
protocol BindingStatusActionCellViewModelOutput: AnyObject {
    var cellPressed: ((IndexPath) -> Void)? { get set }
    var canUnBinding: Bool { get }
}
protocol BindingStatusActionCellViewModelType {
    var inputs: BindingStatusActionCellViewModelInput { get }
    var outputs: BindingStatusActionCellViewModelOutput { get }
}

class BindingStatusActionCellViewModel: RowViewModel, BindingStatusActionCellViewModelType, BindingStatusActionCellViewModelInput, BindingStatusActionCellViewModelOutput, ViewModelPressible {
    
    // MARK: Input & Output
    var inputs: BindingStatusActionCellViewModelInput { return self }
    var outputs: BindingStatusActionCellViewModelOutput { return self }
    
    init(canUnBinding: Bool) {
        self.canUnBinding = canUnBinding
    }
    
    let canUnBinding: Bool
    var cellPressed: ((IndexPath) -> Void)?
}
