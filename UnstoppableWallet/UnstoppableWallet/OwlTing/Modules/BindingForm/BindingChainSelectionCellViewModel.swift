import Foundation
import RxCocoa

protocol BindingChainSelectionCellViewModelInput {
    func updateSelection(isSelected: Bool)
}
protocol BindingChainSelectionCellViewModelOutput: AnyObject {
    var cellPressed: ((IndexPath) -> Void)? { get set }
    var syncState: (() -> Void)? { get set }
    var item: BindingFormService.Item { get }
    var enableSelection: Bool { get }
}
protocol BindingChainSelectionCellViewModelType {
    var inputs: BindingChainSelectionCellViewModelInput { get }
    var outputs: BindingChainSelectionCellViewModelOutput { get }
}

class BindingChainSelectionCellViewModel: RowViewModel, BindingChainSelectionCellViewModelType, BindingChainSelectionCellViewModelInput, BindingChainSelectionCellViewModelOutput, ViewModelPressible {
    
    // MARK: Input & Output
    var inputs: BindingChainSelectionCellViewModelInput { return self }
    var outputs: BindingChainSelectionCellViewModelOutput { return self }
    
    init(item: BindingFormService.Item) {
        self.item = item
        
        let blockchainType = item.wallet.token.blockchainType
        enableSelection = blockchainType == .polygon || blockchainType == .avalanche || blockchainType == .ethereum || blockchainType == .stellar
    }
    
    var item: BindingFormService.Item
    let enableSelection: Bool
    
    var cellPressed: ((IndexPath) -> Void)?
    var syncState: (() -> Void)?
}

extension BindingChainSelectionCellViewModel {
    
    func updateSelection(isSelected: Bool) {
        item.isSelected = isSelected
        syncState?()
    }
}
