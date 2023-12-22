
import Foundation
import BigInt
import RxSwift
import BigInt
import HsToolKit
import MarketKit

class StellarTransactionConverter {
    
    private let coinManager: CoinManager
    private let wrapper: StellarKitWrapper
    private let source: TransactionSource
    private let baseToken: MarketKit.Token

    init(source: TransactionSource, baseToken: MarketKit.Token, coinManager: CoinManager, wrapper: StellarKitWrapper) {
        self.coinManager = coinManager
        self.wrapper = wrapper
        self.source = source
        self.baseToken = baseToken
    }
    
    private var kit: StellarKit {
        wrapper.stellarKit
    }

    private func convertAmount(amount: String, decimals: Int, sign: FloatingPointSign) -> Decimal {
        
        let coinRate: Decimal = 10_000_000
        
        guard let significand = Decimal(string: amount), significand != 0 else {
            return 0
        }
        return Decimal(sign: sign, exponent: -decimals, significand: significand * coinRate)
    }
    
    
    private func baseCoinValue(value: String, sign: FloatingPointSign) -> TransactionValue {
        let amount = convertAmount(amount: value, decimals: baseToken.decimals, sign: sign)
        return .coinValue(token: baseToken, value: amount)
    }
}

extension StellarTransactionConverter {
 
    func transactionRecord(fromTransaction fullTransaction: StellarFullTransaction) -> StellarTransactionRecord {
        let transaction = fullTransaction.transaction

        let operation = fullTransaction.operation
        let value: TransactionValue
        
        switch operation?.operationTypeString {
            
        case "payment":

            guard let amount = operation?.amount else {
                return StellarTransactionRecord(
                    source: source,
                    transaction: transaction
                )
            }
            
            let sign: FloatingPointSign = operation?.from == wrapper.stellarKit.keyPair.accountId ? .minus : .plus
            
            if let assetIssuer = operation?.assetIssuer, let token = try? coinManager.token(query: TokenQuery(blockchainType: .stellar, tokenType: TokenType.creditAlphanum4(assetIssuer: assetIssuer))) {
                
                let amount = convertAmount(amount: amount, decimals: token.decimals, sign: sign)
                value = TransactionValue.coinValue(token: token, value: amount)
                
            } else {
                
                value = baseCoinValue(value: amount, sign: sign)
            }
            
            if let from = operation?.from, wrapper.stellarKit.keyPair.accountId == from {
                
                return StellarOutgoingTransactionRecord(
                    source: source,
                    transaction: transaction,
                    to: from,
                    value: value
                )
            } else if let to = operation?.to, wrapper.stellarKit.keyPair.accountId == to {
                
                return StellarIncomingTransactionRecord(
                    source: source,
                    transaction: transaction,
                    from: to,
                    value: value
                )
                
            } else {
                
                return StellarTransactionRecord(
                    source: source,
                    transaction: transaction
                )
            }
            
        case "create_account":
            
            if let startingBalance = operation?.startingBalance {
                
                value = baseCoinValue(value: startingBalance, sign: .plus)
                
                return StellarCreateAccountTransactionRecord(
                    source: source,
                    transaction: transaction,
                    value: value
                )
            } else {

                return StellarTransactionRecord(
                    source: source,
                    transaction: transaction
                )
            }
            
        default:
            
            return StellarTransactionRecord(
                source: source,
                transaction: transaction
            )
        }
    }
}

class StellarTransactionRecord: TransactionRecord {
    let transaction: StellarTransaction
    let fee: TransactionValue?
    
    init(source: TransactionSource, transaction: StellarTransaction) {
        self.transaction = transaction
        
        fee = nil
//        if let feeAmount = transaction.gasUsed ?? transaction.gasLimit, let gasPrice = transaction.gasPrice {
//            let feeDecimal = Decimal(sign: .plus, exponent: -baseToken.decimals, significand: Decimal(feeAmount) * Decimal(gasPrice))
//            fee = .coinValue(token: baseToken, value: feeDecimal)
//        } else {
//            fee = nil
//        }
        
        super.init(
            source: source,
            uid: transaction.transactionHash,
            transactionHash: transaction.transactionHash,
            transactionIndex: 0,
            blockHeight: transaction.ledger,
            confirmationsThreshold: 0,
            date: Date(timeIntervalSince1970: Double(transaction.timestamp)),
            failed: false
        )
    }
}

class StellarIncomingTransactionRecord: StellarTransactionRecord {
    
    let from: String
    let value: TransactionValue
    
    init(source: TransactionSource, transaction: StellarTransaction, from: String, value: TransactionValue) {
        self.from = from
        self.value = value

        super.init(source: source, transaction: transaction)
    }
    
    override var mainValue: TransactionValue? {
        value
    }
}


class StellarOutgoingTransactionRecord: StellarTransactionRecord {
    
    let to: String
    let value: TransactionValue
    
    init(source: TransactionSource, transaction: StellarTransaction, to: String, value: TransactionValue) {
        self.to = to
        self.value = value

        super.init(source: source, transaction: transaction)
    }
    
    override var mainValue: TransactionValue? {
        value
    }
}

class StellarCreateAccountTransactionRecord: StellarTransactionRecord {
    
    let value: TransactionValue
    
    init(source: TransactionSource, transaction: StellarTransaction, value: TransactionValue) {
        self.value = value

        super.init(source: source, transaction: transaction)
    }
    
    override var mainValue: TransactionValue? {
        value
    }
}
