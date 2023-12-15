//
//  RowViewModel.swift
//

import Foundation
import UIKit

protocol RowViewModel {
}

// Conform this protocol to handles user press action
protocol ViewModelPressible {
    var cellPressed: ((IndexPath) -> Void)? { get set }
}

struct SectionRowViewModel {
    var rowViewModels: [RowViewModel]
}

struct SectionRowView {
    var rowViews: [UITableViewCell]
}
