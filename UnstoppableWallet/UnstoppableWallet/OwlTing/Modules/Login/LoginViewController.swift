import UIKit
import ThemeKit
import RxSwift
import ComponentKit

class LoginViewController: ThemeViewController {
    
    private let viewModel: LoginViewModel
    
    private lazy var stackView = UIStackView()
    private lazy var loginButton = Primary2Button().then {
        $0.addTarget(self, action: #selector(onTapLoginButton), for: .touchUpInside)
        $0.set(style: .yellow)
        $0.setTitle("member.button.login".localized, for: .normal)
    }
    private lazy var passwordForgotButton = Primary2Button().then {
        $0.addTarget(self, action: #selector(onTapForgetPasswordButton), for: .touchUpInside)
        $0.set(style: .yellowTitle)
        $0.setTitle("member.button.forgetpassword".localized, for: .normal)
    }
    private lazy var emailStackView = TextFieldStackView().then {
        $0.backgroundColor = .themeLawrence
        $0.layer.cornerRadius = .cornerRadius8
        $0.layer.cornerCurve = .continuous
        $0.layer.borderWidth = .heightOneDp
        $0.layer.borderColor = UIColor.themeSteel20.cgColor
        $0.placeholder = "member.placeholder.email".localized
        $0.keyboardType = .emailAddress
    }
    private lazy var emailWaringLabel = UILabel().then {
        $0.text = "validator_errors.email".localized
        $0.textColor = .themeRedD
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.isHidden = true
        $0.numberOfLines = 0
    }
    
    private lazy var passwordStackView = TextFieldStackView().then {
        $0.backgroundColor = .themeLawrence
        $0.layer.cornerRadius = .cornerRadius8
        $0.layer.cornerCurve = .continuous
        $0.layer.borderWidth = .heightOneDp
        $0.layer.borderColor = UIColor.themeSteel20.cgColor
        $0.placeholder = "member.placeholder.password".localized
        $0.isSecureTextEntry = true
    }
    
    private lazy var scanButton = UIButton().then {
        $0.setImage(UIImage(named: "qr_scan_24"), for: .normal)
        $0.setTitle(" " + "member.button.scan".localized, for: .normal)
        $0.setTitleColor(.themeBran, for: .normal)
        $0.titleLabel?.font = .headline2
    }
    private lazy var registerButton = Primary2Button().then {
        $0.addTarget(self, action: #selector(onTapRegisterButton), for: .touchUpInside)
        $0.set(style: .yellowTitle)
        $0.setTitle("member.button.register".localized, for: .normal)

    }
    private lazy var logoImageView = UIImageView().then {
        $0.image = UIImage(named: "owlting_login_logo")
        $0.contentMode = .scaleAspectFit
    }
    private lazy var titleImageView = UIImageView().then {
        $0.image = UIImage(named: "owlting_login_title")?.withRenderingMode(.alwaysTemplate)
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .themeLeah
    }
    private lazy var bgScrollView = UIScrollView().then {
        $0.contentInset = .init(top: 30, left: 0, bottom: 0, right: 0)
    }
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: LoginViewModel) {
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
    
    func syncButtonStates() {
            
        if let email = emailStackView.text, !email.isEmpty, email.isValidEmail, let password = passwordStackView.text, !password.isEmpty {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
    }
    
    @objc private func onTapLoginButton() {
        view.endEditing(true)
        viewModel.login(email: emailStackView.text, password: passwordStackView.text)
    }
    
    @objc private func onTapForgetPasswordButton() {
        let nav = ThemeNavigationController(rootViewController: ForgotPasswordModule.viewController())
        present(nav, animated: true)
    }
    
    @objc private func onTapRegisterButton() {
        let nav = ThemeNavigationController(rootViewController: RegisterModule.viewController())
        present(nav, animated: true)
    }
    
    @objc private func onTapClose() {
        dismiss(animated: true)
    }
    
    deinit {
//        print("\(type(of: self)) \(#function)")
    }
}

extension LoginViewController {
    private func viewSetup() {
        
        title = "member.title".localized
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: scanButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close_3_24"), style: .plain, target: self, action: #selector(onTapClose))
        
        [emailStackView, passwordStackView].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(45)
            }
        }
        
        let logoHStackView = UIStackView(arrangedSubviews: [logoImageView, titleImageView])
        logoHStackView.axis = .horizontal
        logoHStackView.alignment = .bottom
        logoHStackView.spacing = .margin8
        
        let logoStackView = UIStackView(arrangedSubviews: [logoHStackView])
        logoStackView.axis = .vertical
        logoStackView.alignment = .center
        
        view.addSubview(bgScrollView)
        bgScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bgScrollView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.leading.trailing.centerX.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview().inset(50)
        }

        stackView.axis = .vertical
        stackView.spacing = .margin8
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: .margin16, bottom: 0, right: .margin16)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        stackView.addArrangedSubview(logoStackView)
        stackView.addArrangedSubview(emailStackView)
        stackView.addArrangedSubview(emailWaringLabel)
        stackView.addArrangedSubview(passwordStackView)
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(registerButton)
        stackView.addArrangedSubview(passwordForgotButton)
        
        stackView.setCustomSpacing(.margin32, after: logoStackView)
        stackView.setCustomSpacing(.margin6, after: loginButton)
        stackView.setCustomSpacing(.margin24, after: emailWaringLabel)
        stackView.setCustomSpacing(.margin24, after: passwordStackView)
        stackView.setCustomSpacing(.margin32, after: logoImageView)
        stackView.setCustomSpacing(0, after: registerButton)
        
        syncButtonStates()
    }
    
    private func bindViewModel() {
        
        emailStackView.onChangeText = { [weak self] text in
            self?.emailWaringLabel.isHidden = (text ?? "").isValidEmail
            self?.syncButtonStates()
        }
        
        passwordStackView.onChangeText = { [weak self] text in
            self?.syncButtonStates()
        }
        
        subscribe(disposeBag, viewModel.loadingSignal) {
            $0 ? HudHelper.instance.show(banner: .loading) : HudHelper.instance.hide()
        }
        
        subscribe(disposeBag, viewModel.successSignal) {
            HudHelper.instance.show(banner: .success(string: $0))
        }
        
        subscribe(disposeBag, viewModel.errorSignal) {
            HudHelper.instance.show(banner: .error(string: $0))
        }
        
        subscribe(disposeBag, viewModel.showBingFormSignal) { [weak self] in
            self?.navigationController?.pushViewController(BindingFormModule.viewController(action: .newRoot), animated: true)
        }
        
        subscribe(disposeBag, viewModel.tokenExpiredSignal) { [weak self] in
            HudHelper.instance.hide()
            self?.showTokenExpiredAlert()
        }
        
        scanButton.rx.tap.subscribe(onNext: { [weak self] in
            
            guard let self = self else { return }
            let nav = ThemeNavigationController(rootViewController: ScanVerificationCodeModule.viewController(delegate: self))
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
            
        }).disposed(by: disposeBag)
    }
}

extension LoginViewController: ScanVerificationCodeDelegate {
    
    func didScan(string: String) {
        viewModel.fetchScanLogin(qrcode: string)
    }
}

extension LoginViewController {
    
    func showTokenExpiredAlert() {
        let controller = UIAlertController(title: "owlpay_scan_token_expired".localized, message: nil, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "button.ok".localized, style: .cancel))
        present(controller, animated: true)
    }
}
