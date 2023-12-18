import UIKit
import ComponentKit

class PrivacyPolicyCell: BaseThemeCell {
    
    // MARK: ViewModel
    private static let padding: CGFloat = .margin16
    
    var onCheckButtonSelected: ((Bool) -> ())?
    
    private lazy var titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
        $0.textColor = .themeLeah
    }
    
    private lazy var checkButton = UIButton().then {
        $0.setImage(UIImage(named: "checkbox_active_24"), for: .selected)
        $0.setImage(UIImage(named: "checkbox_diactive_24"), for: .normal)
        $0.addTarget(self, action: #selector(onTapCheckButton), for: .touchUpInside)
        $0.tintColor = .themeLeah
        $0.touchEdgeInsets = .init(top: -20, left: -20, bottom: -20, right: -20)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        viewSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    deinit {
//        Dprint("\(type(of: self)) \(#function)")
    }
}

extension PrivacyPolicyCell {
    private func viewSetup() {
        
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        set(backgroundStyle: .lawrence, cornerRadius: 12, isFirst: true, isLast: true)
        wrapperView.backgroundColor = .themeLawrence
        
        let stackView = CommonHStackView(arrangedSubviews: [checkButton, titleLabel], spacing: 15)
        wrapperView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(PrivacyPolicyCell.padding)
        }
        
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        checkButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let countText = "owlTing_owlting.privacy_policy".localized
        let remindText = "owlTing_owlting.privacy_policy_agreement".localized
        let textRange = (remindText as NSString).range(of: countText)
        let attrString = NSMutableAttributedString(string: remindText)
        attrString.addAttributes([.foregroundColor: UIColor.themeYellowD.cgColor, .font: UIFont.systemFont(ofSize: 14, weight: .medium)], range: textRange)
        titleLabel.attributedText = attrString
    }
    
    @objc private func onTapCheckButton() {
        let isSelected = !checkButton.isSelected
        checkButton.isSelected = isSelected
        onCheckButtonSelected?(isSelected)
    }
}
