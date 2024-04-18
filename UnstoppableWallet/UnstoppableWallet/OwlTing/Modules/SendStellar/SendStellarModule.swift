
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

