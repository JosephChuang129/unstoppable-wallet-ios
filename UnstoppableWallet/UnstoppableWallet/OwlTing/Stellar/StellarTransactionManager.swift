
import Foundation
import Combine
import stellarsdk

class StellarTransactionManager {
    
    private let accountId: String
    private let storage: StellarTransactionStorage
    private let decorationManager: StellarDecorationManager
    
    private let fullTransactionsSubject = PassthroughSubject<([StellarFullTransaction], Bool), Never>()
    private let fullTransactionsWithTagsSubject = PassthroughSubject<[(transaction: StellarFullTransaction, tags: [StellarTransactionTag])], Never>()
    
    init(accountId: String, storage: StellarTransactionStorage, decorationManager: StellarDecorationManager) {
        self.accountId = accountId
        self.storage = storage
        self.decorationManager = decorationManager
    }
    
    func save(transactionResponses: [TransactionResponse]) {
        
        let transactions = transactionResponses.compactMap { internalTx in
            StellarTransaction(response: internalTx)
        }
        
        storage.save(transactions: transactions)
        
        let fullTransactions = decorationManager.decorate(transactions: transactions)
        
        var fullTransactionsWithTags = [(transaction: StellarFullTransaction, tags: [StellarTransactionTag])]()
        var tagRecords = [StellarTransactionTagRecord]()
        
        for fullTransaction in fullTransactions {
            
            let operation = fullTransaction.operation
            let assetType = operation?.assetType
            let type: StellarTransactionTag.TagType = operation?.operationTypeString == "create_account" ? .createAccount : (operation?.from == accountId ? .outgoing : .incoming)
            let tagProtocol: StellarTransactionTag.TagProtocol = assetType == AssetTypeAsString.NATIVE ? .native : .creditAlphanum4
            let tag = StellarTransactionTag(type: type, protocol: tagProtocol, contractAddress: operation?.assetIssuer)
            let tagRecord = StellarTransactionTagRecord(transactionHash: fullTransaction.transaction.transactionHash, tag: tag)
            
            tagRecords.append(tagRecord)
            fullTransactionsWithTags.append((transaction: fullTransaction, tags: [tag]))
        }
        
        storage.save(tags: tagRecords)
        fullTransactionsSubject.send((fullTransactions, false))
        fullTransactionsWithTagsSubject.send(fullTransactionsWithTags)
    }
    
    func save(operationResponses: [OperationResponse]) {
        
        var operations: [StellarOperation] = []
        
        for operation in operationResponses {
            
            //            print("payment = \(operation.operationTypeString)")
            
            if let nextOperation = operation as? PaymentOperationResponse {
                let op = StellarPaymentOperation(response: nextOperation)
                operations.append(op)
            }
            //            else if let nextOperation = payment as? PathPaymentStrictSendOperationResponse {
            //
            //                if (nextOperation.assetType == AssetTypeAsString.NATIVE) {
            //                    print("received: \(nextOperation.amount) lumen" )
            //                } else {
            //                    print("received: \(nextOperation.amount) \(nextOperation.assetCode!)" )
            //                }
            //                let op = PathPaymentStrictSendOperation(response: nextOperation)
            //                operations.append(op)
            //            }
            else if let nextOperation = operation as? AccountCreatedOperationResponse {
                let op = StellarAccountCreatedOperation(response: nextOperation)
                operations.append(op)
            }
        }
        storage.save(operations: operations)
    }
    
    func process(transactions: [StellarTransaction]) {
        
    }
    
    private func save(transactions: [StellarTransaction]) {
        storage.save(transactions: transactions)
    }
}

extension StellarTransactionManager {
    
    var fullTransactionsPublisher: AnyPublisher<([StellarFullTransaction], Bool), Never> {
        fullTransactionsSubject.eraseToAnyPublisher()
    }
    
    func fullTransactionsPublisher(tagQueries: [StellarTransactionTagQuery]) -> AnyPublisher<[StellarFullTransaction], Never> {
        
        fullTransactionsWithTagsSubject
            .map { transactionsWithTags in
                
                transactionsWithTags.compactMap { (transaction: StellarFullTransaction, tags: [StellarTransactionTag]) -> StellarFullTransaction? in
                    for tagQuery in tagQueries {
                        
                        for tag in tags {
                            if tag.conforms(tagQuery: tagQuery) {
                                return transaction
                            }
                        }
                    }
                    
                    return nil
                }
            }
            .filter { transactions in
                transactions.count > 0
            }
            .eraseToAnyPublisher()
    }
    
    func fullTransactions(tagQueries: [StellarTransactionTagQuery], fromHash: String?, limit: Int?) -> [StellarFullTransaction] {
        let transactions = storage.transactionsBefore(tagQueries: tagQueries, hash: fromHash, limit: limit)
        return decorationManager.decorate(transactions: transactions)
    }
}

public class StellarFullTransaction {
    let transaction: StellarTransaction
    let operation: StellarOperation?
    
    init(transaction: StellarTransaction, operation: StellarOperation?) {
        self.transaction = transaction
        self.operation = operation
    }
}

open class StellarTransactionDecoration {
    
    public init() {
    }
    
    open func tags(accountId: String) -> [StellarTransactionTag] {
        []
    }
    
}


import BigInt

class StellarDecorationManager {
    private let accountId: String
    private let storage: StellarTransactionStorage
    
    init(accountId: String, storage: StellarTransactionStorage) {
        self.accountId = accountId
        self.storage = storage
    }
}

extension StellarDecorationManager {
    
    func decorate(transactions: [StellarTransaction]) -> [StellarFullTransaction] {
        
        let fullTransactions = transactions.compactMap { [weak self] transaction in
            
            if let op = self?.storage.stellarOperation(hash: transaction.transactionHash) {
                return StellarFullTransaction(transaction: transaction, operation: op)
            }
            
            return nil
        }
        
        return fullTransactions
    }
}

import BigInt

public class StellarIncomingDecoration: StellarTransactionDecoration {
    let from: String
    public let value: BigUInt
    
    init(from: String, value: BigUInt) {
        self.from = from
        self.value = value
    }
    
    func tags() -> [StellarTransactionTag] {
        [
            StellarTransactionTag(type: .incoming, protocol: .native)
        ]
    }
    
}


class StellarUnknownTransactionDecoration: StellarTransactionDecoration {
    private let userAddress: String
    private let toAddress: String?
    public let fromAddress: String?
    private let value: BigUInt?
    
    public init(userAddress: String, fromAddress: String?, toAddress: String?, value: BigUInt?) {
        self.userAddress = userAddress
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.value = value
    }
    
}
