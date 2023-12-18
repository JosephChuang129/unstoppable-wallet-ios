import UIKit
import ThemeKit
import RxSwift
import ComponentKit

class BindingFormViewController: ThemeViewController {
    
    let viewModel: BindingFormViewModelType
    
    init(viewModel: BindingFormViewModel, urlManager: UrlManager) {
        self.viewModel = viewModel
        self.urlManager = urlManager
        
        super.init()
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let disposeBag = DisposeBag()
    private let urlManager: UrlManager
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
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
        
        if viewModel.outputs.action == .newRoot {
            UIApplication.shared.windows.first { $0.isKeyWindow }?.set(newRootController: MainModule.instance(presetTab: .settings))
        } else {
            dismiss(animated: true)
        }
    }
}

extension BindingFormViewController {
    private func viewSetup() {
        
        title = "binding_form.title".localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close_3_24"), style: .plain, target: self, action: #selector(onCancel))
        isModalInPresentation = true
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.registerCell(forClass: BindingFormCell.self)
        tableView.registerCell(forClass: OwlPayPrivacyPolicyCell.self)
        tableView.registerCell(forClass: BindingChainSelectionCell.self)
        tableView.registerCell(forClass: Primary2ButtonCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func bindViewModel() {
        let inputs = viewModel.inputs
        let outputs = viewModel.outputs
        
        outputs.updateHandler = { [weak self] in
            self?.tableView.reloadData()
        }
        
        outputs.owlPayPrivacyPolicyCellPressed = { [weak self] url in
            guard let self = self else { return }
            self.urlManager.open(url: url, from: self)
        }
        
        subscribe(disposeBag, outputs.loadingSignal) {
            $0 ? HudHelper.instance.show(banner: .loading) : HudHelper.instance.hide()
        }
        
        subscribe(disposeBag, outputs.successSignal) { [weak self] text in
            HudHelper.instance.hide()
        }
        
        subscribe(disposeBag, outputs.errorSignal) {
            HudHelper.instance.show(banner: .error(string: $0))
        }
        
        subscribe(disposeBag, outputs.amlRegisteredSignal) { [weak self] in
            HudHelper.instance.hide()
            self?.showRegisteredAlert()
        }
        
    }
}

extension BindingFormViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in _: UITableView) -> Int {
        return viewModel.outputs.numberOfSections()
    }
    
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.outputs.numberOfItemsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowViewModel = viewModel.outputs.getCellViewModel(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.outputs.cellIdentifier(for: rowViewModel), for: indexPath)
        
        if let cell = cell as? CellConfigurable {
            cell.bind(viewModel: rowViewModel)
        }
        
        if let cell = cell as? BindingFormCell {
            cell.delegate = self
        }
        
        if let cell = cell as? BindingChainSelectionCell {
            cell.set(backgroundStyle: .lawrence, isLast: tableView.indexPathForLastRow(inSection: indexPath.section) == indexPath)
        }
        
        if let cell = cell as? Primary2ButtonCell {
            cell.onTap = { [weak self] in
                self?.viewModel.inputs.onTapSend()
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let rowViewModel = viewModel.outputs.getCellViewModel(at: indexPath) as? ViewModelPressible {
            rowViewModel.cellPressed?(indexPath)
        }
    }
}

extension BindingFormViewController: BindingFormCellDelegate {
    func didTapCountryButton() {
        
        let nav = ThemeNavigationController(rootViewController: CountryListModule.viewController(delegate: self))
        present(nav, animated: true)
    }
}

extension BindingFormViewController: CountryListSelectDelegate {
    
    func didSelect(country: AmlCountry) {
        viewModel.inputs.onSelect(country: country)
    }
}

extension BindingFormViewController {
    
    func showRegisteredAlert() {
        
        let controller = UIAlertController(title: "binding_form.registered.alert.title".localized, message: "binding_form.registered.alert.msg".localized, preferredStyle: .alert)
        
        controller.addAction(
            UIAlertAction(title: "button.ok".localized, style: .default) { [weak self] action in
                UIApplication.shared.windows.first { $0.isKeyWindow }?.set(newRootController: MainModule.instance(presetTab: .settings))
            }
        )
        present(controller, animated: true)
    }
}
