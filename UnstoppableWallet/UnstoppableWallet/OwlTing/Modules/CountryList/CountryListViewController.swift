import UIKit
import ThemeKit
import RxSwift
import ComponentKit
import Combine

class CountryListViewController: ThemeSearchViewController {
    
    let viewModel: CountryListViewModelType
    private weak var delegate: CountryListSelectDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: CountryListViewModel, delegate: CountryListSelectDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        
        super.init(scrollViews: [tableView])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        dismiss(animated: true)
    }
}

extension CountryListViewController {
    private func viewSetup() {
        
        title = "nationality_list.title".localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close_3_24"), style: .plain, target: self, action: #selector(onCancel))
        navigationItem.searchController?.searchBar.placeholder = "nationality_list.search.hint".localized
        navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.registerCell(forClass: CountryListCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func bindViewModel() {
        let inputs = viewModel.inputs
        let outputs = viewModel.outputs
        
        outputs.updateHandler = { [weak self] in
            self?.tableView.reloadData()
        }
        
        outputs.countryListCellPressed = { [weak self] country in
            self?.delegate?.didSelect(country: country)
            self?.dismiss(animated: true)
        }
        
        $filter
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.viewModel.inputs.apply(filter: $0) }
                .store(in: &cancellables)
    }
}

extension CountryListViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        
        if let cell = cell as? CountryListCell {
            cell.set(backgroundStyle: .lawrence, isFirst: indexPath.row == 0, isLast: tableView.indexPathForLastRow(inSection: indexPath.section) == indexPath)
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
