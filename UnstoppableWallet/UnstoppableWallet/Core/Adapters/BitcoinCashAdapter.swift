import BitcoinCashKit
import RxSwift

class BitcoinCashAdapter: BitcoinBaseAdapter {
    private let bitcoinCashKit: Kit

    init(wallet: Wallet, syncMode: SyncMode?, bitcoinCashCoinType: BitcoinCashCoinType?, testMode: Bool) throws {
        guard case let .mnemonic(words, _) = wallet.account.type, words.count == 12 else {
            throw AdapterError.unsupportedAccount
        }

        guard let walletSyncMode = syncMode else {
            throw AdapterError.wrongParameters
        }

        guard let bitcoinCashCoinType = bitcoinCashCoinType else {
            throw AdapterError.wrongParameters
        }

        let kitCoinType: BitcoinCashKit.CoinType

        switch bitcoinCashCoinType {
        case .type0: kitCoinType = .type0
        case .type145: kitCoinType = .type145
        }

        let networkType: Kit.NetworkType = testMode ? .testNet : .mainNet(coinType: kitCoinType)
        let logger = App.shared.logger.scoped(with: "BitcoinCashKit")

        bitcoinCashKit = try Kit(withWords: words, walletId: wallet.account.id, syncMode: BitcoinBaseAdapter.kitMode(from: walletSyncMode), networkType: networkType, confirmationsThreshold: BitcoinBaseAdapter.confirmationsThreshold, logger: logger)

        super.init(abstractKit: bitcoinCashKit)

        bitcoinCashKit.delegate = self
    }

}

extension BitcoinCashAdapter: ISendBitcoinAdapter {
}

extension BitcoinCashAdapter {

    static func clear(except excludedWalletIds: [String]) throws {
        try Kit.clear(exceptFor: excludedWalletIds)
    }

}
