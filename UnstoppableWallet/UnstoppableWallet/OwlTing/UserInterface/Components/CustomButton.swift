import UIKit
import SnapKit

open class Primary2Button: UIButton {
    public static let height: CGFloat = .heightButton

    public init() {
        super.init(frame: .zero)

        cornerRadius = Self.height / 2
        layer.cornerCurve = .continuous
        contentEdgeInsets = UIEdgeInsets(top: 0, left: .margin16, bottom: 0, right: .margin16)

        titleLabel?.font = .headline2
        setTitleColor(.themeGray50, for: .disabled)

        snp.makeConstraints { maker in
            maker.height.equalTo(Self.height)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func set(style: Style) {
        switch style {
        case .yellow:
            setTitleColor(.white, for: .normal)
            setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
            setBackgroundColor(.themeYellowD, for: .normal)
            setBackgroundColor(.themeYellow50, for: .highlighted)
            setBackgroundColor(UIColor.themeYellowD.withAlphaComponent(0.4), for: .disabled)
        case .yellowTitle:
            setTitleColor(.themeYellowD, for: .normal)
            setBackgroundColor(.clear, for: .normal)
            setBackgroundColor(.clear, for: .highlighted)
            setBackgroundColor(.clear, for: .disabled)
        case .blackTitle:
            setTitleColor(.themeLeah, for: .normal)
            setBackgroundColor(.clear, for: .normal)
            setBackgroundColor(.clear, for: .highlighted)
            setBackgroundColor(.clear, for: .disabled)
        case .blackBordered:
            setTitleColor(.themeLeah, for: .normal)
            setTitleColor(.themeBlackBorder, for: .disabled)
            borderColor = .themeBlackBorder
            borderWidth = 1
            setBackgroundColor(.clear, for: .normal)
            setBackgroundColor(.clear, for: .highlighted)
            setBackgroundColor(.clear, for: .disabled)
        }
    }

    public enum Style {
        case yellow
        case yellowTitle
        case blackTitle
        case blackBordered
    }

}

class GenderRadioButton: UIButton {
    
    func viewSetup() {
//        touchEdgeInsets = .init(inset: -20)
        setImage(UIImage(named: "circle_radiooff_24"), for: .normal)
        setImage(UIImage(named: "circle_radioon_yellow_24"), for: .selected)
        setTitleColor(.themeLeah, for: .selected)
        setTitleColor(.themeLeah, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewSetup()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewSetup()
    }
}
