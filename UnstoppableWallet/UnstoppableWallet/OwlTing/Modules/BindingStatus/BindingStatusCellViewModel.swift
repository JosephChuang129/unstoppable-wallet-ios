import Foundation

protocol BindingStatusCellViewModelInput {}
protocol BindingStatusCellViewModelOutput: AnyObject {
    var cellPressed: ((IndexPath) -> Void)? { get set }
    var item: BindingStatusService.Item { get }
}
protocol BindingStatusCellViewModelType {
    var inputs: BindingStatusCellViewModelInput { get }
    var outputs: BindingStatusCellViewModelOutput { get }
}

class BindingStatusCellViewModel: RowViewModel, BindingStatusCellViewModelType, BindingStatusCellViewModelInput, BindingStatusCellViewModelOutput, ViewModelPressible {
    
    // MARK: Input & Output
    var inputs: BindingStatusCellViewModelInput { return self }
    var outputs: BindingStatusCellViewModelOutput { return self }
    
    init(item: BindingStatusService.Item) {
        self.item = item
    }
    
    let item: BindingStatusService.Item
    var cellPressed: ((IndexPath) -> Void)?
}
