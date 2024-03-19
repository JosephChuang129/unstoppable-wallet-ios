
import UIKit
import ThemeKit
import MarketKit
import StorageKit

class SendStellarModule {

    static func viewController(token: Token, mode: SendBaseService.Mode, adapter: StellarAdapter) -> UIViewController {
        let stellarAddressParser = StellarAddressParser(stellarAdapter: adapter)
        let addressParserChain = AddressParserChain().append(handler: stellarAddressParser)

        let addressService = AddressService(
            mode: .parsers(AddressParserFactory.parser(blockchainType: .stellar), addressParserChain),
            marketKit: App.shared.marketKit,
            contactBookManager: App.shared.contactManager,
            blockchainType: .stellar
        )
        
        let service = SendStellarService(token: token, mode: mode, adapter: adapter, addressService: addressService)
        let switchService = AmountTypeSwitchService(localStorage: StorageKit.LocalStorage.default)
        let fiatService = FiatService(switchService: switchService, currencyKit: App.shared.currencyKit, marketKit: App.shared.marketKit)

        switchService.add(toggleAllowedObservable: fiatService.toggleAvailableObservable)

        let coinService = CoinService(token: token, currencyKit: App.shared.currencyKit, marketKit: App.shared.marketKit)

        let viewModel = SendStellarViewModel(service: service)
        let availableBalanceViewModel = SendAvailableBalanceViewModel(service: service, coinService: coinService, switchService: switchService)

        let amountViewModel = AmountInputViewModel(
            service: service,
            fiatService: fiatService,
            switchService: switchService,
            decimalParser: AmountDecimalParser()
        )
        addressService.amountPublishService = amountViewModel

        let recipientViewModel = StellarRecipientAddressViewModel(service: addressService, handlerDelegate: nil, sendService: service)

        let viewController = SendStellarViewController(
            stellarKitWrapper: adapter.stellarKitWrapper,
            viewModel: viewModel,
            availableBalanceViewModel: availableBalanceViewModel,
            amountViewModel: amountViewModel,
            recipientViewModel: recipientViewModel
        )
        
        return viewController
    }

}


import MarketKit
import RxSwift
import RxRelay
import TronKit
import stellarsdk
import BigInt
import HsExtensions

class SendStellarService {
    let sendToken: Token
    let mode: SendBaseService.Mode

    private let disposeBag = DisposeBag()
    private let adapter: StellarAdapter
    private let addressService: AddressService

    private let stateRelay = PublishRelay<State>()
    private(set) var state: State = .notReady {
        didSet {
            stateRelay.accept(state)
        }
    }

    private var stellarAmount: BigUInt?
    private var addressData: AddressData?

    private let amountCautionRelay = PublishRelay<(error: Error?, warning: AmountWarning?)>()
    private var amountCaution: (error: Error?, warning: AmountWarning?) = (error: nil, warning: nil) {
        didSet {
            amountCautionRelay.accept(amountCaution)
        }
    }

    private let addressErrorRelay = PublishRelay<Error?>()
    private var addressError: Error? = nil {
        didSet {
            addressErrorRelay.accept(addressError)
        }
    }

    private let activeAddressRelay = PublishRelay<Bool>()

    init(token: Token, mode: SendBaseService.Mode, adapter: StellarAdapter, addressService: AddressService) {
        sendToken = token
        self.mode = mode
        self.adapter = adapter
        self.addressService = addressService

        switch mode {
        case .predefined(let address): addressService.set(text: address)
        case .send: ()
        }
        
        subscribe(disposeBag, addressService.stateObservable) { [weak self] in self?.sync(addressState: $0) }
    }

    private func sync(addressState: AddressService.State) {
        
        switch addressState {
            case .success(let address):
            addressData = AddressData(stellarAddress: Address(raw: address.raw), domain: address.domain)
            default: addressData = nil
        }

        syncState()
    }

    private func syncState() {
        
        if amountCaution.error == nil, case .success = addressService.state, let stellarAmount = stellarAmount, let addressData = addressData {
            let sendData = StellarSendData(to: addressData.stellarAddress.raw, value: Int(stellarAmount))
            state = .ready(sendData: sendData)
        } else {
            state = .notReady
        }
    }

    private func validStellarAmount(amount: Decimal) throws -> BigUInt {
        guard let stellarAmount = BigUInt(amount.hs.roundedString(decimal: sendToken.decimals)) else {
            throw AmountError.invalidDecimal
        }

        guard amount <= adapter.balanceData.available else {
            throw AmountError.insufficientBalance
        }

        return stellarAmount
    }
}

extension SendStellarService {

    var stateObservable: Observable<State> {
        stateRelay.asObservable()
    }

    var amountCautionObservable: Observable<(error: Error?, warning: AmountWarning?)> {
        amountCautionRelay.asObservable()
    }

    var addressErrorObservable: Observable<Error?> {
        addressErrorRelay.asObservable()
    }

    var activeAddressObservable: Observable<Bool> {
        activeAddressRelay.asObservable()
    }

}

extension SendStellarService: IAvailableBalanceService {

    var availableBalance: DataStatus<Decimal> {
        .completed(adapter.balanceData.available)
    }

    var availableBalanceObservable: Observable<DataStatus<Decimal>> {
        Observable.just(availableBalance)
    }

}

extension SendStellarService: IAmountInputService {

    var amount: Decimal {
        0
    }

    var token: Token? {
        sendToken
    }

    var balance: Decimal? {
        adapter.balanceData.available
    }

    var amountObservable: Observable<Decimal> {
        .empty()
    }

    var tokenObservable: Observable<Token?> {
        .empty()
    }

    var balanceObservable: Observable<Decimal?> {
        .just(adapter.balanceData.available)
    }

    func onChange(amount: Decimal) {
        if amount > 0 {
            do {
                stellarAmount = try validStellarAmount(amount: amount)

                var amountWarning: AmountWarning? = nil
                if amount.isEqual(to: adapter.balanceData.available) {
                    switch sendToken.type {
                        case .native: amountWarning = AmountWarning.coinNeededForFee
                        default: ()
                    }
                }

                amountCaution = (error: nil, warning: amountWarning)
            } catch {
                stellarAmount = nil
                amountCaution = (error: error, warning: nil)
            }
        } else {
            stellarAmount = nil
            amountCaution = (error: nil, warning: nil)
        }

        syncState()
    }

    func sync(address: String) {

//        guard address != adapter.stellarKitWrapper.stellarKit.keyPair.accountId else {
//            state = .notReady
//            addressError = AddressError.ownAddress
//            return
//        }
        Single<Bool>
            .create { [weak self] observer in
                let task = Task { [weak self] in
                    self?.adapter.accountActive(address: address, completion: { result in
                        observer(.success(result))
                    })
                }

                return Disposables.create {
                    task.cancel()
                }
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onSuccess: { [weak self] active in
                self?.activeAddressRelay.accept(active)
            })
            .disposed(by: disposeBag)
    }

}

extension SendStellarService {

    enum State {
        case ready(sendData: StellarSendData)
        case notReady
    }

    enum AmountError: Error {
        case invalidDecimal
        case insufficientBalance
    }

    enum AddressError: Error {
        case ownAddress
    }

    enum AmountWarning {
        case coinNeededForFee
    }

    private struct AddressData {
        let stellarAddress: Address
        let domain: String?
    }

}

