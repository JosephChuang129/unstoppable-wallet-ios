import UIKit
import UIExtensions
import SnapKit
import ComponentKit
import RxSwift

class MainSettingsFooterCell: UITableViewCell {
    let cellHeight: CGFloat = 155
//    let cellHeight: CGFloat = 30
    
    let disposeBag = DisposeBag()
    private let versionLabel = UILabel()
    private lazy var loginButton = Primary2Button().then {
        $0.setTitle("main_settings.login_binding".localized, for: .normal)
//        $0.isHidden = true
    }
    
    private lazy var deleteAccountButton = UIButton().then {
        $0.setTitleColor(.themeGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        $0.setTitle("main_settings.delete_account".localized, for: .normal)
//        $0.isHidden = true
    }

    var onTapLogin: (() -> ())?
    var onTapLogout: (() -> ())?
    var onTapDeleteAccount: (() -> ())?

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none

        let stackView = CommonVStackView(arrangedSubviews: [loginButton, versionLabel], spacing: 30)
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(CGFloat.margin16)
        }
        
        contentView.addSubview(deleteAccountButton)
        deleteAccountButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(stackView.snp.bottom).offset(30)
        }
        
        versionLabel.textAlignment = .center
        versionLabel.textColor = .themeGray
        versionLabel.font = .caption
        
        let currentLoginState = App.shared.accountManager.currentLoginState
        let title = currentLoginState ? "main_settings.logout".localized : "main_settings.login_binding".localized
        loginButton.setTitle(title, for: .normal)
        loginButton.set(style: currentLoginState ? .blackBordered : .yellow)
        deleteAccountButton.isHidden = !currentLoginState
        
        loginButton.rx.tap.subscribe(onNext: { [weak self] in
            currentLoginState ? self?.onTapLogout?() : self?.onTapLogin?()
        }).disposed(by: disposeBag)
        
        deleteAccountButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.onTapDeleteAccount?()
        }).disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(appVersion: String) {
        versionLabel.text = "\(AppConfig.appName.uppercased()) \(appVersion)"
    }

}
