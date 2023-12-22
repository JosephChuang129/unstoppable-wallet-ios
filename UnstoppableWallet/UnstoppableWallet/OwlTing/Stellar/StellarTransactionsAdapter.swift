import Foundation
import RxSwift
import BigInt
import HsToolKit
import MarketKit

class StellarTransactionsAdapter {
    static let decimal = 7

    let stellarKit: StellarKit
    let source: TransactionSource
    let transactionConverter: StellarTransactionConverter

    init(stellarKitWrapper: StellarKitWrapper, source: TransactionSource, baseToken: MarketKit.Token, coinManager: CoinManager, evmLabelManager: EvmLabelManager) {
        self.stellarKit = stellarKitWrapper.stellarKit
        self.source = source
        
        transactionConverter = StellarTransactionConverter(source: source, baseToken: baseToken, coinManager: coinManager, wrapper: stellarKitWrapper)
    }

    private func tagQuery(token: MarketKit.Token?, filter: TransactionTypeFilter) -> StellarTransactionTagQuery {
        var type: StellarTransactionTag.TagType?
        var `protocol`: StellarTransactionTag.TagProtocol?
        var contractAddress: String?

        if let token = token {
            switch token.type {
                case .native:
                    `protocol` = .native
            case .creditAlphanum4(let assetIssuer):
                contractAddress = assetIssuer
                `protocol` = .creditAlphanum4

                default: ()
            }
        }

        switch filter {
            case .all: ()
            case .incoming: type = .incoming
            case .outgoing: type = .outgoing
//            case .swap: type = .swap
//            case .approve: type = .approve
        }

        return StellarTransactionTagQuery(type: type, protocol: `protocol`, contractAddress: contractAddress)
    }

}

extension StellarTransactionsAdapter: ITransactionsAdapter {

    var lastBlockInfo: LastBlockInfo? {
        stellarKit.lastBlockHeight.map { LastBlockInfo(height: $0, timestamp: nil) }
    }

    var lastBlockUpdatedObservable: Observable<Void> {
        stellarKit.lastBlockHeightPublisher.asObservable().map { _ in () }
    }
    
    var syncing: Bool {
        stellarKit.syncState.syncing
    }

    var syncingObservable: Observable<()> {
        stellarKit.syncStatePublisher.asObservable().map { _ in () }
    }

    var explorerTitle: String {
        "Stellarscan"
    }

    func explorerUrl(transactionHash: String) -> String? {
        switch stellarKit.network {
        case .public: return "https://stellar.expert/explorer/public/tx/\((transactionHash))"
        case .testnet: return "https://stellar.expert/explorer/testnet/tx/\((transactionHash))"
        default: return ""
        }
    }

    func transactionsObservable(token: MarketKit.Token?, filter: TransactionTypeFilter) -> Observable<[TransactionRecord]> {
        stellarKit.transactionsPublisher(tagQueries: [tagQuery(token: token, filter: filter)]).asObservable().map { [weak self] in
            $0.compactMap { self?.transactionConverter.transactionRecord(fromTransaction: $0) }
        }
    }

    func transactionsSingle(from: TransactionRecord?, token: MarketKit.Token?, filter: TransactionTypeFilter, limit: Int) -> Single<[TransactionRecord]> {

        let transactions = stellarKit.transactions(tagQueries: [tagQuery(token: token, filter: filter)], fromHash: from.flatMap { $0.transactionHash }, limit: limit)
        return Single.just(transactions.compactMap { transactionConverter.transactionRecord(fromTransaction: $0) })
        
    }

    func rawTransaction(hash: String) -> String? {
        nil
    }
}
