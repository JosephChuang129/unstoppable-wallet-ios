
import Foundation
import stellarsdk
import RxSwift
import HsExtensions
import MarketKit

class StellarSyncer {
    private var tasks = Set<AnyTask>()

    private let transactionManager: StellarTransactionManager
    private let syncTimer: StellarSyncTimer
    private let stellarKitProvider: StellarKitProvider
    private let storage: StellarSyncerStorage
    private var syncing: Bool = false
    private let disposeBag = DisposeBag()

    @DistinctPublished private(set) var state: StellarKit.SyncState = .notSynced(error: StellarKit.SyncError.notStarted)
    @DistinctPublished private(set) var lastBlockHeight: Int = 0

    init(syncTimer: StellarSyncTimer, transactionManager: StellarTransactionManager, stellarKitProvider: StellarKitProvider, storage: StellarSyncerStorage) {
        self.syncTimer = syncTimer
        self.stellarKitProvider = stellarKitProvider
        self.transactionManager = transactionManager
        self.storage = storage
        
        syncTimer.delegate = self
        lastBlockHeight = storage.lastBlockHeight ?? 0
        
        stellarKitProvider.transactionRecordsSubject.subscribe(onNext: { [weak self] transactionResponses in
            self?.transactionManager.save(transactionResponses: transactionResponses)
            self?.saveLastBlockHeight(transactionResponses: transactionResponses)
        }).disposed(by: disposeBag)
        
        stellarKitProvider.operationRecordsSubject.subscribe(onNext: { [weak self] operationResponses in
            self?.transactionManager.save(operationResponses: operationResponses)
        }).disposed(by: disposeBag)
        
        stellarKitProvider.accountStatusSubject.subscribe(onNext: { [weak self] status in
            let state: StellarKit.SyncState = status ? .synced : .notSynced(error: StellarKit.SyncError.notStarted)
            self?.set(state: state)
        }).disposed(by: disposeBag)
    }

    private func syncChainParameters() {
//        Task { [chainParameterManager] in
//            try await chainParameterManager.sync()
//        }
    }

    private func set(state: StellarKit.SyncState) {
        self.state = state

        if case .syncing = state {} else {
            syncing = false
        }
    }

    private func saveLastBlockHeight(transactionResponses: [TransactionResponse]) {
        if let ledger = transactionResponses.first?.ledger {
            lastBlockHeight = ledger
            storage.save(lastBlockHeight: ledger)
        }
    }
}

extension StellarSyncer {

    func start() {
        syncChainParameters()
        syncTimer.start()
    }

    func stop() {
        syncTimer.stop()
    }

    func refresh() {
        switch syncTimer.state {
        case .ready:
            sync()
        case .notReady:
            syncTimer.start()
        }
    }

}

extension StellarSyncer: IStellarSyncTimerDelegate {
    
    func didUpdate(state: StellarSyncTimer.State) {
        switch state {
        case .ready:
            set(state: .syncing(progress: nil))
            sync()
        case .notReady(let error):
            tasks = Set()
            set(state: .notSynced(error: error))
        }
    }

    func sync() {

        stellarKitProvider.fetchAccountDetails()
        stellarKitProvider.fetchTransactions()
        stellarKitProvider.fetchOperations()
    }
//    func sync() {
//        Task { [weak self, lastBlockHeight, tronGridProvider, address, storage] in
//            do {
//                guard let syncer = self, !syncer.syncing else {
//                    return
//                }
//                syncer.syncing = true
//
//                let address = address.base58
//                let newLastBlockHeight = try await tronGridProvider.fetch(rpc: BlockNumberJsonRpc())
//
//                guard newLastBlockHeight != lastBlockHeight else {
//                    self?.set(state: .synced)
//                    return
//                }
//                storage.save(lastBlockHeight: newLastBlockHeight)
//                self?.lastBlockHeight = newLastBlockHeight
//
//                let response = try await tronGridProvider.fetchAccountInfo(address: address)
//                self?.accountInfoManager.handle(accountInfoResponse: response)
//
//                let lastTrc20TxTimestamp = storage.lastTransactionTimestamp(apiPath: TronGridProvider.ApiPath.transactionsTrc20.rawValue) ?? 0
//                var fingerprint: String?
//                var completed = false
//                repeat {
//                    let fetchResult = try await tronGridProvider.fetchTrc20Transactions(
//                        address: address,
//                        minTimestamp: lastTrc20TxTimestamp + 1000,
//                        fingerprint: fingerprint
//                    )
//
//                    if let lastTransaction = fetchResult.transactions.last {
//                        self?.transactionManager.save(trc20TransferResponses: fetchResult.transactions)
//                        storage.save(apiPath: TronGridProvider.ApiPath.transactionsTrc20.rawValue, lastTransactionTimestamp: lastTransaction.blockTimestamp)
//                    }
//                    fingerprint = fetchResult.fingerprint
//                    completed = fetchResult.completed
//                } while !completed
//
//                let lastTxTimestamp = storage.lastTransactionTimestamp(apiPath: TronGridProvider.ApiPath.transactions.rawValue) ?? 0
//                fingerprint = nil
//                completed = false
//                repeat {
//                    let fetchResult = try await tronGridProvider.fetchTransactions(
//                        address: address,
//                        minTimestamp: lastTxTimestamp + 1000,
//                        fingerprint: fingerprint
//                    )
//
//                    if let lastTransaction = fetchResult.transactions.last {
//                        self?.transactionManager.save(transactionResponses: fetchResult.transactions)
//                        storage.save(apiPath: TronGridProvider.ApiPath.transactions.rawValue, lastTransactionTimestamp: lastTransaction.blockTimestamp)
//                    }
//
//                    fingerprint = fetchResult.fingerprint
//                    completed = fetchResult.completed
//                } while !completed
//
//                self?.transactionManager.process(initial: lastTxTimestamp == 0 || lastTrc20TxTimestamp == 0)
//                self?.set(state: .synced)
//            } catch {
//                if let requestError = error as? TronGridProvider.RequestError,
//                   case .failedToFetchAccountInfo = requestError {
//                    self?.accountInfoManager.handleInactiveAccount()
//                    self?.set(state: .synced)
//                } else {
//                    self?.set(state: .notSynced(error: error))
//                }
//            }
//        }.store(in: &tasks)
//    }

}

