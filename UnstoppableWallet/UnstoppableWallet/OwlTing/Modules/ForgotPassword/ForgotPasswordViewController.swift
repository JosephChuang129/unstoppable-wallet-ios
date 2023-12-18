import UIKit
import ThemeKit
import RxSwift
import ComponentKit

class ForgotPasswordViewController: ThemeViewController {
    
    private let viewModel: ForgotPasswordViewModel
    
    private let disposeBag = DisposeBag()
    
    private lazy var bgScrollView = UIScrollView().then {
        $0.contentInset = .init(top: 30, left: 0, bottom: 0, right: 0)
    }
    
    private lazy var confirmButton = Primary2Button().then {
        $0.addTarget(self, action: #selector(onTapConfirmButton), for: .touchUpInside)
        $0.set(style: .yellow)
        $0.setTitle("forgeot_password_send_button".localized, for: .normal)
    }
    
    private lazy var emailStackView = TextFieldStackView().then {
        $0.backgroundColor = .themeLawrence
        $0.layer.cornerRadius = .cornerRadius8
        $0.layer.cornerCurve = .continuous
        $0.layer.borderWidth = .heightOneDp
        $0.layer.borderColor = UIColor.themeSteel20.cgColor
        $0.placeholder = "forgeot_password_email_hint".localized
        $0.keyboardType = .emailAddress
    }
    
    private lazy var noteEmailLabel = UILabel().then {
        $0.text = "forgeot_password_email_note".localized
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.numberOfLines = 0
    }
    
    private lazy var emailTitleLabel = RequiredLabel().then {
        $0.setup(text: "forgeot_password_email".localized)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
    }
    
    private lazy var emailWaringLabel = UILabel().then {
        $0.text = "validator_errors.email".localized
        $0.textColor = .themeRedD
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.isHidden = true
        $0.numberOfLines = 0
    }
    
    private lazy var wrapperView = BorderedView().then {
        $0.cornerRadius = 12
        $0.backgroundColor = .themeLawrence
        $0.borderColor = .clear
    }
    
    
    init(viewModel: ForgotPasswordViewModel) {
        self.viewModel = viewModel

        super.init()
        
        hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        bindViewModel()
        viewModel.start()
    }
    
    
    deinit {
//        print("\(type(of: self)) \(#function)")
    }
}

extension ForgotPasswordViewController {
    private func viewSetup() {
        
        navigationItem.title = "forgot_password.title".localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close_3_24"), style: .plain, target: self, action: #selector(onTapClose))
        
        let stackView = CommonVStackView(arrangedSubviews: [wrapperView, confirmButton], spacing: .margin8).then {
            $0.layoutMargins = UIEdgeInsets(top: 0, left: .margin16, bottom: 0, right: .margin16)
            $0.isLayoutMarginsRelativeArrangement = true
            $0.setCustomSpacing(.margin32, after: wrapperView)
        }
        
        let containerStackView = CommonVStackView(arrangedSubviews: [noteEmailLabel, emailTitleLabel, emailStackView, emailWaringLabel], spacing: 10).then {
            $0.setCustomSpacing(20, after: noteEmailLabel)
        }
        
        wrapperView.addSubview(containerStackView)
        containerStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.bottom.equalToSuperview().inset(20)
        }
        
        view.addSubview(bgScrollView)
        bgScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bgScrollView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.leading.trailing.centerX.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview().inset(20)
        }
        
        [emailStackView].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(45)
            }
        }
        
        syncButtonStates()
        emailStackView.onChangeText = { [weak self] text in
            self?.emailWaringLabel.isHidden = (text ?? "").isValidEmail
            self?.syncButtonStates()
        }
    }
    
    private func bindViewModel() {
        
        subscribe(disposeBag, viewModel.loadingSignal) {
            $0 ? HudHelper.instance.show(banner: .loading) : HudHelper.instance.hide()
        }
        
        subscribe(disposeBag, viewModel.successSignal) { [weak self] text in
            HudHelper.instance.hide()
            self?.showSendEmailSuccessAlert()
        }
        
        subscribe(disposeBag, viewModel.errorSignal) {
            HudHelper.instance.show(banner: .error(string: $0))
        }
    }
}

extension ForgotPasswordViewController {
    
    @objc private func onTapConfirmButton() {
        view.endEditing(true)
        viewModel.passwordForgot(email: emailStackView.text)
    }
    
    @objc private func onTapClose() {
        dismiss(animated: true)
    }
    
    func syncButtonStates() {
            
        if let account = emailStackView.text, !account.isEmpty, account.isValidEmail {
            confirmButton.isEnabled = true
        } else {
            confirmButton.isEnabled = false
        }
    }
    
    private func showSendEmailSuccessAlert() {
        
        let controller = UIAlertController(title: "reset_password_success.title".localized, message: "reset_password_success.msg".localized, preferredStyle: .alert)
        controller.view.tintColor = .themeYellowD
        controller.addAction(
            UIAlertAction(title: "button.ok".localized, style: .default) { [weak self] action in
                self?.dismiss(animated: true)
            }
        )
        present(controller, animated: true)
    }
}
