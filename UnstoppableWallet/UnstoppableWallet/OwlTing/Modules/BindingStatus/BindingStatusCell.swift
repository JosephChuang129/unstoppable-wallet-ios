import Foundation
import UIKit
import ComponentKit

class BindingStatusCell: UITableViewCell {
    
    // MARK: ViewModel
    var viewModel: BindingStatusCellViewModelType?
    
    private lazy var titleLabel = UILabel().then {
        $0.textColor = .themeLeah
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    private lazy var wrapperView = BorderedView()
    
    private lazy var blockchainBadgeView = BadgeView().then {
        $0.set(style: .small)
    }
    
    private lazy var chainImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var statusLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        $0.textAlignment = .right
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
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension BindingStatusCell {
    private func viewSetup() {
        
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        contentView.addSubview(wrapperView)
        wrapperView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(54)
        }
        
        let stackView = CommonHStackView(arrangedSubviews: [chainImageView, titleLabel, blockchainBadgeView, statusLabel], spacing: 10)
        wrapperView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.centerY.equalToSuperview()
        }
        
        chainImageView.snp.makeConstraints {
            $0.size.equalTo(CGFloat.iconSize24)
        }
        
        blockchainBadgeView.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        chainImageView.setContentHuggingPriority(.required, for: .horizontal)
        
        wrapperView.backgroundColor = .themeLawrence
        wrapperView.borderColor = .gray
        wrapperView.cornerRadius = 14
    }
}

extension BindingStatusCell: CellConfigurable {
    func bind(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? BindingStatusCellViewModelType else { return }
        self.viewModel = viewModel
        
        let item = viewModel.outputs.item
        let chain = item.chain
        titleLabel.text = chain.chainAsset
        chainImageView.kf.setImage(with: URL(string: item.imgUrl ?? ""), options: [.transition(.fade(0.4))])
        statusLabel.text = item.chainStatus.title()
        statusLabel.textColor = item.chainStatus.color()
        
        if let blockchainBadge = item.wallet?.badge {
            blockchainBadgeView.text = blockchainBadge
            blockchainBadgeView.isHidden = false
        } else {
            blockchainBadgeView.isHidden = true
        }
    }

}
