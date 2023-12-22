
import Foundation
import Combine
import HdWalletKit
import BigInt
import HsCryptoKit
import HsToolKit
import stellarsdk
import MarketKit
import RxSwift
import RxRelay

class StellarKitManager {
    
    private let queue = DispatchQueue(label: "\(AppConfig.label).stellar-kit-manager", qos: .userInitiated)
    
    private weak var _stellarKitWrapper: StellarKitWrapper?
    
    private let stellarKitCreatedRelay = PublishRelay<Void>()
    private var currentAccount: Account?
    private var cuttentTokenType: TokenType?
    
    init() {
    }

    private func _stellarKitWrapper(wallet: Wallet, account: Account, blockchainType: BlockchainType) throws -> StellarKitWrapper {
        
        if let _stellarKitWrapper = _stellarKitWrapper, let currentAccount = currentAccount, currentAccount == account, let cuttentTokenType = cuttentTokenType, cuttentTokenType == wallet.token.tokenQuery.tokenType {
            return _stellarKitWrapper
        }

        let network: Network = AppConfig.officeMode ? .testnet : .public
        
        switch account.type {
        case .mnemonic:
            guard let seed = account.type.mnemonicSeed else {
                throw AdapterError.unsupportedAccount
            }

            let kit = StellarKit.instance(seed: seed, network: network, walletId: account.id, tokenType: wallet.token.tokenQuery.tokenType)
            kit.start()
            
            let wrapper = StellarKitWrapper(blockchainType: blockchainType, stellarKit: kit, token: wallet.token)
            
            _stellarKitWrapper = wrapper
            currentAccount = account
            cuttentTokenType = wallet.token.tokenQuery.tokenType

            stellarKitCreatedRelay.accept(())

            return wrapper

        default:
            throw AdapterError.unsupportedAccount
        }
    }
}

extension StellarKitManager {
    
    var stellarKitCreatedObservable: Observable<Void> {
        stellarKitCreatedRelay.asObservable()
    }

    var stellarKitWrapper: StellarKitWrapper? {
        queue.sync {
            _stellarKitWrapper
        }
    }

    func stellarKitWrapper(wallet: Wallet, account: Account, blockchainType: BlockchainType) throws -> StellarKitWrapper {
        try queue.sync {
            try _stellarKitWrapper(wallet: wallet, account: account, blockchainType: blockchainType)
        }
    }
}
