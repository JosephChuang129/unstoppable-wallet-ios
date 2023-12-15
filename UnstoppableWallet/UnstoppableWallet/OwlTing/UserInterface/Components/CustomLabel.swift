//
//  CustomLabel.swift
//

import UIKit

class PrimaryLabel: PaddingLabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // This will call `awakeFromNib` in your code
        setup()
    }
    
    func setup() {
        
        textColor = .themeGray
        backgroundColor = .clear
        font = UIFont.systemFont(ofSize: 15, weight: .regular)
        padding = .init(top: 0, left: 10, bottom: 0, right: 10)
    }
}

class RequiredLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // This will call `awakeFromNib` in your code
    }
    
    func setup(text: String, font: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium)) {
        
        let title = "* " + text
        let attributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font: font])
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.themeYellowD, range: NSRange(location: 0, length: 1))
        attributedText = attributedString
    }
}

class PaddingLabel : UILabel {
    
    var padding = UIEdgeInsets.zero
    
    @IBInspectable
    var paddingLeft: CGFloat {
        get { return padding.left }
        set { padding.left = newValue }
    }
    
    @IBInspectable
    var paddingRight: CGFloat {
        get { return padding.right }
        set { padding.right = newValue }
    }
    
    @IBInspectable
    var paddingTop: CGFloat {
        get { return padding.top }
        set { padding.top = newValue }
    }
    
    @IBInspectable
    var paddingBottom: CGFloat {
        get { return padding.bottom }
        set { padding.bottom = newValue }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insets = self.padding
        var rect = super.textRect(forBounds: bounds.inset(by: insets), limitedToNumberOfLines: numberOfLines)
        rect.origin.x    -= insets.left
        rect.origin.y    -= insets.top
        rect.size.width  += (insets.left + insets.right)
        rect.size.height += (insets.top + insets.bottom)
        return rect
    }
}

class TermLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // This will call `awakeFromNib` in your code
    }
    
    func setup(text: String) {
        
        numberOfLines = 0
        let paraph = NSMutableParagraphStyle()
        paraph.lineSpacing = 10
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular),
                          NSAttributedString.Key.paragraphStyle: paraph]
        attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}

