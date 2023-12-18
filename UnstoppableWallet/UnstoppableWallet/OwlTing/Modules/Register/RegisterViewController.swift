import UIKit
import ThemeKit
import RxSwift
import ComponentKit

class RegisterViewController: ThemeViewController {
    
    private let viewModel: RegisterViewModel
    
    private let disposeBag = DisposeBag()
    private let urlManager: UrlManager
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    var sectionRowViews: [SectionRowView] = []
    
    private lazy var registerInfoCell = RegisterInfoCell()
    private lazy var privacyPolicyCell = PrivacyPolicyCell()
    private lazy var buttonCell = Primary2ButtonCell().then {
        $0.set(style: .yellow)
        $0.title = "register_button.title".localized
    }
    
    init(viewModel: RegisterViewModel, urlManager: UrlManager) {
        self.viewModel = viewModel
        self.urlManager = urlManager

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

extension RegisterViewController {
    private func viewSetup() {
        
        navigationItem.title = "register_title".localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close_3_24"), style: .plain, target: self, action: #selector(onTapClose))
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        tableView.registerCell(forClass: RegisterInfoCell.self)
        tableView.registerCell(forClass: PrivacyPolicyCell.self)
        tableView.registerCell(forClass: Primary2ButtonCell.self)
        
        tableView.dataSource = self
        tableView.delegate = self

        sectionRowViews.append(SectionRowView(rowViews: [registerInfoCell]))
        sectionRowViews.append(SectionRowView(rowViews: [privacyPolicyCell]))
        sectionRowViews.append(SectionRowView(rowViews: [buttonCell]))
        
        buttonCell.onTap = { [weak self] in
            self?.viewModel.register()
        }
        tableView.reloadData()
    }
    
    private func bindViewModel() {
        
        subscribe(disposeBag, viewModel.loadingSignal) {
            $0 ? HudHelper.instance.show(banner: .loading) : HudHelper.instance.hide()
        }
        
        subscribe(disposeBag, viewModel.successSignal) {
            HudHelper.instance.show(banner: .success(string: $0))
        }
        
        subscribe(disposeBag, viewModel.errorSignal) {
            HudHelper.instance.show(banner: .error(string: $0))
        }
        
        registerInfoCell.onChangeName = { [weak self] text in
            self?.viewModel.onChange(name: text)
        }
        
        registerInfoCell.onChangeEmail = { [weak self] email in
            
            UIView.performWithoutAnimation {
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            
            self?.viewModel.onChange(email: email)
        }
        
        subscribe(disposeBag, viewModel.showBingFormSignal) { [weak self] in
            self?.navigationController?.pushViewController(BindingFormModule.viewController(action: .newRoot), animated: true)
        }
        
        registerInfoCell.onChangePassword = { [weak self] pwd in
            
            UIView.performWithoutAnimation {
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            
            self?.viewModel.onChange(password: pwd)
        }
        
        registerInfoCell.onChangeConfirmPassword = { [weak self] pwd in
            
            UIView.performWithoutAnimation {
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            self?.viewModel.onChange(confirmPassword: pwd)
        }
        
        registerInfoCell.onChangeGenderCategory = { [weak self] genderCategory in
            self?.viewModel.onChange(gender: genderCategory)
        }
        
        registerInfoCell.onChangeBirthday = { [weak self] date in
            self?.viewModel.onChange(birthday: date)
        }
        
        privacyPolicyCell.onCheckButtonSelected = { [weak self] isSelected in
            self?.viewModel.onChange(isPrivacyPolicySelected: isSelected)
        }
        
        subscribe(disposeBag, viewModel.approveAllowedDriver) { [weak self] approveAllowed in
            self?.buttonCell.isEnabled = approveAllowed
        }
    }
}

extension RegisterViewController {
    
    @objc private func onTapConfirmButton() {
        view.endEditing(true)
    }
    
    @objc private func onTapClose() {
        dismiss(animated: true)
    }
    
    func cellIdentifier(for view: CellConfigurable) -> String {
        switch view {
        case is RegisterInfoCell:
            return RegisterInfoCell.cellIdentifier()
        case is PrivacyPolicyCell:
            return PrivacyPolicyCell.cellIdentifier()
        case is Primary2ButtonCell:
            return Primary2ButtonCell.cellIdentifier()
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }
}

extension RegisterViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        sectionRowViews.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionRowViews[section].rowViews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = sectionRowViews[indexPath.section]
        let cell = section.rowViews[indexPath.item]

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = sectionRowViews[indexPath.section]
        let cell = section.rowViews[indexPath.item]
        
        if cell == privacyPolicyCell {
            handlePrivacyPolicyCellTap()
        }
    }
}

extension RegisterViewController {
    
    private func handlePrivacyPolicyCellTap() {
        self.urlManager.open(url: viewModel.privacyPolicyUrl, from: self)
    }
}
