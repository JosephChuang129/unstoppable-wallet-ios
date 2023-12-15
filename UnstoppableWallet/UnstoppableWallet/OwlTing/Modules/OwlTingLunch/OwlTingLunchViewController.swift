import UIKit
import ThemeKit
import RxSwift
import ComponentKit

class OwlTingLunchViewController: ThemeViewController {
    
    let viewModel: OwlTingLunchViewModelType
    
    init(viewModel: OwlTingLunchViewModel, urlManager: UrlManager) {
        self.viewModel = viewModel
        self.urlManager = urlManager
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let urlManager: UrlManager
    
    private lazy var startButton = Primary2Button().then {
        $0.setTitle("owlTing_lunch.agree_button".localized, for: .normal)
        $0.set(style: .yellow)
        $0.addTarget(self, action: #selector(onTapStart), for: .touchUpInside)
        $0.isEnabled = false
    }

    private lazy var agreementLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
        $0.textColor = .themeLeah
    }
    
    private lazy var agreementButton = UIButton().then {
        $0.addTarget(self, action: #selector(onTapAgreement), for: .touchUpInside)
        $0.setTitleColor(.themeLeah, for: .normal)
        $0.titleLabel?.numberOfLines = 0
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.contentHorizontalAlignment = .leading
    }
    
    private lazy var checkButton = UIButton().then {
        $0.setImage(UIImage(named: "checkbox_active_24"), for: .selected)
        $0.setImage(UIImage(named: "checkbox_diactive_24"), for: .normal)
        $0.addTarget(self, action: #selector(onTapCheckButton), for: .touchUpInside)
        $0.tintColor = .themeLeah
        $0.touchEdgeInsets = .init(top: -20, left: -20, bottom: -20, right: -20)
    }
    
    private lazy var logoImageView = UIImageView().then {
        $0.image = UIImage(named: "lunch_logo")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var mapImageView = UIImageView().then {
        $0.image = UIImage(named: "lunch_map")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var agreementStackView = CommonVStackView(arrangedSubviews: [CommonHStackView(arrangedSubviews: [checkButton, agreementButton], spacing: 15)]).then {
        $0.alignment = .center
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.text = "owlTing_lunch.welcome".localized
        $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        $0.numberOfLines = 0
        $0.textColor = .themeLeah
        $0.textAlignment = .center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSetup()
        bindViewModel()
        viewModel.inputs.start()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    @objc func onCancel() {
        dismiss(animated: true)
    }
    
    @objc private func onTapStart() {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.set(newRootController: MainModule.instance())
    }
    
    @objc private func onTapAgreement() {
        urlManager.open(url: viewModel.outputs.agreementUrl, from: self)
    }
    
    @objc private func onTapCheckButton() {
        let isSelected = !checkButton.isSelected
        checkButton.isSelected = isSelected
        startButton.isEnabled = isSelected
    }
}

extension OwlTingLunchViewController {
    private func viewSetup() {
        
        view.addSubview(mapImageView)
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(135)
            $0.centerX.equalToSuperview()
        }
        
        mapImageView.snp.makeConstraints {
            $0.center.equalTo(logoImageView)
        }
        
        let stackView = CommonVStackView(arrangedSubviews: [titleLabel, agreementStackView, startButton], spacing: 35)
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(CGFloat.margin32)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(CGFloat.margin32)
        }
        
        agreementButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        checkButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let countText = "owlTing_lunch.terms_of_use".localized
        let remindText = "owlTing_lunch_terms_of_use_agreement".localized
        let textRange = (remindText as NSString).range(of: countText)
        let attrString = NSMutableAttributedString(string: remindText)
        attrString.addAttributes([.foregroundColor: UIColor.themeYellowD.cgColor, .font: UIFont.systemFont(ofSize: 14, weight: .medium)], range: textRange)
        agreementButton.setAttributedTitle(attrString, for: .normal)
    }
    
    private func bindViewModel() {
        let inputs = viewModel.inputs
        let outputs = viewModel.outputs
        
        
    }
}
