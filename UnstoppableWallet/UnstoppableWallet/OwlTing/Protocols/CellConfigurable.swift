//
//  CellConfigurable.swift
//

import Foundation
import UIKit

protocol CellConfigurable {
    func bind(viewModel: RowViewModel)
}

protocol CellOffsetSetupable {
    
    var collectionViewOffset: CGFloat { get set }
    func setCollectionView(forRow row: Int)
    func setFirst()
    func updateOffset(offSet: CGFloat)
}


