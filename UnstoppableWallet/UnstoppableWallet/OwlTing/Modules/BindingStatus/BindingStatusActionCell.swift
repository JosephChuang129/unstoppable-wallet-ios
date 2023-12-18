import Foundation
import UIKit

protocol BindingStatusActionCellDelegate: AnyObject {
    func didTapUnbindButton()
    func didTapRebindButton()
}

class BindingStatusActionCell: UITableViewCell {
    
    // MARK: ViewModel
    var viewModel: BindingStatusActionCellViewModelType?
    weak var delegate: BindingStatusActionCellDelegate?
    
    lazy var unbindButton = Primary2Button().then {
        $0.setTitle("binding_status.unbind_button.title".localized, for: .normal)
        $0.set(style: .blackBordered)
        $0.addTarget(self, action: #selector(onTapUnbindButton), for: .touchUpInside)
    }
    
    private lazy var rebindButton = UIButton().then {
        $0.setTitleColor(.themeYellowD, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.setTitle("binding_status.rebind_button.title".localized, for: .normal)
        $0.contentHorizontalAlignment = .center
        $0.addTarget(self, action: #selector(onTapRebindButton), for: .touchUpInside)
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

extension BindingStatusActionCell {
    private func viewSetup() {
        
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        let stackView = CommonVStackView(arrangedSubviews: [rebindButton, unbindButton], spacing: 30)
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
}

extension BindingStatusActionCell: CellConfigurable {
    func bind(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? BindingStatusActionCellViewModelType else { return }
        self.viewModel = viewModel
        
        unbindButton.isEnabled = viewModel.outputs.canUnBinding
    }
}

extension BindingStatusActionCell {
    
    @objc private func onTapUnbindButton() {
        delegate?.didTapUnbindButton()
    }
    
    @objc private func onTapRebindButton() {
        delegate?.didTapRebindButton()
    }
}
