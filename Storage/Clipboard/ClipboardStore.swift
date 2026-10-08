import Foundation
import SQLite3
import KeyboardCore

struct ClipboardItem: Identifiable, Equatable {
    let id: String
    let text: String
    let createdAt: Date
    let lastUsedAt: Date
    let pinned: Bool
}

// One instance per process, always used on the main actor; SQLite arbitrates interprocess access.
@MainActor final class ClipboardStore {
    private var database: OpaquePointer?
    private let canWrite: Bool
    private static let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    private struct DatabaseError: LocalizedError {
        let code: Int32
        var errorDescription: String? { "履歴保存に失敗しました（SQLite \(code)）。再操作してください。" }
    }

    init(writable: Bool, fileURL: URL? = nil, schemaURL: URL? = nil) throws {
        canWrite = writable
        let directory = try fileURL?.deletingLastPathComponent() ?? SharedContainer.url().appendingPathComponent("Clipboard", isDirectory: true)
        if writable { try SharedContainer.preparePrivateDirectory(directory) }
        let file = fileURL ?? directory.appendingPathComponent("history.sqlite")
        let flags = writable ? SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE : SQLITE_OPEN_READONLY
        let code = sqlite3_open_v2(file.path, &database, flags | SQLITE_OPEN_FULLMUTEX, nil)
        guard code == SQLITE_OK else { sqlite3_close(database); database = nil; throw DatabaseError(code: code) }
        do {
            sqlite3_busy_timeout(database, 300)
            let version = try scalar("PRAGMA user_version")
            guard version <= 1 else { throw StorageError.unsupportedSchema }
            if writable {
                try execute("PRAGMA journal_mode = DELETE; PRAGMA secure_delete = ON;")
                if version == 0 {
                    guard let url = schemaURL ?? Bundle.main.url(forResource: "schema", withExtension: "sql") else {
                        throw StorageError.unsupportedSchema
                    }
                    try transaction { try execute(String(contentsOf: url, encoding: .utf8)) }
                }
                #if os(iOS)
                try FileManager.default.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: file.path)
                #endif
            } else if version != 1 { throw StorageError.unsupportedSchema }
        } catch {
            sqlite3_close(database); database = nil
            throw error
        }
    }
    deinit { sqlite3_close(database) }

    private func execute(_ sql: String) throws {
        let code = sqlite3_exec(database, sql, nil, nil, nil)
        guard code == SQLITE_OK else { throw DatabaseError(code: code) }
    }
    private func statement(_ sql: String, strings: [String] = [], doubles: [Double] = []) throws -> OpaquePointer {
        var pointer: OpaquePointer?
        let code = sqlite3_prepare_v2(database, sql, -1, &pointer, nil)
        guard code == SQLITE_OK, let pointer else { throw DatabaseError(code: code) }
        for (i, value) in strings.enumerated() {
            sqlite3_bind_text(pointer, Int32(i + 1), value, -1, Self.transient)
        }
        for (i, value) in doubles.enumerated() {
            sqlite3_bind_double(pointer, Int32(strings.count + i + 1), value)
        }
        return pointer
    }
    private func update(_ sql: String, strings: [String] = [], doubles: [Double] = []) throws {
        let stmt = try statement(sql, strings: strings, doubles: doubles)
        defer { sqlite3_finalize(stmt) }
        let code = sqlite3_step(stmt)
        guard code == SQLITE_DONE else { throw DatabaseError(code: code) }
    }
    private func scalar(_ sql: String, doubles: [Double] = []) throws -> Int {
        let stmt = try statement(sql, doubles: doubles)
        defer { sqlite3_finalize(stmt) }
        let code = sqlite3_step(stmt)
        guard code == SQLITE_ROW else { throw DatabaseError(code: code) }
        return Int(sqlite3_column_int(stmt, 0))
    }
    private func transaction(_ body: () throws -> Void) throws {
        guard canWrite else { throw StorageError.clipboardDisabled }
        try execute("BEGIN IMMEDIATE")
        do { try body(); try execute("COMMIT") }
        catch { try? execute("ROLLBACK"); throw error }
    }

    func list(search: String = "", limit: Int = 200) throws -> [ClipboardItem] {
        // instr is literal substring search: wildcard characters are not interpreted.
        let stmt = try statement("SELECT id,text,created_at,last_used_at,pinned FROM clipboard WHERE instr(text,?) > 0 ORDER BY pinned DESC,last_used_at DESC LIMIT ?", strings: [search], doubles: [Double(min(200, max(1, limit)))])
        defer { sqlite3_finalize(stmt) }
        var items: [ClipboardItem] = []
        while true {
            let code = sqlite3_step(stmt)
            if code == SQLITE_DONE { return items }
            guard code == SQLITE_ROW else { throw DatabaseError(code: code) }
            func string(_ column: Int32) -> String { String(cString: sqlite3_column_text(stmt, column)) }
            items.append(.init(id: string(0), text: string(1), createdAt: Date(timeIntervalSince1970: sqlite3_column_double(stmt, 2)), lastUsedAt: Date(timeIntervalSince1970: sqlite3_column_double(stmt, 3)), pinned: sqlite3_column_int(stmt, 4) == 1))
        }
    }
    func add(_ text: String, limit: Int, now: Date = Date()) throws {
        guard ClipboardPolicy.accepts(text) else { throw StorageError.invalidClipboard }
        let cap = min(200, max(1, limit))
        try transaction {
            try update("DELETE FROM clipboard WHERE pinned=0 AND created_at < ?", doubles: [now.addingTimeInterval(-Double(ClipboardPolicy.retentionDays) * 86400).timeIntervalSince1970])
            let existing = try list().first { $0.text == text }
            if let existing {
                try update("UPDATE clipboard SET last_used_at=?2 WHERE id=?1", strings: [existing.id], doubles: [now.timeIntervalSince1970])
            } else {
                if try scalar("SELECT COUNT(*) FROM clipboard WHERE pinned=1") >= cap { throw StorageError.capacityReached }
                while try scalar("SELECT COUNT(*) FROM clipboard") >= cap {
                    try execute("DELETE FROM clipboard WHERE id=(SELECT id FROM clipboard WHERE pinned=0 ORDER BY last_used_at ASC LIMIT 1)")
                }
                try update("INSERT INTO clipboard(id,text,created_at,last_used_at) VALUES(?1,?2,?3,?3)", strings: [UUID().uuidString, text], doubles: [now.timeIntervalSince1970])
            }
        }
    }

    func prune(now: Date = Date()) throws {
        try transaction { try update("DELETE FROM clipboard WHERE pinned=0 AND created_at < ?", doubles: [now.addingTimeInterval(-Double(ClipboardPolicy.retentionDays) * 86400).timeIntervalSince1970]) }
    }

    func remove(_ id: String) throws { try transaction { try update("DELETE FROM clipboard WHERE id=?", strings: [id]) } }
    func removeAll() throws { try transaction { try execute("DELETE FROM clipboard") } }
    func togglePin(_ id: String) throws { try transaction { try update("UPDATE clipboard SET pinned=1-pinned WHERE id=?", strings: [id]) } }
    func markUsed(_ id: String) throws { try transaction { try update("UPDATE clipboard SET last_used_at=?2 WHERE id=?1", strings: [id], doubles: [Date().timeIntervalSince1970]) } }
}
