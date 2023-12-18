import Foundation
import RxSwift
import RxCocoa

protocol BindingStatusViewModelInputs {
    func start()
    func amlChainUnBinding()
}

protocol BindingStatusViewModelOutputs: AnyObject {
    var isLoading: ((Bool) -> Void)? { get set }
    var onErrorHandling: ((ErrorResult) -> Void)? { get set }
    var updateHandler: (() -> Void)? { get set }
    var cellPressed: (() -> Void)? { get set }
    var activeWallets: [Wallet] { get }
    var userChains: [SSOUserChain] { get }
    var loadingSignal: Signal<(Bool)> { get }
    var successSignal: Signal<String> { get }
    var errorSignal: Signal<String> { get }
    var chainUnBindingSignal: Signal<()> { get }
    func numberOfSections() -> Int
    func numberOfItemsInSection(_ section: Int) -> Int
    func cellIdentifier(for viewModel: RowViewModel) -> String
    func getCellViewModel(at indexPath: IndexPath) -> RowViewModel
}

protocol BindingStatusViewModelType {
    var inputs: BindingStatusViewModelInputs { get }
    var outputs: BindingStatusViewModelOutputs { get }
}

class BindingStatusViewModel: BaseViewModel, BindingStatusViewModelType, BindingStatusViewModelInputs, BindingStatusViewModelOutputs {
    
    public var inputs: BindingStatusViewModelInputs { return self }
    public var outputs: BindingStatusViewModelOutputs { return self }
    
    init(service: BindingStatusService) {
        self.service = service
        
    }

    private let service: BindingStatusService
    private let disposeBag = DisposeBag()
    
    //MARK: Outputs
    private let chainUnBindingRelay = PublishRelay<()>()
    
    var sectionRowViewModels: [SectionRowViewModel] = []
    var cellPressed: (() -> Void)?
    
    func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is BindingStatusCellViewModel:
            return BindingStatusCell.cellIdentifier()
        case is BindingStatusActionCellViewModel:
            return BindingStatusActionCell.cellIdentifier()
            
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

extension BindingStatusViewModel {
    
    //MARK: Inputs
    func start() {
        buildCellViewModels()
    }
}

extension BindingStatusViewModel {

    private func buildCellViewModels() {
        
        sectionRowViewModels = []
        let viewModels = service.items.map { item in
            BindingStatusCellViewModel(item: item)
        }
        sectionRowViewModels.append(SectionRowViewModel(rowViewModels: viewModels))
        sectionRowViewModels.append(SectionRowViewModel(rowViewModels: [BindingStatusActionCellViewModel(canUnBinding: userChains.count > 0)]))

        updateHandler?()
    }
}

extension BindingStatusViewModel {
    
    func amlChainUnBinding() {

        let chains = userChains.compactMap { ssoUserChain in
            generateUserChain(ssoUserChain: ssoUserChain)
        }

        var parameter = AmlRegisterRequest()
        parameter.chains = chains

        loadingRelay.accept(true)

        service.networkService.request(networkClient: .amlChainBinding(parameter: parameter.toJSON()))
            .subscribe(onNext: { [weak self] (response: AmlUserMetaResponse) in

                self?.chainUnBindingRelay.accept(())

            }, onError: { [weak self] error in

                self?.errorRelay.accept("alert.error.try_again_later".localized)

            }).disposed(by: disposeBag)
    }
}


extension BindingStatusViewModel {
    
    var activeWallets: [Wallet] {
        service.activeWallets
    }
    
    var userChains: [SSOUserChain] {
        
        let chains = service.items.filter { item in
            item.chainStatus == .binding
        }.map { item in
            item.chain
        }
        
        return chains
    }
    
    func generateChain(wallet: Wallet) -> UserChain? {
        
        guard let adapter = App.shared.adapterManager.depositAdapter(for: wallet) else { return nil }
        
        var chain = UserChain()
        chain.address = adapter.receiveAddress.address
        chain.asset = wallet.token.coin.code
        chain.network = wallet.token.blockchain.name
        chain.isBinding = false
        
        return chain
    }
    
    func generateUserChain(ssoUserChain: SSOUserChain) -> UserChain? {
        
        var chain = UserChain()
        chain.address = ssoUserChain.chainAddress
        chain.asset = ssoUserChain.chainAsset
        chain.network = ssoUserChain.chainNetwork
        chain.isBinding = false
        
        return chain
    }
}

extension BindingStatusViewModel {
    
    var chainUnBindingSignal: Signal<()> {
        chainUnBindingRelay.asSignal()
    }
}
