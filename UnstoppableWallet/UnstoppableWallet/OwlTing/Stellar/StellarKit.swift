
import Foundation
import Combine
import HdWalletKit
import BigInt
import HsToolKit
import stellarsdk
import MarketKit
import RxSwift
import RxCocoa

public class StellarKit {
    
    let keyPair: KeyPair
    let stellarKitProvider: StellarKitProvider
    let transactionManager: StellarTransactionManager
    let network: Network
    private let syncer: StellarSyncer
    let disposeBag = DisposeBag()
    
    init(keyPair: KeyPair, network: Network, transactionManager: StellarTransactionManager, syncer: StellarSyncer, stellarKitProvider: StellarKitProvider) {
        self.keyPair = keyPair
        self.network = network
        self.transactionManager = transactionManager
        self.syncer = syncer
        self.stellarKitProvider = stellarKitProvider
        
        subscribe(disposeBag, stellarKitProvider.submitTransactionSuccessSubject) { [weak self] in
            self?.refresh()
        }
        
    }
}

extension StellarKit {
    
    public enum SyncError: Error {
        case notStarted
        case noNetworkConnection
    }
    
    public enum SendError: Error {
        case notSupportedContract
        case abnormalSend
        case invalidParameter
    }
}

extension StellarKit {
    
    public enum SyncState {
        case synced
        case syncing(progress: Double?)
        case notSynced(error: Error)
        
        public var notSynced: Bool {
            if case .notSynced = self { return true } else { return false }
        }
        
        public var syncing: Bool {
            if case .syncing = self { return true } else { return false }
        }
        
        public var synced: Bool {
            self == .synced
        }
    }
}

extension StellarKit.SyncState: Equatable {
    
    public static func ==(lhs: StellarKit.SyncState, rhs: StellarKit.SyncState) -> Bool {
        switch (lhs, rhs) {
        case (.synced, .synced): return true
        case (.syncing(let lhsProgress), .syncing(let rhsProgress)): return lhsProgress == rhsProgress
        case (.notSynced(let lhsError), .notSynced(let rhsError)): return "\(lhsError)" == "\(rhsError)"
        default: return false
        }
    }
    
}

extension StellarKit.SyncState: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .synced: return "synced"
        case .syncing(let progress): return "syncing \(progress ?? 0)"
        case .notSynced(let error): return "not synced: \(error)"
        }
    }
}

extension StellarKit {
    
    public var lastBlockHeight: Int? {
        syncer.lastBlockHeight
    }
    
    public var syncState: StellarKit.SyncState {
        syncer.state
    }
    
    public func start() {
        syncer.start()
    }
    
    public func stop() {
        syncer.stop()
    }
    
    public func refresh() {
        syncer.refresh()
    }
    
    public var balance: BigUInt {
        stellarKitProvider.balance
    }
    
    public var nativeBalance: BigUInt {
        stellarKitProvider.nativeBalance
    }
    
    public var balancePublisher: AnyPublisher<BigUInt, Never> {
        stellarKitProvider.balancePublisher
    }
    
    public var lastBlockHeightPublisher: AnyPublisher<Int, Never> {
        syncer.$lastBlockHeight.eraseToAnyPublisher()
    }
    
    public var syncStatePublisher: AnyPublisher<SyncState, Never> {
        syncer.$state.eraseToAnyPublisher()
    }
    
    public func transactions(tagQueries: [StellarTransactionTagQuery], fromHash: String? = nil, limit: Int? = nil) -> [StellarFullTransaction] {
        transactionManager.fullTransactions(tagQueries: tagQueries, fromHash: fromHash, limit: limit)
    }
    
    public func transactionsPublisher(tagQueries: [StellarTransactionTagQuery]) -> AnyPublisher<[StellarFullTransaction], Never> {
        transactionManager.fullTransactionsPublisher(tagQueries: tagQueries)
    }
    
    public var allTransactionsPublisher: AnyPublisher<([StellarFullTransaction], Bool), Never> {
        transactionManager.fullTransactionsPublisher
    }
}

extension StellarKit {
    
    public static func instance(seed: Data, network: Network, walletId: String, tokenType: TokenType) -> StellarKit {
        
        let uniqueId = "\(walletId)-\(network)"
        
        let masterPrivateKey = Ed25519Derivation(seed: seed)
        let purpose = masterPrivateKey.derived(at: 44)
        let coinType = purpose.derived(at: 148)
        let activeAccount = coinType.derived(at: 0)
        let keyPair = try! KeyPair.init(seed: Seed(bytes: activeAccount.raw.bytes))
        
        let reachabilityManager = ReachabilityManager()
        let syncTimer = StellarSyncTimer(reachabilityManager: reachabilityManager, syncInterval: 30)
        let stellarKitProvider = StellarKitProvider(keyPair: keyPair, network: network, tokenType: tokenType)
        
        let storage: StellarTransactionStorage = try! StellarTransactionStorage(databaseDirectoryUrl: dataDirectoryUrl(), databaseFileName: "transactions-storage-\(uniqueId)")
        let syncerStorage = try! StellarSyncerStorage(databaseDirectoryUrl: dataDirectoryUrl(), databaseFileName: "syncer-state-storage-\(uniqueId)")
        let decorationManager = StellarDecorationManager(accountId: keyPair.accountId, storage: storage)
        let transactionManager = StellarTransactionManager(accountId: keyPair.accountId, storage: storage, decorationManager: decorationManager)
        
        let syncer = StellarSyncer(syncTimer: syncTimer, transactionManager: transactionManager, stellarKitProvider: stellarKitProvider, storage: syncerStorage)
        
        let kit = StellarKit(keyPair: keyPair, network: network, transactionManager: transactionManager, syncer: syncer, stellarKitProvider: stellarKitProvider)
        
        return kit
    }
    
    private static func dataDirectoryUrl() throws -> URL {
        let fileManager = FileManager.default
        
        let url = try fileManager
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("stellar-kit", isDirectory: true)
        
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        
        return url
    }
    
    public static func clear(exceptFor excludedFiles: [String]) throws {
        let fileManager = FileManager.default
        let fileUrls = try fileManager.contentsOfDirectory(at: dataDirectoryUrl(), includingPropertiesForKeys: nil)
        
        for filename in fileUrls {
            if !excludedFiles.contains(where: { filename.lastPathComponent.contains($0) }) {
                try fileManager.removeItem(at: filename)
            }
        }
    }
}

