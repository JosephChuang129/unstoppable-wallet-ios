import UIKit
import ComponentKit

class BindingChainSelectionCell: BaseThemeCell {
    
    // MARK: ViewModel
    var viewModel: BindingChainSelectionCellViewModelType?
    private static let padding: CGFloat = .margin16
    
    private lazy var nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
        $0.textColor = .themeLeah
    }
    
    private lazy var checkButton = UIButton().then {
        $0.setImage(UIImage(named: "checkbox_active_24"), for: .selected)
        $0.setImage(UIImage(named: "checkbox_diactive_24"), for: .normal)
        $0.addTarget(self, action: #selector(onTapCheckButton), for: .touchUpInside)
        $0.tintColor = .themeLeah
        $0.imageView?.contentMode = .scaleAspectFit
        $0.touchEdgeInsets = .init(top: -20, left: -20, bottom: -20, right: -20)
    }
    
    private lazy var blockchainBadgeView = BadgeView().then {
        $0.set(style: .small)
    }
    
    private lazy var chainImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var stackView = CommonHStackView(arrangedSubviews: [checkButton, chainImageView, nameLabel, blockchainBadgeView, UILabel()], spacing: 10).then {
        $0.setCustomSpacing(20, after: checkButton)
        $0.alignment = .center
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
    
    override func set(backgroundStyle: BaseThemeCell.BackgroundStyle, cornerRadius: CGFloat = .cornerRadius12, isFirst: Bool = false, isLast: Bool = false) {
        
        super.set(backgroundStyle: .lawrence, cornerRadius: cornerRadius, isFirst: isFirst, isLast: isLast)
        topSeparatorView.isHidden = true
    }
    
    deinit {
//        Dprint("\(type(of: self)) \(#function)")
    }
}

extension BindingChainSelectionCell {
    private func viewSetup() {
        
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        wrapperView.backgroundColor = .themeLawrence
        
        wrapperView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(BindingChainSelectionCell.padding)
        }
        
        chainImageView.snp.makeConstraints {
            $0.size.equalTo(CGFloat.iconSize24)
        }
        
        blockchainBadgeView.setContentHuggingPriority(.required, for: .horizontal)
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        chainImageView.setContentHuggingPriority(.required, for: .horizontal)
        checkButton.setContentHuggingPriority(.required, for: .horizontal)
        checkButton.setContentHuggingPriority(.required, for: .vertical)
    }
    
    @objc private func onTapCheckButton() {
        
        let isSelected = !checkButton.isSelected
        checkButton.isSelected = isSelected
        viewModel?.inputs.updateSelection(isSelected: isSelected)
    }
}

extension BindingChainSelectionCell: CellConfigurable {
    func bind(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? BindingChainSelectionCellViewModelType else { return }
        self.viewModel = viewModel
        
        let item = viewModel.outputs.item
        let wallet = item.wallet
        let enableSelection = viewModel.outputs.enableSelection
        
        nameLabel.text = wallet.coin.code
        checkButton.isSelected = item.isSelected
        
        chainImageView.kf.setImage(with: URL(string: wallet.coin.imageUrl), options: [.transition(.fade(0.4))])
        if let blockchainBadge = wallet.badge {
            blockchainBadgeView.text = blockchainBadge
            blockchainBadgeView.isHidden = false
        } else {
            blockchainBadgeView.isHidden = true
        }
        
        stackView.alpha = enableSelection ? 1.0 : 0.3
        stackView.isUserInteractionEnabled = enableSelection ? true : false
    }
}
