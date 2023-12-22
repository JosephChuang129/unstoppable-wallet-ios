
import Foundation
import GRDB

class StellarSyncerStorage {
    private let dbPool: DatabasePool

    init(databaseDirectoryUrl: URL, databaseFileName: String) {
        let databaseURL = databaseDirectoryUrl.appendingPathComponent("\(databaseFileName).sqlite")

        dbPool = try! DatabasePool(path: databaseURL.path)

        try! migrator.migrate(dbPool)
    }

    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("createLastBlockHeight") { db in
            try db.create(table: LastBlockHeight.databaseTableName, body: { t in
                t.column(LastBlockHeight.Columns.primaryKey.name, .text).primaryKey(onConflict: .replace)
                t.column(LastBlockHeight.Columns.height.name, .integer).notNull()
            })
        }

        return migrator
    }

}

extension StellarSyncerStorage {

    var lastBlockHeight: Int? {
        try? dbPool.read { db in
            try LastBlockHeight.fetchOne(db)?.height
        }
    }

    func save(lastBlockHeight: Int) {
        _ = try! dbPool.write { db in
            let state = try LastBlockHeight.fetchOne(db) ?? LastBlockHeight()
            state.height = lastBlockHeight
            try state.insert(db)
        }
    }
}


class LastBlockHeight: Record {
    private static let primaryKey = "primaryKey"

    private let primaryKey: String = LastBlockHeight.primaryKey
    var height: Int?

    override init() {
        super.init()
    }

    override class var databaseTableName: String {
        return "last_block_height"
    }

    enum Columns: String, ColumnExpression {
        case primaryKey
        case height
    }

    required init(row: Row) {
        height = row[Columns.height]

        super.init(row: row)
    }

    override func encode(to container: inout PersistenceContainer) {
        container[Columns.primaryKey] = primaryKey
        container[Columns.height] = height
    }

}
