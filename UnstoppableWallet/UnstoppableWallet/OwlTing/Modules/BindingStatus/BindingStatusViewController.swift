import UIKit
import ThemeKit
import RxSwift
import ComponentKit

class BindingStatusViewController: ThemeViewController {
    
    let viewModel: BindingStatusViewModelType
    
    init(viewModel: BindingStatusViewModel) {
        self.viewModel = viewModel
        
        super.init()
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSetup()
        bindViewModel()
        viewModel.inputs.start()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
}

extension BindingStatusViewController {
    private func viewSetup() {
        
        title = "binding_status.title".localized
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.registerCell(forClass: BindingStatusCell.self)
        tableView.registerCell(forClass: BindingStatusActionCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func bindViewModel() {
        let inputs = viewModel.inputs
        let outputs = viewModel.outputs
        
        outputs.updateHandler = { [weak self] in
            self?.tableView.reloadData()
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
        
        subscribe(disposeBag, outputs.chainUnBindingSignal) {
            HudHelper.instance.hide()
            UIApplication.shared.windows.first { $0.isKeyWindow }?.set(newRootController: MainModule.instance(presetTab: .settings))
        }
    }
}


extension BindingStatusViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        
        if let cell = cell as? BindingStatusActionCell {
            cell.delegate = self
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

extension BindingStatusViewController: BindingStatusActionCellDelegate {
    
    func didTapUnbindButton() {

        guard viewModel.outputs.userChains.count > 0 else {
            return
        }
        let controller = UIAlertController(title: "binding_status.unbind_alert.title".localized, message: nil, preferredStyle: .alert)
        controller.addAction(
            UIAlertAction(title: "binding_status.unbind_button.title".localized, style: .destructive) { [weak self] action in
                self?.viewModel.inputs.amlChainUnBinding()
            }
        )
        controller.addAction(UIAlertAction(title: "binding_status.cancel_button.title".localized, style: .cancel))
        present(controller, animated: true)
    }
    
    func didTapRebindButton() {
        
        guard viewModel.outputs.activeWallets.count > 0 else {
            showNoWalletAlert()
            return
        }
        
        let controller = UIAlertController(title: "binding_status.rebind_alert.title".localized, message: "binding_status.rebind_alert.msg".localized, preferredStyle: .alert)
        controller.addAction(
            UIAlertAction(title: "button.ok".localized, style: .destructive) { [weak self] action in
                let nav = ThemeNavigationController(rootViewController: BindingFormModule.viewController())
                self?.present(nav, animated: true)
            }
        )
        controller.addAction(UIAlertAction(title: "binding_status.rebind_alert.back_button.title".localized, style: .cancel))
        present(controller, animated: true)
    }
    
    private func showNoWalletAlert() {
        
        let controller = UIAlertController(title: "no_wallet_alert.title".localized, message: "no_wallet_alert.msg".localized, preferredStyle: .alert)
        controller.addAction(
            UIAlertAction(title: "no_wallet_alert.button.confirm".localized, style: .destructive) { [weak self] action in
                UIApplication.shared.windows.first { $0.isKeyWindow }?.set(newRootController: MainModule.instance(presetTab: .balance))
            }
        )
        controller.addAction(UIAlertAction(title: "no_wallet_alert.button.cancel".localized, style: .cancel))
        self.present(controller, animated: true)
    }
}
