
import Foundation
import BigInt
import RxSwift

class StellarAdapter {

    let decimals = 7

    let stellarKitWrapper: StellarKitWrapper
    let stellarKit: StellarKit

    init(stellarKitWrapper: StellarKitWrapper) {
        self.stellarKitWrapper = stellarKitWrapper
        self.stellarKit = stellarKitWrapper.stellarKit
    }
}

extension StellarAdapter: IBalanceAdapter {

    var balanceState: AdapterState {
        convertToAdapterState(syncState: stellarKit.syncState)
    }

    var balanceStateUpdatedObservable: Observable<AdapterState> {
        stellarKit.syncStatePublisher.asObservable().map { [weak self] in
            self?.convertToAdapterState(syncState: $0) ?? .syncing(progress: nil, lastBlockDate: nil)
        }
    }

    var balanceData: BalanceData {
        balanceData(balance: stellarKit.balance)
    }
    
    var nativeBalanceData: BalanceData {
        balanceData(balance: stellarKit.nativeBalance)
    }

    var balanceDataUpdatedObservable: Observable<BalanceData> {
        stellarKit.balancePublisher.asObservable().map { [weak self] in
            return self?.balanceData(balance: $0) ?? BalanceData(available: 0)
        }
    }
}

extension StellarAdapter {
    
    func balanceDecimal(kitBalance: BigUInt?, decimals: Int) -> Decimal {
        guard let kitBalance = kitBalance else {
            return 0
        }

        guard let significand = Decimal(string: kitBalance.description) else {
            return 0
        }

        return Decimal(sign: .plus, exponent: -decimals, significand: significand)
    }
    
    func convertToAdapterState(syncState: StellarKit.SyncState) -> AdapterState {
        switch syncState {
            case .synced: return .synced
            case .notSynced(let error): return .notSynced(error: error.convertedError)
            case .syncing: return .syncing(progress: nil, lastBlockDate: nil)
        }
    }

    var isMainNet: Bool {
        stellarKitWrapper.stellarKit.network == .public
    }
    
    func balanceData(balance: BigUInt?) -> BalanceData {
        BalanceData(available: balanceDecimal(kitBalance: balance, decimals: decimals))
    }
}

extension StellarAdapter: IAdapter {
    
    var statusInfo: [(String, Any)] {
        []
    }
    
    var debugInfo: String {
        ""
    }
    

    func start() {
        // started via StellarKitManager
    }

    func stop() {
        stellarKit.stop()
    }

    func refresh() {
        stellarKit.refresh()
    }

}

extension StellarAdapter: IDepositAdapter {

    var receiveAddress: DepositAddress {
        DepositAddress(stellarKit.keyPair.accountId)
    }

}
