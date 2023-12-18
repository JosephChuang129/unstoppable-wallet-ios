import Foundation
import RxSwift
import RxCocoa

protocol BindingFormViewModelInputs {
    func start()
    func onSelect(country: AmlCountry)
    func onTapSend()
}

protocol BindingFormViewModelOutputs: AnyObject {
    var isLoading: ((Bool) -> Void)? { get set }
    var onErrorHandling: ((ErrorResult) -> Void)? { get set }
    var updateHandler: (() -> Void)? { get set }
    var cellPressed: (() -> Void)? { get set }
    var owlPayPrivacyPolicyCellPressed: ((String) -> Void)? { get set }
    var amlRegisteredSignal: Signal<()> { get }
    var loadingSignal: Signal<(Bool)> { get }
    var successSignal: Signal<String> { get }
    var errorSignal: Signal<String> { get }
    var amlValidateStatus: AmlValidateStatus { get }
    var action: BindingFormModule.Action { get }
    func numberOfSections() -> Int
    func numberOfItemsInSection(_ section: Int) -> Int
    func cellIdentifier(for viewModel: RowViewModel) -> String
    func getCellViewModel(at indexPath: IndexPath) -> RowViewModel
}

protocol BindingFormViewModelType {
    var inputs: BindingFormViewModelInputs { get }
    var outputs: BindingFormViewModelOutputs { get }
}

class BindingFormViewModel: BaseViewModel, BindingFormViewModelType, BindingFormViewModelInputs, BindingFormViewModelOutputs {
    
    public var inputs: BindingFormViewModelInputs { return self }
    public var outputs: BindingFormViewModelOutputs { return self }
    
    init(service: BindingFormService, action: BindingFormModule.Action) {
        self.service = service
        self.action = action
    }
    
    private let service: BindingFormService
    let action: BindingFormModule.Action
    private let disposeBag = DisposeBag()
    //MARK: Outputs
    
    var sectionRowViewModels: [SectionRowViewModel] = []
    private lazy var bindingFormCellViewModel = BindingFormCellViewModel(status: service.amlValidateStatus)
    private lazy var owlPayPrivacyPolicyCellViewModel = OwlPayPrivacyPolicyCellViewModel()
    private lazy var bindingChainSelectionCellViewModels = [BindingChainSelectionCellViewModel]()
    private lazy var sendButtonCellViewModel = Primary2ButtonCellViewModel()
    private let amlRegisteredRelay = PublishRelay<()>()
    
    var owlPayPrivacyPolicyCellPressed: ((String) -> Void)?
    
    var cellPressed: (() -> Void)?
    
    func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is BindingFormCellViewModel:
            return BindingFormCell.cellIdentifier()
        case is OwlPayPrivacyPolicyCellViewModel:
            return OwlPayPrivacyPolicyCell.cellIdentifier()
        case is BindingChainSelectionCellViewModel:
            return BindingChainSelectionCell.cellIdentifier()
        case is Primary2ButtonCellViewModel:
            return Primary2ButtonCell.cellIdentifier()
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> RowViewModel {
        let section = sectionRowViewModels[indexPath.section]
        let rowViewModel = section.rowViewModels[indexPath.item]
        return rowViewModel
    }
    
    func numberOfSections() -> Int {
        return sectionRowViewModels.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return sectionRowViewModels[section].rowViewModels.count
    }
}

extension BindingFormViewModel {
    
    //MARK: Inputs
    func start() {
        buildCellViewModels()
    }
}

extension BindingFormViewModel {
    
    private func buildCellViewModels() {
        
        addBindingForm()
        addOwlPayPrivacyPolicy()
        sectionRowViewModels.append(SectionRowViewModel(rowViewModels: [sendButtonCellViewModel]))
        
        updateHandler?()
    }
    
    private func addBindingForm() {
        
        bindingChainSelectionCellViewModels = service.activeItems.map { item in
            
            let rowViewModel = BindingChainSelectionCellViewModel(item: item)
            rowViewModel.outputs.syncState = { [weak self] in
                self?.syncState()
            }
            return rowViewModel
        }
        
        bindingFormCellViewModel.outputs.syncState = { [weak self] in
            self?.syncState()
        }
        
        sectionRowViewModels.append(SectionRowViewModel(rowViewModels: [bindingFormCellViewModel] + bindingChainSelectionCellViewModels))
    }
    
    private func addOwlPayPrivacyPolicy() {
        
        owlPayPrivacyPolicyCellViewModel.outputs.cellPressed = { [weak self] indexPath in
            
            guard let self = self else { return }
            self.owlPayPrivacyPolicyCellPressed?("https://www.owlting.com/owlpay/privacy?lang=\(self.service.langCode)")
        }
        
        owlPayPrivacyPolicyCellViewModel.outputs.syncState = { [weak self] in
            self?.syncState()
        }
        sectionRowViewModels.append(SectionRowViewModel(rowViewModels: [owlPayPrivacyPolicyCellViewModel]))
    }
}

extension BindingFormViewModel {
    
    private func syncState() {
        
        let selectedChainItems = bindingChainSelectionCellViewModels.filter { viewModel in
            viewModel.item.isSelected
        }
        
        let isOwlPayPrivacyPolicySelected = owlPayPrivacyPolicyCellViewModel.outputs.isSelected
        
        var isEnabled = false
        if let name = bindingFormCellViewModel.outputs.name, !name.isEmpty, let date = bindingFormCellViewModel.outputs.birthday, let selectedCountry = bindingFormCellViewModel.outputs.selectedAmlCountry, selectedChainItems.count > 0, isOwlPayPrivacyPolicySelected {
            isEnabled = true
        }
        sendButtonCellViewModel.isEnabled = isEnabled
    }
    
    func onSelect(country: AmlCountry) {
        bindingFormCellViewModel.selectedAmlCountry = country
        syncState()
    }
    
    func onTapSend() {
        
        switch service.amlValidateStatus {
            
        case .verified:
            amlChainBinding()
            
        case .unfinished:
            amlChainBinding()
            
        case .rejected:
            amlRegister()
            
        case .userNotFound:
            amlRegister()
            
        default: break
        }
    }
}

extension BindingFormViewModel {
    
    func amlRegister() {
        
        let selectedChainItems = bindingChainSelectionCellViewModels.filter { viewModel in
            viewModel.item.isSelected
        }
        
        guard let name = bindingFormCellViewModel.outputs.name, let date = bindingFormCellViewModel.outputs.birthday, let selectedCountry = bindingFormCellViewModel.outputs.selectedAmlCountry, selectedChainItems.count > 0 else {
            return
        }
        
        let chains = selectedChainItems.compactMap { viewModel in
            generateChain(item: viewModel.item)
        }
        
        var parameter = AmlRegisterRequest()
        parameter.name = name
        parameter.country = selectedCountry.isoCode
        parameter.birthday = DateHelper.instance.formatOTDate(from: date)
        parameter.chains = chains
        
        loadingRelay.accept(true)
        
        service.networkService.request(networkClient: .amlRegister(parameter: parameter.toJSON()))
            .subscribe(onNext: { [weak self] (response: AmlUserMetaResponse) in
                
                self?.amlRegisteredRelay.accept(())
                
            }, onError: { [weak self] error in
                
                self?.errorRelay.accept("alert.error.try_again_later".localized)
                
            }).disposed(by: disposeBag)
    }
    
    func amlChainBinding() {
        
        let selectedChainItems = bindingChainSelectionCellViewModels.filter { viewModel in
            viewModel.item.isSelected
        }
        
        guard selectedChainItems.count > 0 else {
            return
        }
        
        let chains = selectedChainItems.compactMap { viewModel in
            generateChain(item: viewModel.item)
        }
        
        let unBindingChains = service.unbindUserChains.filter { chain in
            !chains.contains(chain)
        }
        
        var parameter = AmlRegisterRequest()
        parameter.chains = chains + unBindingChains
        
        loadingRelay.accept(true)

        service.networkService.request(networkClient: .amlChainBinding(parameter: parameter.toJSON()))
            .subscribe(onNext: { [weak self] (response: AmlUserMetaResponse) in

                self?.amlRegisteredRelay.accept(())

            }, onError: { [weak self] error in

                self?.errorRelay.accept("alert.error.try_again_later".localized)

            }).disposed(by: disposeBag)
    }
    
    func generateChain(item: BindingFormService.Item) -> UserChain? {
        
        guard let adapter = App.shared.adapterManager.depositAdapter(for: item.wallet) else { return nil }
        
        let wallet = item.wallet
        var chain = UserChain()
        chain.address = adapter.receiveAddress.address
        chain.asset = wallet.token.coin.code
        chain.network = wallet.token.blockchain.name
        chain.isBinding = true
        
        return chain
    }
}

extension BindingFormViewModel {
    
    var amlRegisteredSignal: Signal<()> {
        amlRegisteredRelay.asSignal()
    }
    
    var amlValidateStatus: AmlValidateStatus {
        service.amlValidateStatus
    }
}
