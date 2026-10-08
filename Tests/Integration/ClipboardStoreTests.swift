import XCTest
import KeyboardCore

final class ClipboardStoreTests: XCTestCase {
    @MainActor private func withStore(_ test: (ClipboardStore) throws -> Void) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = try ClipboardStore(writable: true, fileURL: directory.appendingPathComponent("test.sqlite"), schemaURL: Bundle(for: Self.self).url(forResource: "schema", withExtension: "sql"))
        try test(store)
    }
    @MainActor func testDuplicatesPinsAndBoundedEviction() async throws {
        try withStore { store in
            try store.add("A", limit: 2)
            try store.add("A", limit: 2)
            XCTAssertEqual(try store.list().count, 1)
            let first = try XCTUnwrap(store.list().first)
            try store.togglePin(first.id)
            try store.add("B", limit: 2)
            try store.add("C", limit: 2)
            XCTAssertEqual(Set(try store.list().map(\.text)), Set(["A", "C"]))
            let second = try XCTUnwrap(store.list().first { $0.text == "C" })
            try store.togglePin(second.id)
            XCTAssertThrowsError(try store.add("D", limit: 2))
            XCTAssertEqual(try store.list().count, 2)
        }
    }
    @MainActor func testLiteralSearchAndExpiry() async throws {
        try withStore { store in
            let past = Date().addingTimeInterval(-31 * 86400)
            try store.add("100%_", limit: 10, now: past)
            let pinned = try XCTUnwrap(store.list().first)
            try store.togglePin(pinned.id)
            try store.add("old", limit: 10, now: past)
            try store.prune()
            XCTAssertEqual(try store.list(search: "%_").map(\.text), ["100%_"])
            XCTAssertEqual(try store.list().count, 1)
            try store.removeAll()
            XCTAssertTrue(try store.list().isEmpty)
        }
    }
    @MainActor func testTwoConnectionsAndReadOnlyEnforcement() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("test.sqlite")
        let writer = try ClipboardStore(writable: true, fileURL: url, schemaURL: Bundle(for: Self.self).url(forResource: "schema", withExtension: "sql"))
        try writer.add("共有", limit: 10)
        let reader = try ClipboardStore(writable: false, fileURL: url)
        XCTAssertEqual(try reader.list().map(\.text), ["共有"])
        XCTAssertThrowsError(try reader.add("禁止", limit: 10))
        try writer.removeAll()
        XCTAssertTrue(try reader.list().isEmpty)
    }
}
