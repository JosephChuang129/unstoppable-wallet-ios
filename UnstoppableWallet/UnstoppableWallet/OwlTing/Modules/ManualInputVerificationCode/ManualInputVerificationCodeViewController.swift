import UIKit
import ThemeKit
import RxSwift
import ComponentKit

class ManualInputVerificationCodeViewController: ThemeViewController {
    
    private let viewModel: ManualInputVerificationCodeViewModel
    
    private let disposeBag = DisposeBag()
    
    private lazy var bgScrollView = UIScrollView()
    private lazy var stackView = UIStackView()
    private lazy var confirmButton = Primary2Button()
    private lazy var backScanButton = Primary2Button()
    private lazy var accountStackView = TextFieldStackView()
    private lazy var accountWrapperView = UIView()
    
    init(viewModel: ManualInputVerificationCodeViewModel) {
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

extension ManualInputVerificationCodeViewController {
    private func viewSetup() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close_3_24"), style: .plain, target: self, action: #selector(onTapClose))
        
        confirmButton.addTarget(self, action: #selector(onTapConfirmButton), for: .touchUpInside)
        confirmButton.set(style: .yellow)
        confirmButton.setTitle("button.ok".localized, for: .normal)
        
        backScanButton.addTarget(self, action: #selector(onTapBackScanButton), for: .touchUpInside)
        backScanButton.set(style: .blackTitle)
        backScanButton.setTitle("QR Code 掃描", for: .normal)
        
        accountWrapperView.backgroundColor = .themeLawrence
        accountWrapperView.layer.cornerRadius = .cornerRadius8
        accountWrapperView.layer.cornerCurve = .continuous
        accountWrapperView.layer.borderWidth = .heightOneDp
        accountWrapperView.layer.borderColor = UIColor.themeSteel20.cgColor
        accountWrapperView.addSubview(accountStackView)
        accountStackView.placeholder = "輸入號碼"
        accountStackView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        [accountStackView].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(45)
            }
        }
        
        bgScrollView.contentInset = .init(top: 30, left: 0, bottom: 0, right: 0)
        view.addSubview(bgScrollView)
        bgScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bgScrollView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.leading.trailing.centerX.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview().inset(20)
        }

        stackView.axis = .vertical
        stackView.spacing = .margin8
//        stackView.alignment = .fill
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: .margin16, bottom: 0, right: .margin16)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        stackView.addArrangedSubview(accountWrapperView)
        stackView.addArrangedSubview(confirmButton)
        stackView.addArrangedSubview(backScanButton)
        
        stackView.setCustomSpacing(.margin32, after: accountWrapperView)
        stackView.setCustomSpacing(.margin32, after: confirmButton)
        
        syncButtonStates()
        accountStackView.onChangeText = { [weak self] text in
            self?.syncButtonStates()
        }
    }
    
    private func bindViewModel() {
        
        
    }
}

extension ManualInputVerificationCodeViewController {
    
    @objc private func onTapConfirmButton() {
        
    }
    
    @objc private func onTapBackScanButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func onTapClose() {
        dismiss(animated: true)
    }
    
    func syncButtonStates() {
            
        if let account = accountStackView.text, !account.isEmpty {
            confirmButton.isEnabled = true
        } else {
            confirmButton.isEnabled = false
        }
    }
}
