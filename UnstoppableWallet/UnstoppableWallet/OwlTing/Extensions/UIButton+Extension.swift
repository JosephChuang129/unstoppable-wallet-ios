//
//  UIButton+Extension.swift
//

import Foundation
import UIKit

private var buttonTouchEdgeInsets: UIEdgeInsets?

extension UIButton {
    var touchEdgeInsets:UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &buttonTouchEdgeInsets) as? UIEdgeInsets
        }

        set {
            objc_setAssociatedObject(self,
                &buttonTouchEdgeInsets, newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var frame = self.bounds
        
        if let touchEdgeInsets = self.touchEdgeInsets {
            frame = frame.inset(by: touchEdgeInsets)
        }
        
        return frame.contains(point);
    }
}
