
import Foundation
import Combine
import BigInt
import stellarsdk
import MarketKit
import RxSwift
import RxCocoa

public enum StellarUSDCAssetIssuer {
    case mainNet
    case testNet
    
    public var assetIssuer: String {
        switch self {
        case .mainNet: return "GA5ZSEJYB37JRC5AVCIA5MOP4RHTM335X2KGX3IHOJAPP5RE34K4KZVN"
        case .testNet: return "GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5"
        }
    }
}

class StellarKitProvider {
    
    private let sdk: StellarSDK
    private let keyPair: KeyPair
    private let network: Network
    private let tokenType: TokenType
    
    private let balanceSubject = PassthroughSubject<BigUInt, Never>()
    let transactionRecordsSubject = PublishSubject<[TransactionResponse]>()
    let operationRecordsSubject = PublishSubject<[OperationResponse]>()
    let accountStatusSubject = PublishSubject<Bool>()
    let submitTransactionSuccessSubject = PublishSubject<()>()
    let usdcAssetIssuer: String
    
    var balance: BigUInt = .zero {
        didSet {
            balanceSubject.send(balance)
        }
    }
    
    var nativeBalance: BigUInt = .zero
    
    init(keyPair: KeyPair, network: Network, tokenType: TokenType) {
        self.network = network
        self.keyPair = keyPair
        self.tokenType = tokenType
        
        self.sdk = network == .public ? StellarSDK.publicNet() : StellarSDK.testNet()
        self.usdcAssetIssuer = network == .public ? StellarUSDCAssetIssuer.mainNet.assetIssuer : StellarUSDCAssetIssuer.testNet.assetIssuer
    }
}


extension StellarKitProvider {
    
    var balancePublisher: AnyPublisher<BigUInt, Never> {
        balanceSubject.eraseToAnyPublisher()
    }
}

extension StellarKitProvider {
    
    func fetchAccountDetails() {
        
        sdk.accounts.getAccountDetails(accountId: keyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let accountResponse):
                
                self.accountStatusSubject.onNext(true)
                
                if self.tokenType != .native,
                   !accountResponse.balances.contains(where: { $0.assetIssuer == self.usdcAssetIssuer }) {
                    self.trustUSDC()
                }
                
                for balance in accountResponse.balances {
                    
//                    print("balance balance: \(balance.balance)")
//                    print("balance assetType: \(balance.assetType)")
//                    print("self.tokenType: \(self.tokenType)")
                    
                    switch balance.assetType {
                    case AssetTypeAsString.NATIVE:
                        
//                        print("balance: \(balance.balance) XLM")
                        if self.tokenType == .native {
                            self.balance = BigUInt((Double(balance.balance) ?? .zero) * 10_000_000)
                        }
                        self.nativeBalance = BigUInt((Double(balance.balance) ?? .zero) * 10_000_000)
                        
                    default:
                        
//                        print("balance: \(balance.balance) \(balance.assetCode!) issuer: \(balance.assetIssuer!)")
                        guard case .creditAlphanum4( _) = self.tokenType else { continue }
                        self.balance = BigUInt((Double(balance.balance) ?? .zero) * 10_000_000)

                    }
                }
                
            case .failure(let error):
                // print("fetchAccountDetails error = \(error.localizedDescription)")
                self.accountStatusSubject.onNext(false)
            }
        }
    }
    
    
    func fetchTransactions() {
        
        sdk.transactions.getTransactions(forAccount: keyPair.accountId, order: .descending, limit: 100) { (response) -> (Void) in
            switch response {
            case .success(let response):
                self.transactionRecordsSubject.onNext(response.records)
                
            case .failure(let error):
                //print("fetchTransactions error = \(error.localizedDescription)")
                break
            }
        }
    }
    
    func fetchOperations() {
        
        sdk.operations.getOperations(forAccount: keyPair.accountId, order: .descending, limit: 100) { (response) -> (Void) in
            switch response {
            case .success(let response):
                self.operationRecordsSubject.onNext(response.records)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func isValidAccount(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        sdk.accounts.getAccountDetails(accountId: id) { (response) -> (Void) in
            switch response {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                // print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    func send(destinationAccountId: String, amount: Decimal, token: Token) -> Single<Void> {
        
        return Single.create { single in
            
            guard let issuingAccountKeyPair = try? KeyPair(accountId: self.usdcAssetIssuer) else {
                single(.error(StellarKit.SendError.notSupportedContract))
                return Disposables.create()
            }
            
            guard let asset = self.tokenType == .native ? Asset(type: AssetType.ASSET_TYPE_NATIVE) : Asset(type: AssetType.ASSET_TYPE_CREDIT_ALPHANUM4, code: token.coin.code, issuer: issuingAccountKeyPair) else {
                single(.error(StellarKit.SendError.notSupportedContract))
                return Disposables.create()
            }
            
            let sourceAccountKeyPair = self.keyPair
            let sourceAccountId = self.keyPair.accountId
            
//            print("asset.issuer?.accountId = \(asset.issuer?.accountId)")
//            print("asset.type = \(asset.type)")
//            print("asset.code = \(asset.code)")
//            print("amount = \(amount)")
//            print("usdcAssetIssuer = \(self.usdcAssetIssuer)")
//            print("sourceAccountId = \(sourceAccountId)")
//            print("destinationAccountId = \(destinationAccountId)")
            
            
            self.sdk.accounts.getAccountDetails(accountId: sourceAccountId) { response in
                switch response {
                case .success(let accountResponse):
                    
                    do {
                        // build the payment operation
                        let paymentOperation = try PaymentOperation(sourceAccountId: sourceAccountId,
                                                                    destinationAccountId: destinationAccountId,
                                                                    asset: asset,
                                                                    amount: amount)
                        
                        // build the transaction containing our payment operation.
                        let transaction = try Transaction(sourceAccount: accountResponse,
                                                          operations: [paymentOperation],
                                                          memo: Memo.none)
                        // sign the transaction
                        try transaction.sign(keyPair: sourceAccountKeyPair, network: self.network)
                        
                        // submit the transaction.
                        try self.sdk.transactions.submitTransaction(transaction: transaction) { response in
                            switch response {
                            case .success(_):
                                self.submitTransactionSuccessSubject.onNext(())
                                single(.success(()))
                                
                            case .failure(let error):
                                
                                single(.error(error))
                                print("submitTransaction error = \(error.localizedDescription)")
                                StellarSDKLog.printHorizonRequestErrorMessage(tag:"mainnet", horizonRequestError: error)
                                
                            case .destinationRequiresMemo(destinationAccountId: let destinationAccountId):
                                //print("Destination account \(destinationAccountId) requires memo.")
                                break
                            }
                        }
                    } catch {
                        // handle other errors
                         print("catch error = \(error.localizedDescription)")
                        single(.error(error))
                    }
                    
                case .failure(let error):
                    // handle account details retrieval error
                     print("failure error = \(error.localizedDescription)")
                    single(.error(error))
                }
                
            }
            
            return Disposables.create()
        }
    }
    
    
    func trustUSDC() {
        
        guard let issuingAccountKeyPair = try? KeyPair(accountId: self.usdcAssetIssuer) else { return }
        
        let IOM = ChangeTrustAsset(type: AssetType.ASSET_TYPE_CREDIT_ALPHANUM4, code: "USDC", issuer: issuingAccountKeyPair)
        
        let sourceAccountId = keyPair.accountId
        
        self.sdk.accounts.getAccountDetails(accountId: keyPair.accountId) { response in
            switch response {
            case .success(let accountResponse):
                
                do {
                    // build a change trust operation.
                    let limit = Decimal(string: "922337203685.4775807")
                    //                    let limit = Decimal(string: "0")
                    let changeTrustOp = ChangeTrustOperation(sourceAccountId: sourceAccountId, asset:IOM!, limit: limit)
                    
                    // build the transaction containing our operation
                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [changeTrustOp],
                                                      memo: Memo(text: "Trust USDC"))
                    // sign the transaction
                    try transaction.sign(keyPair: self.keyPair, network: self.network)
                    
                    // sublit the transaction
                    try self.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                        //                        switch response {
                        //                        case .success(_):
                        //
                        //                        case .failure(let error):
                        //                        case .destinationRequiresMemo(destinationAccountId: let destinationAccountId):
                        //                        }
                    }
                } catch {
                    // handle other errors
                    // print("catch error = \(error.localizedDescription)")
                }
                
            case .failure(let error): break
                // handle account details retrieval error
                // print("failure error = \(error.localizedDescription)")
            }
        }
    }
}

extension Network: Equatable {
    
    public static func == (lhs: Network, rhs: Network) -> Bool {
        switch (lhs, rhs) {
        case (.public, .public), (.testnet, .testnet), (.futurenet, .futurenet):
            return true
        case let (.custom(networkId1), .custom(networkId2)):
            return networkId1 == networkId2
        default:
            return false
        }
    }
}


