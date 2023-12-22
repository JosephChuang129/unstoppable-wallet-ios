import Foundation
import UIKit
import ThemeKit
import MarketKit
import HsExtensions
import StorageKit
import BigInt

struct SendStellarConfirmationModule {

    static func viewController(stellarKitWrapper: StellarKitWrapper, sendData: StellarSendData, token: Token) -> UIViewController? {
        guard let coinServiceFactory = EvmCoinServiceFactory(
            blockchainType: stellarKitWrapper.blockchainType,
            marketKit: App.shared.marketKit,
            currencyKit: App.shared.currencyKit,
            coinManager: App.shared.coinManager
        ) else {
            return nil
        }
        
        let switchService = AmountTypeSwitchService(localStorage: StorageKit.LocalStorage.default)
        let feeFiatService = FiatService(switchService: switchService, currencyKit: App.shared.currencyKit, marketKit: App.shared.marketKit)
        let feeService = SendFeeService(fiatService: feeFiatService, feeToken: coinServiceFactory.baseCoinService.token)
        let feeViewModel = SendFeeViewModel(service: feeService)

        let service = SendStellarConfirmationService(sendData: sendData, stellarKitWrapper: stellarKitWrapper, feeService: feeService, evmLabelManager: App.shared.evmLabelManager, token: token)
        let contactLabelService = ContactLabelService(contactManager: App.shared.contactManager, blockchainType: .stellar)
        let viewModel = SendStellarConfirmationViewModel(service: service, coinServiceFactory: coinServiceFactory, evmLabelManager: App.shared.evmLabelManager, contactLabelService: contactLabelService)
        let controller = SendStellarConfirmationViewController(transactionViewModel: viewModel, feeViewModel: feeViewModel)

        return controller
    }

}
