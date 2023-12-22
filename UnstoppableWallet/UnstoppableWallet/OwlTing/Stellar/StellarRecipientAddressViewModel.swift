
import RxSwift

class StellarRecipientAddressViewModel: RecipientAddressViewModel {
    private let disposeBag = DisposeBag()
    private let sendService: SendStellarService
    
    init(service: AddressService, handlerDelegate: IRecipientAddressService?, sendService: SendStellarService) {
        self.sendService = sendService
        super.init(service: service, handlerDelegate: handlerDelegate)
        
        subscribe(disposeBag, sendService.activeAddressObservable) { [weak self] in self?.handle(active: $0) }
    }
    
    private func handle(active: Bool) {
        if active {
            cautionRelay.accept(nil)
        } else {
            cautionRelay.accept(Caution(text: "stellar.send.inactive_address".localized, type: .warning))
        }
    }
    
    override func sync(state: AddressService.State? = nil, customError: Error? = nil) {
        super.sync(state: state, customError: customError)
        
        //        if case let .success(address) = state {
        //            sendService.sync(address: address.raw)
        //        }
    }
    
}
