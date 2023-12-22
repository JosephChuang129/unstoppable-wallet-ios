
import Foundation
import GRDB
import HsCryptoKit
import HsExtensions
import stellarsdk
import BigInt

class StellarTransactionStorage {
    private let dbPool: DatabasePool

    init(databaseDirectoryUrl: URL, databaseFileName: String) {
        let databaseURL = databaseDirectoryUrl.appendingPathComponent("\(databaseFileName).sqlite")

        dbPool = try! DatabasePool(path: databaseURL.path)

        try? migrator.migrate(dbPool)
    }

    var migrator: DatabaseMigrator {
        
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("Create Transaction") { db in
            try db.create(table: StellarTransaction.databaseTableName) { t in
                
                t.column(StellarTransaction.Columns.id.name, .text).primaryKey(onConflict: .replace)
                t.column(StellarTransaction.Columns.pagingToken.name, .text)
                t.column(StellarTransaction.Columns.transactionHash.name, .text)
                t.column(StellarTransaction.Columns.ledger.name, .integer)
                t.column(StellarTransaction.Columns.createdAt.name, .datetime)
                t.column(StellarTransaction.Columns.timestamp.name, .double)
                t.column(StellarTransaction.Columns.sourceAccount.name, .text)
                t.column(StellarTransaction.Columns.sourceAccountMuxed.name, .text)
                t.column(StellarTransaction.Columns.sourceAccountMuxedId.name, .text)
                t.column(StellarTransaction.Columns.sourceAccountSequence.name, .text)
                t.column(StellarTransaction.Columns.maxFee.name, .text)
                t.column(StellarTransaction.Columns.feeCharged.name, .text)
                t.column(StellarTransaction.Columns.feeAccount.name, .text)
                t.column(StellarTransaction.Columns.feeAccountMuxed.name, .text)
                t.column(StellarTransaction.Columns.feeAccountMuxedId.name, .text)
                t.column(StellarTransaction.Columns.operationCount.name, .integer)
                t.column(StellarTransaction.Columns.memoType.name, .text)
            }
        }
        
        migrator.registerMigration("create TransactionTagRecord") { db in
            try db.create(table: StellarTransactionTagRecord.databaseTableName) { t in
                t.column(StellarTransactionTagRecord.Columns.transactionHash.name, .text)
                t.column(StellarTransactionTagRecord.Columns.type.name, .text).notNull()
                t.column(StellarTransactionTagRecord.Columns.protocol.name, .text)
                t.column(StellarTransactionTagRecord.Columns.contractAddress.name, .text)
            }
        }
        
        migrator.registerMigration("Create StellarOperation") { db in
            try db.create(table: StellarOperation.databaseTableName) { t in
                
                t.column(StellarOperation.Columns.id.name, .text).primaryKey(onConflict: .replace)
                t.column(StellarOperation.Columns.pagingToken.name, .text)
                t.column(StellarOperation.Columns.transactionHash.name, .text)
                t.column(StellarOperation.Columns.createdAt.name, .datetime)
                t.column(StellarOperation.Columns.timestamp.name, .double)
                t.column(StellarOperation.Columns.sourceAccount.name, .text)
                t.column(StellarOperation.Columns.sourceAccountMuxed.name, .text)
                t.column(StellarOperation.Columns.sourceAccountMuxedId.name, .text)
                t.column(StellarOperation.Columns.operationTypeString.name, .text)
                t.column(StellarOperation.Columns.transactionSuccessful.name, .boolean)
                t.column(StellarOperation.Columns.amount.name, .text)
                
                t.column(StellarOperation.Columns.assetType.name, .text)
                t.column(StellarOperation.Columns.assetCode.name, .text)
                t.column(StellarOperation.Columns.assetIssuer.name, .text)
                t.column(StellarOperation.Columns.from.name, .text)
                t.column(StellarOperation.Columns.to.name, .text)
                t.column(StellarOperation.Columns.startingBalance.name, .text)
            }
        }
        
        return migrator
    }

}


class StellarTransaction: Record {
    static let decimal = 8 // 8-digit decimals

    let id: String
    let pagingToken: String
    let transactionHash: String
    let ledger: Int
    let createdAt: Date
    let timestamp: Double
    let sourceAccount: String
    let sourceAccountMuxed: String?
    let sourceAccountMuxedId: String?
    let sourceAccountSequence: String
    let maxFee: String?
    let feeCharged: String?
    let feeAccount: String
    let feeAccountMuxed: String?
    let feeAccountMuxedId: String?
    let operationCount: Int
    let memoType: String


    init?(response: TransactionResponse) {

        self.id = response.id
        self.pagingToken = response.pagingToken
        self.transactionHash = response.transactionHash
        self.ledger = response.ledger
        self.createdAt = response.createdAt
        self.timestamp = response.createdAt.timeIntervalSince1970
        self.sourceAccount = response.sourceAccount
        self.sourceAccountMuxed = response.sourceAccountMuxed
        self.sourceAccountMuxedId = response.sourceAccountMuxedId
        self.sourceAccountSequence = response.sourceAccountSequence
        self.maxFee = response.maxFee
        self.feeCharged = response.feeCharged
        self.feeAccount = response.feeAccount
        self.feeAccountMuxed = response.feeAccountMuxed
        self.feeAccountMuxedId = response.feeAccountMuxedId
        self.operationCount = response.operationCount
        self.memoType = response.memoType
        
        super.init()
    }

    override public class var databaseTableName: String {
        return "transactions"
    }

    enum Columns: String, ColumnExpression {

        case id
        case pagingToken
        case transactionHash
        case ledger
        case createdAt
        case timestamp
        case sourceAccount
        case sourceAccountMuxed
        case sourceAccountMuxedId
        case sourceAccountSequence
        case maxFee
        case feeCharged
        case feeAccount
        case feeAccountMuxed
        case feeAccountMuxedId
        case operationCount
        case memoType
    }


    required init(row: Row) {
        
        id = row[Columns.id]
        pagingToken = row[Columns.pagingToken]
        transactionHash = row[Columns.transactionHash]
        ledger = row[Columns.ledger]
        createdAt = row[Columns.createdAt]
        timestamp = row[Columns.timestamp]
        sourceAccount = row[Columns.sourceAccount]
        sourceAccountMuxed = row[Columns.sourceAccountMuxed]
        sourceAccountMuxedId = row[Columns.sourceAccountMuxedId]
        sourceAccountSequence = row[Columns.sourceAccountSequence]
        maxFee = row[Columns.maxFee]
        feeCharged = row[Columns.feeCharged]
        feeAccount = row[Columns.feeAccount]
        feeAccountMuxed = row[Columns.feeAccountMuxed]
        feeAccountMuxedId = row[Columns.feeAccountMuxedId]
        operationCount = row[Columns.operationCount]
        memoType = row[Columns.memoType]
        
        super.init(row: row)
    }

    override public func encode(to container: inout PersistenceContainer) {

        container[Columns.id] = id
        container[Columns.pagingToken] = pagingToken
        container[Columns.transactionHash] = transactionHash
        container[Columns.ledger] = ledger
        container[Columns.createdAt] = createdAt
        container[Columns.timestamp] = timestamp
        container[Columns.sourceAccount] = sourceAccount
        container[Columns.sourceAccountMuxed] = sourceAccountMuxed
        container[Columns.sourceAccountMuxedId] = sourceAccountMuxedId
        container[Columns.sourceAccountSequence] = sourceAccountSequence
        container[Columns.maxFee] = maxFee
        container[Columns.feeCharged] = feeCharged
        container[Columns.feeAccount] = feeAccount
        container[Columns.feeAccountMuxed] = feeAccountMuxed
        container[Columns.feeAccountMuxedId] = feeAccountMuxedId
        container[Columns.operationCount] = operationCount
        container[Columns.memoType] = memoType
    }


    private static func decimalValue(of int64: Int64) -> Decimal {
        return Decimal(sign: .plus, exponent: -decimal, significand: Decimal(int64))
    }

    private static func int64Value(of decimalValue: Decimal) -> Int64 {
        return Int64(truncating: Decimal(sign: .plus, exponent: decimal, significand: decimalValue) as NSNumber)
    }

}

public class StellarOperation: Record {
    
    let id: String
    let pagingToken: String
    let transactionHash: String
    let createdAt: Date
    let timestamp: Double
    let sourceAccount: String
    let sourceAccountMuxed: String?
    let sourceAccountMuxedId: String?
    let operationTypeString: String
    let transactionSuccessful: Bool
    
    var amount: String?
    var assetType: String?
    var assetCode: String?
    var assetIssuer: String?
    var from: String?
    var to: String?
    var startingBalance: String?
    
    init(response: OperationResponse) {

        self.id = response.id
        self.pagingToken = response.pagingToken
        self.transactionHash = response.transactionHash
        self.createdAt = response.createdAt
        self.timestamp = response.createdAt.timeIntervalSince1970
        self.sourceAccount = response.sourceAccount
        self.sourceAccountMuxed = response.sourceAccountMuxed
        self.sourceAccountMuxedId = response.sourceAccountMuxedId
        self.operationTypeString = response.operationTypeString
        self.transactionSuccessful = response.transactionSuccessful
        
        super.init()
    }

    override public class var databaseTableName: String {
        "stellarOperation"
    }

    enum Columns: String, ColumnExpression, CaseIterable {
        case id
        case pagingToken
        case transactionHash
        case createdAt
        case timestamp
        case sourceAccount
        case sourceAccountMuxed
        case sourceAccountMuxedId
        case operationTypeString
        case transactionSuccessful
        
        case amount
        case from
        case to
        case assetType
        case assetCode
        case assetIssuer
        case startingBalance
    }

    required init(row: Row) {
        
        id = row[Columns.id]
        pagingToken = row[Columns.pagingToken]
        transactionHash = row[Columns.transactionHash]
        createdAt = row[Columns.createdAt]
        timestamp = row[Columns.timestamp]
        sourceAccount = row[Columns.sourceAccount]
        sourceAccountMuxed = row[Columns.sourceAccountMuxed]
        sourceAccountMuxedId = row[Columns.sourceAccountMuxedId]
        operationTypeString = row[Columns.operationTypeString]
        transactionSuccessful = row[Columns.transactionSuccessful]
        
        amount = row[Columns.amount]
        from = row[Columns.from]
        to = row[Columns.to]
        assetType = row[Columns.assetType]
        assetCode = row[Columns.assetCode]
        assetIssuer = row[Columns.assetIssuer]
        startingBalance = row[Columns.startingBalance]
        

        super.init(row: row)
    }

    override public func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.pagingToken] = pagingToken
        container[Columns.transactionHash] = transactionHash
        container[Columns.createdAt] = createdAt
        container[Columns.timestamp] = timestamp
        container[Columns.sourceAccount] = sourceAccount
        container[Columns.sourceAccountMuxed] = sourceAccountMuxed
        container[Columns.sourceAccountMuxedId] = sourceAccountMuxedId
        container[Columns.operationTypeString] = operationTypeString
        container[Columns.transactionSuccessful] = transactionSuccessful
        
        container[Columns.amount] = amount
        container[Columns.from] = from
        container[Columns.to] = to
        container[Columns.assetType] = assetType
        container[Columns.assetCode] = assetCode
        container[Columns.assetIssuer] = assetIssuer
        container[Columns.startingBalance] = startingBalance
   
    }
}


class StellarPaymentOperation: StellarOperation {
    
    init(response: PaymentOperationResponse) {
        
        super.init(response: response)
        
        self.amount = response.amount
        self.assetType = response.assetType
        self.assetCode = response.assetCode
        self.assetIssuer = response.assetIssuer
        self.from = response.from
        self.to = response.to
    }
    
    required init(row: Row) {
        fatalError("init(row:) has not been implemented")
    }
}

class StellarAccountCreatedOperation: StellarOperation {
    
    init(response: AccountCreatedOperationResponse) {
        
        super.init(response: response)
        self.startingBalance = response.startingBalance.description
        self.assetType = AssetTypeAsString.NATIVE
    }
    
    required init(row: Row) {
        fatalError("init(row:) has not been implemented")
    }
}

class PathPaymentStrictSendOperation: StellarOperation {
    
    init(response: PathPaymentStrictSendOperationResponse) {
        
        super.init(response: response)
        
        self.amount = response.amount
        self.assetType = response.assetType
        self.assetCode = response.assetCode
        self.assetIssuer = response.assetIssuer
        self.from = response.from
        self.to = response.to
    }
    
    required init(row: Row) {
        fatalError("init(row:) has not been implemented")
    }
}


class StellarTransactionTagRecord: Record {
    let transactionHash: String
    let tag: StellarTransactionTag

    init(transactionHash: String, tag: StellarTransactionTag) {
        self.transactionHash = transactionHash
        self.tag = tag

        super.init()
    }

    override class var databaseTableName: String {
        "transactionTag"
    }

    enum Columns: String, ColumnExpression, CaseIterable {
        case transactionHash
        case type
        case `protocol`
        case contractAddress
    }

    required init(row: Row) {
        transactionHash = row[Columns.transactionHash]
        tag = StellarTransactionTag(
            type: row[Columns.type],
            protocol: row[Columns.protocol],
            contractAddress: row[Columns.contractAddress]
        )

        super.init(row: row)
    }

    override func encode(to container: inout PersistenceContainer) {
        container[Columns.transactionHash] = transactionHash
        container[Columns.type] = tag.type
        container[Columns.protocol] = tag.protocol
        container[Columns.contractAddress] = tag.contractAddress
    }

}

extension StellarTransactionStorage {
    
    func transaction(hash: String) -> StellarTransaction? {
        try! dbPool.read { db in
            try StellarTransaction
                .filter(StellarTransaction.Columns.transactionHash == hash)
                    .fetchOne(db)
        }
    }

    func transactions(hashes: [String]) -> [StellarTransaction] {
        try! dbPool.read { db in
            try StellarTransaction
                .filter(hashes.contains(StellarTransaction.Columns.transactionHash))
                    .fetchAll(db)
        }
    }
    
    
    func transactionsBefore(tagQueries: [StellarTransactionTagQuery], hash: String?, limit: Int?) -> [StellarTransaction] {
        
        return try! dbPool.read { db in
            var arguments = [DatabaseValueConvertible]()
            var whereConditions = [String]()
            let queries = tagQueries.filter { !$0.isEmpty }
            var joinClause = ""

            if !queries.isEmpty {
                let tagConditions = queries
                        .map { (tagQuery: StellarTransactionTagQuery) -> String in
                            var statements = [String]()

                            if let type = tagQuery.type {
                                statements.append("\(StellarTransactionTagRecord.databaseTableName).'\(StellarTransactionTagRecord.Columns.type.name)' = ?")
                                arguments.append(type)
                            }
                            if let `protocol` = tagQuery.protocol {
                                statements.append("\(StellarTransactionTagRecord.databaseTableName).'\(StellarTransactionTagRecord.Columns.protocol.name)' = ?")
                                arguments.append(`protocol`)
                            }
                            if let contractAddress = tagQuery.contractAddress {
                                statements.append("\(StellarTransactionTagRecord.databaseTableName).'\(StellarTransactionTagRecord.Columns.contractAddress.name)' = ?")
                                arguments.append(contractAddress)
                            }

                            return "(\(statements.joined(separator: " AND ")))"
                        }
                        .joined(separator: " OR ")

                whereConditions.append(tagConditions)
                joinClause = "INNER JOIN \(StellarTransactionTagRecord.databaseTableName) ON \(StellarTransaction.databaseTableName).\(StellarTransaction.Columns.transactionHash.name) = \(StellarTransactionTagRecord.databaseTableName).\(StellarTransactionTagRecord.Columns.transactionHash.name)"
            }
            
            // print("joinClause = \(joinClause)")
            
            if let fromHash = hash,
               let fromTransaction = try StellarTransaction.filter(StellarTransaction.Columns.transactionHash == fromHash).fetchOne(db) {
                let fromCondition = """
                                    (
                                     \(StellarTransaction.Columns.timestamp.name) < ? OR
                                         (
                                             \(StellarTransaction.databaseTableName).\(StellarTransaction.Columns.timestamp.name) = ? AND
                                             \(StellarTransaction.databaseTableName).\(StellarTransaction.Columns.transactionHash.name) < ?
                                         )
                                    )
                                    """

                arguments.append(fromTransaction.timestamp)
                arguments.append(fromTransaction.timestamp)
                arguments.append(fromTransaction.transactionHash)

                whereConditions.append(fromCondition)
            }

            var limitClause = ""
            if let limit = limit {
                limitClause += "LIMIT \(limit)"
            }

            let orderClause = """
                              ORDER BY \(StellarTransaction.databaseTableName).\(StellarTransaction.Columns.timestamp.name) DESC,
                              \(StellarTransaction.databaseTableName).\(StellarTransaction.Columns.transactionHash.name) DESC
                              """

            let whereClause = whereConditions.count > 0 ? "WHERE \(whereConditions.joined(separator: " AND "))" : ""

            let sql = """
                      SELECT DISTINCT \(StellarTransaction.databaseTableName).*
                      FROM \(StellarTransaction.databaseTableName)
                      \(joinClause)
                      \(whereClause)
                      \(orderClause)
                      \(limitClause)
                      """
            
//            let sql = """
//                      SELECT DISTINCT \(StellarTransaction.databaseTableName).*
//                      FROM \(StellarTransaction.databaseTableName)
//                      \(whereClause)
//                      \(orderClause)
//                      \(limitClause)
//                      """

            
//            print("joinClause = \(joinClause)")
//            print("whereClause = \(whereClause)")
//            print("orderClause = \(orderClause)")
//            print("limitClause = \(limitClause)")
//            print("sql = \(sql)")
            
            let rows = try Row.fetchAll(db.makeStatement(sql: sql), arguments: StatementArguments(arguments))
            return rows.map { row -> StellarTransaction in
                StellarTransaction(row: row)
            }
        }
    }
    
    func transactions() -> [StellarTransaction] {
        try! dbPool.read { db in
            try StellarTransaction.filter(StellarTransaction.Columns.transactionHash).fetchAll(db)
        }
    }
    
    func save(transactions: [StellarTransaction]) {
        
        try! dbPool.write { db in
            for transaction in transactions {
                try transaction.save(db)
            }
        }
    }
    
    func save(operations: [StellarOperation]) {
        
        try! dbPool.write { db in
            for operation in operations {
                try operation.save(db)
            }
        }
    }
    
    func save(tags: [StellarTransactionTagRecord]) {
        try! dbPool.write { db in
            for tag in tags {
                try tag.save(db)
            }
        }
    }
    
    func stellarOperations() -> [StellarOperation] {
        try! dbPool.read { db in
            try StellarOperation.fetchAll(db)
        }
    }
    
    func stellarOperation(hash: String) -> StellarOperation? {
        try! dbPool.read { db in
            try StellarOperation
                .filter(StellarOperation.Columns.transactionHash == hash)
                    .fetchOne(db)
        }
    }
}

public class StellarTransactionTag: Hashable {
    public let type: TagType
    public let `protocol`: TagProtocol?
    public let contractAddress: String?

    public init(type: TagType, `protocol`: TagProtocol? = nil, contractAddress: String? = nil) {
        self.type = type
        self.protocol = `protocol`
        self.contractAddress = contractAddress
    }

    public func conforms(tagQuery: StellarTransactionTagQuery) -> Bool {
        if let type = tagQuery.type, self.type != type {
            return false
        }

        if let `protocol` = tagQuery.protocol, self.protocol != `protocol` {
            return false
        }

        if let contractAddress = tagQuery.contractAddress, self.contractAddress != contractAddress {
            return false
        }

        return true
    }

    public static func == (lhs: StellarTransactionTag, rhs: StellarTransactionTag) -> Bool {
        lhs.type == rhs.type && lhs.protocol == rhs.protocol && lhs.contractAddress == rhs.contractAddress
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(`protocol`)
        hasher.combine(contractAddress)
    }
    
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> TagProtocol? {
        switch dbValue.storage {
            case .string(let string):
                return TagProtocol(rawValue: string)
            default:
                return nil
        }
    }
}


public class StellarTransactionTagQuery {
    public let type: StellarTransactionTag.TagType?
    public let `protocol`: StellarTransactionTag.TagProtocol?
    public let contractAddress: String?

    public init(type: StellarTransactionTag.TagType? = nil, `protocol`: StellarTransactionTag.TagProtocol? = nil, contractAddress: String? = nil) {
        self.type = type
        self.protocol = `protocol`
        self.contractAddress = contractAddress
    }

    var isEmpty: Bool {
        type == nil && `protocol` == nil && contractAddress == nil
    }

}

extension StellarTransactionTag {

    public enum TagProtocol: String, DatabaseValueConvertible {
        case native
        case creditAlphanum4

        public var databaseValue: DatabaseValue {
            rawValue.databaseValue
        }
    }

    public enum TagType: String, DatabaseValueConvertible {
        case incoming
        case outgoing
        case approve
        case swap
        case contractCreation
        case createAccount

        public var databaseValue: DatabaseValue {
            rawValue.databaseValue
        }
    }

}



