import UIKit
import ComponentKit
import RxSwift

protocol BindingFormCellDelegate: AnyObject {
    func didTapCountryButton()
}

class BindingFormCell: BaseThemeCell {
    
    // MARK: ViewModel
    var viewModel: BindingFormCellViewModelType?
    weak var delegate: BindingFormCellDelegate?
    
    private var disposeBag = DisposeBag()
    
    private static let horizontalPadding: CGFloat = .margin16
    private static let verticalPadding: CGFloat = .margin24
    
    private lazy var nameLabel = UILabel().then {
        $0.textColor = .themeLeah
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.numberOfLines = 0
    }
    
    private lazy var emailLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.numberOfLines = 0
    }
    
    private lazy var avatarImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.cornerRadius = 20
    }
    
    private lazy var userVStackView = CommonVStackView(arrangedSubviews: [nameLabel, emailLabel], spacing: 4)
    private lazy var userStackView = CommonHStackView(arrangedSubviews: [avatarImageView, userVStackView], spacing: 10)
    
    private lazy var waringStackView = WaringStackView().then {
        $0.titleLabel.text = "binding_form.reject_waring".localized
        $0.titleLabel.textColor = .themeRedD
        $0.titleLabel.numberOfLines = 0
        $0.warningImageView.image = UIImage(named: "warning_2_20")?.withTintColor(.themeRedD)
        $0.isHidden = true
    }
    
    private lazy var statusLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.numberOfLines = 0
        $0.textColor = .themeLeah
    }
    
    private lazy var nameStackView = TextFieldStackView().then {
        $0.backgroundColor = .themeLawrence
        $0.layer.cornerRadius = .cornerRadius8
        $0.layer.cornerCurve = .continuous
        $0.layer.borderWidth = .heightOneDp
        $0.layer.borderColor = UIColor.themeSteel20.cgColor
        $0.placeholder = "binding_form_kyc_name".localized
    }
    
    private lazy var countryButton = UIButton().then {
        $0.setTitle("binding_form_kyc_nationality".localized, for: .normal)
        $0.setTitleColor(UIColor.placeholderText, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.layer.cornerRadius = .cornerRadius8
        $0.layer.cornerCurve = .continuous
        $0.layer.borderWidth = .heightOneDp
        $0.layer.borderColor = UIColor.themeSteel20.cgColor
        $0.contentHorizontalAlignment = .leading
        $0.contentEdgeInsets = .init(top: 0, left: 15, bottom: 0, right: 15)
        $0.addTarget(self, action: #selector(onTapCountryButton), for: .touchUpInside)
    }
    
    private lazy var birthdayButton = UIButton().then {
        $0.setTitle("binding_form_kyc_birth".localized, for: .normal)
        $0.setTitleColor(UIColor.placeholderText, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.layer.cornerRadius = .cornerRadius8
        $0.layer.cornerCurve = .continuous
        $0.layer.borderWidth = .heightOneDp
        $0.layer.borderColor = UIColor.themeSteel20.cgColor
        $0.contentHorizontalAlignment = .leading
        $0.contentEdgeInsets = .init(top: 0, left: 15, bottom: 0, right: 15)
        $0.addTarget(self, action: #selector(onTapBirthdayButton), for: .touchUpInside)
    }
    
    private lazy var remindLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.numberOfLines = 0
        $0.textColor = .themeLeah
        $0.text = "binding_form_wallet_selection_title".localized
    }
    
    private lazy var evmTipStackView = WaringStackView().then {
        $0.titleLabel.text = "binding_form.evm_waring".localized
        $0.titleLabel.textColor = .themeYellowD
        $0.titleLabel.numberOfLines = 0
        $0.warningImageView.image = UIImage(named: "warning_2_20")?.withTintColor(.themeYellowD)
    }
    
    private lazy var maximumDate = Date() - 18.years
    
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
        avatarImageView.kf.cancelDownloadTask()
        disposeBag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    deinit {
//        Dprint("\(type(of: self)) \(#function)")
    }
}

extension BindingFormCell {
    
    private func viewSetup() {
        
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        set(backgroundStyle: .lawrence, cornerRadius: 12, isFirst: true, isLast: false)
        wrapperView.backgroundColor = .themeLawrence
        
        let stackView = CommonVStackView(arrangedSubviews: [userStackView, waringStackView, statusLabel, nameStackView, countryButton, birthdayButton, remindLabel, evmTipStackView], spacing: 5).then {
            $0.setCustomSpacing(40, after: userStackView)
            $0.setCustomSpacing(20, after: statusLabel)
            $0.setCustomSpacing(40, after: birthdayButton)
            $0.setCustomSpacing(20, after: waringStackView)
            $0.setCustomSpacing(20, after: remindLabel)
            $0.setCustomSpacing(20, after: evmTipStackView)
        }
        wrapperView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(BindingFormCell.verticalPadding)
            $0.leading.trailing.equalToSuperview().inset(BindingFormCell.horizontalPadding)
        }
        
        [nameStackView, countryButton, birthdayButton].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(45).priority(.high)
            }
        }
        
        avatarImageView.snp.makeConstraints {
            $0.width.height.equalTo(40)
        }
        
        nameStackView.onChangeText = { [weak self] text in
            self?.viewModel?.outputs.name = text
        }
    }
    
    @objc private func onTapBirthdayButton() {

        contentView.endEditing(true)
        
        guard let viewModel = viewModel else { return }
        
        DatePickerPopupView.show(date: viewModel.outputs.birthday ?? Date(), maximumDate: maximumDate) { [weak self] date in

            if let date = date {
                self?.viewModel?.outputs.birthday = date
                self?.birthdayButton.setTitle(DateHelper.instance.formatOTDate(from: date), for: .normal)
                self?.birthdayButton.setTitleColor(UIColor.themeLeah, for: .normal)
            }
        }
    }
    
    @objc private func onTapCountryButton() {
        
        contentView.endEditing(true)
        delegate?.didTapCountryButton()
    }
}

extension BindingFormCell: CellConfigurable {
    func bind(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? BindingFormCellViewModelType else { return }
        self.viewModel = viewModel
        
        let status = viewModel.outputs.status
        statusLabel.text = status.bindWording()
        waringStackView.isHidden = status != .rejected
        let customer = App.shared.accountManager.customer
        
        nameLabel.text = customer?.name
        emailLabel.text = customer?.email
        nameStackView.text = viewModel.outputs.name
        
        avatarImageView.kf.setImage(with: URL(string: customer?.avatar ?? ""), placeholder: UIImage(named: "owlting_login_logo"), options: [.transition(.fade(0.4))])
        if let date = viewModel.outputs.birthday {
            birthdayButton.setTitle(DateHelper.instance.formatOTDate(from: date), for: .normal)
            birthdayButton.setTitleColor(UIColor.themeLeah, for: .normal)
        }
        
        if let country = viewModel.outputs.selectedAmlCountry {
            countryButton.setTitle(country.name, for: .normal)
            countryButton.setTitleColor(.themeLeah, for: .normal)
        }
        
        if status == .verified || status == .unfinished {
            
            nameStackView.backgroundColor = .themeTyler
            birthdayButton.backgroundColor = .themeTyler
            countryButton.backgroundColor = .themeTyler
            
            nameStackView.isUserInteractionEnabled = false
            birthdayButton.isUserInteractionEnabled = false
            countryButton.isUserInteractionEnabled = false
            
        } else {
            
            nameStackView.backgroundColor = .clear
            birthdayButton.backgroundColor = .clear
            countryButton.backgroundColor = .clear
            
            nameStackView.isUserInteractionEnabled = true
            birthdayButton.isUserInteractionEnabled = true
            countryButton.isUserInteractionEnabled = true
        }
        
        subscribeToViewModel()
    }
    
    func subscribeToViewModel() {
        
        guard let viewModel = viewModel else { return }
        subscribe(disposeBag, viewModel.outputs.selectedAmlCountrySignal) { [weak self] country in
            
            self?.countryButton.setTitle(country.name, for: .normal)
            self?.countryButton.setTitleColor(.themeLeah, for: .normal)
        }
    }
}
