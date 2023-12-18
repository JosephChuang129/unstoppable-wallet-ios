import UIKit
import ComponentKit

enum GenderCategory: String {
    case female
    case male
    case unknown
    
    //0:unknown, 1:male, 2:female
    func fetchRowInt() -> Int {
        switch self {
        case .female: return 2
        case .male: return 1
        case .unknown: return 0
        }
    }

    static func fetchRaw(_ theEnum: GenderCategory) -> String {
        return theEnum.rawValue
    }
}


class RegisterInfoCell: BaseThemeCell {
    
    // MARK: ViewModel
    
    private static let horizontalPadding: CGFloat = .margin16
    private static let verticalPadding: CGFloat = .margin24
    
    private lazy var acountLabel = RequiredLabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
        $0.textColor = .themeLeah
        $0.setup(text: "register_display_name".localized)
    }
    
    private lazy var accountStackView = TextFieldStackView().then {
        $0.backgroundColor = .themeLawrence
        $0.layer.cornerRadius = .cornerRadius8
        $0.layer.cornerCurve = .continuous
        $0.layer.borderWidth = .heightOneDp
        $0.layer.borderColor = UIColor.themeSteel20.cgColor
        $0.placeholder = "register_display_name_hint".localized
    }
    
    private lazy var emailLabel = RequiredLabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
        $0.textColor = .themeLeah
        $0.setup(text: "register_email".localized)
    }
    
    private lazy var emailTextFieldStackView = TextFieldStackView().then {
        $0.backgroundColor = .themeLawrence
        $0.layer.cornerRadius = .cornerRadius8
        $0.layer.cornerCurve = .continuous
        $0.layer.borderWidth = .heightOneDp
        $0.layer.borderColor = UIColor.themeSteel20.cgColor
        $0.placeholder = "register_email_hint".localized
        $0.keyboardType = .emailAddress
    }
    
    private lazy var emailWaringLabel = UILabel().then {
        $0.text = "validator_errors.email".localized
        $0.textColor = .themeRedD
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.isHidden = true
        $0.numberOfLines = 0
    }
    
    private lazy var emailStackView = CommonVStackView(arrangedSubviews: [emailLabel, emailTextFieldStackView, emailWaringLabel], spacing: 10)
    
    private lazy var passwordLabel = RequiredLabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
        $0.textColor = .themeLeah
        $0.setup(text: "register_password".localized)
    }
    
    private lazy var passwordStackView = TextFieldStackView().then {
        $0.backgroundColor = .themeLawrence
        $0.layer.cornerRadius = .cornerRadius8
        $0.layer.cornerCurve = .continuous
        $0.layer.borderWidth = .heightOneDp
        $0.layer.borderColor = UIColor.themeSteel20.cgColor
        $0.placeholder = "register_password.hint".localized
        $0.isSecureTextEntry = true
    }
    
    private lazy var confirmPasswordStackView = TextFieldStackView().then {
        $0.backgroundColor = .themeLawrence
        $0.layer.cornerRadius = .cornerRadius8
        $0.layer.cornerCurve = .continuous
        $0.layer.borderWidth = .heightOneDp
        $0.layer.borderColor = UIColor.themeSteel20.cgColor
        $0.placeholder = "register_confirm_password.hint".localized
        $0.isSecureTextEntry = true
    }
    
    private lazy var passwordRemind = UILabel().then {
        $0.text = "register_password_rule".localized
        $0.textColor = .themeLeah
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
    }
    
    private lazy var passwordWaringLabel = UILabel().then {
        $0.text = "validator_errors.password".localized
        $0.textColor = .themeRedD
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.isHidden = true
        $0.numberOfLines = 0
    }
    
    private lazy var pwdStackView = CommonVStackView(arrangedSubviews: [passwordLabel, passwordStackView, confirmPasswordStackView, passwordRemind, passwordWaringLabel], spacing: 10)
    
    private lazy var birthdayLabel = RequiredLabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
        $0.textColor = .themeLeah
        $0.setup(text: "register_birth".localized)
    }
    
    private lazy var birthdayButton = UIButton().then {
        $0.setTitle("register_birth_hint".localized, for: .normal)
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
    
    private lazy var genderLabel = RequiredLabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
        $0.textColor = .themeLeah
        $0.setup(text: "register_gender".localized)
    }
    
    private lazy var maleButton = GenderRadioButton().then {
        $0.setTitle("  " + "register_gender_male".localized, for: .normal)
    }
    private lazy var femaleButton = GenderRadioButton().then {
        $0.setTitle("  " + "register_gender_female".localized, for: .normal)
    }
    private lazy var unknownGenderButton = GenderRadioButton().then {
        $0.setTitle("  " + "register_gender_unknown".localized, for: .normal)
    }
    
    private lazy var radioButtonController: RadioButtonsController = RadioButtonsController().then {
        $0.delegate = self
    }
    
    private lazy var genderRadioStackView = CommonVStackView(arrangedSubviews: [maleButton, femaleButton, unknownGenderButton], spacing: 10).then {
        $0.alignment = .leading
    }
    
    var birthdayDate = Date() - 18.years
    var maximumDate = Date() - 18.years
    var onChangeName: ((String?) -> ())?
    var onChangeEmail: ((String?) -> ())?
    var onChangePassword: ((String?) -> ())?
    var onChangeConfirmPassword: ((String?) -> ())?
    var onChangeBirthday: ((Date) -> ())?
    var onChangeGenderCategory: ((GenderCategory) -> ())?
    
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

extension RegisterInfoCell {
    
    private func viewSetup() {
        
        radioButtonController.addButton(maleButton)
        radioButtonController.addButton(femaleButton)
        radioButtonController.addButton(unknownGenderButton)
        
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        set(backgroundStyle: .lawrence, cornerRadius: 12, isFirst: true, isLast: true)
        wrapperView.backgroundColor = .themeLawrence
        
        let stackView = CommonVStackView(arrangedSubviews: [acountLabel, accountStackView, emailStackView, pwdStackView, birthdayLabel, birthdayButton, genderLabel, genderRadioStackView], spacing: 40).then {
            $0.setCustomSpacing(10, after: acountLabel)
            $0.setCustomSpacing(10, after: emailLabel)
            $0.setCustomSpacing(10, after: passwordLabel)
            $0.setCustomSpacing(10, after: birthdayLabel)
            $0.setCustomSpacing(10, after: genderLabel)
        }
        wrapperView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(RegisterInfoCell.verticalPadding)
            $0.leading.trailing.equalToSuperview().inset(RegisterInfoCell.horizontalPadding)
        }
        
        [accountStackView, emailTextFieldStackView, passwordStackView, confirmPasswordStackView, birthdayButton, genderLabel].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(45).priority(.required)
            }
        }
        
        accountStackView.onChangeText = { [weak self] text in
            self?.handleChange(name: text)
        }
        
        emailTextFieldStackView.onChangeText = { [weak self] text in
            self?.emailWaringLabel.isHidden = (text ?? "").isValidEmail
            self?.handleChange(email: text)
        }
        
        passwordStackView.onChangeText = { [weak self] text in
            self?.validPasswordInputs()
            self?.handleChange(password: text)
        }
        
        confirmPasswordStackView.onChangeText = { [weak self] text in
            self?.validPasswordInputs()
            self?.handleChange(confirmPassword: text)
        }
    }
    
    @objc private func onTapBirthdayButton() {

        contentView.endEditing(true)
        DatePickerPopupView.show(date: birthdayDate, maximumDate: maximumDate) { [weak self] date in

            if let date = date {
                self?.birthdayDate = date
                self?.birthdayButton.setTitle(DateHelper.instance.formatOTDate(from: date), for: .normal)
                self?.birthdayButton.setTitleColor(UIColor.themeLeah, for: .normal)
                self?.onChangeBirthday?(date)
            }
        }
    }
    
    private func handleChange(name: String?) {
        onChangeName?(name)
    }
    
    private func handleChange(email: String?) {
        onChangeEmail?(email)
    }
    
    private func handleChange(password: String?) {
        onChangePassword?(password)
    }
    
    private func handleChange(confirmPassword: String?) {
        onChangeConfirmPassword?(confirmPassword)
    }
}

extension RegisterInfoCell: RadioButtonControllerDelegate {
    func didSelectButton(selectedButton: UIButton) {
        
        switch selectedButton {
        case maleButton:
            onChangeGenderCategory?(.male)
            
        case femaleButton:
            onChangeGenderCategory?(.female)
            
        case unknownGenderButton:
            onChangeGenderCategory?(.unknown)
            
        default: break
        }
    }
}

extension RegisterInfoCell {
    
    private func validPasswordInputs() {
        
        let isPwCountMoreThanLimit = (passwordStackView.text?.count ?? 0 >= 8) && (confirmPasswordStackView.text?.count ?? 0 >= 8)
        let isPwInputsSame = passwordStackView.text == confirmPasswordStackView.text
        let passwordValid = (passwordStackView.text ?? "").passwordValid() && (confirmPasswordStackView.text ?? "").passwordValid()
        
        var string: [String] = []
        
        if !isPwCountMoreThanLimit || !passwordValid {
            string.append("validator_errors.password".localized)
        }
        
        if !isPwInputsSame {
            string.append("register_password.not_same_error".localized)
        }
        
        passwordWaringLabel.text = string.joined(separator: "，")
        passwordWaringLabel.isHidden = isPwCountMoreThanLimit && isPwInputsSame && passwordValid
    }
}
