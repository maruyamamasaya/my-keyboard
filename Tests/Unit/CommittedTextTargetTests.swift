import XCTest
@testable import KeyboardCore

@MainActor private final class CommittedClient: CommittedTextClient {
    var snapshot = DocumentSnapshot(documentID: UUID(), before: "前か", after: "後", selected: nil)
    var inserted: [String] = []
    var deletions = 0
    var changesDocumentOnDelete = false
    func insertText(_ text: String) { inserted.append(text); snapshot.before? += text; snapshot.selected = nil }
    func deleteBackward() {
        deletions += 1; snapshot.before?.removeLast()
        if changesDocumentOnDelete { snapshot.documentID = UUID() }
    }
}

final class CommittedTextTargetTests: XCTestCase {
    func testSelectedRangeTakesPriorityAndUsesSingleInsertion() async throws {
        try await MainActor.run {
            let client = CommittedClient(); client.snapshot.selected = "か😀"
            let target = try XCTUnwrap(CommittedTextTarget(snapshot: client.snapshot, suffix: "か"))
            XCTAssertTrue(target.isSelection); XCTAssertEqual(target.text, "か😀")
            XCTAssertTrue(target.replace(with: "カ😀", using: client))
            XCTAssertEqual(client.inserted, ["カ😀"]); XCTAssertEqual(client.deletions, 0)
        }
    }
    func testSuffixConversionAndStaleSelectionAreGuarded() async throws {
        try await MainActor.run {
            let client = CommittedClient()
            let target = try XCTUnwrap(CommittedTextTarget(snapshot: client.snapshot, suffix: "か"))
            XCTAssertTrue(target.replace(with: "ka", using: client))
            XCTAssertEqual(client.snapshot.before, "前ka"); XCTAssertEqual(client.snapshot.after, "後")
            XCTAssertFalse(target.replace(with: "カ", using: client))
            XCTAssertEqual(client.deletions, 1)
            client.snapshot.selected = "後"
            let selected = try XCTUnwrap(CommittedTextTarget(snapshot: client.snapshot))
            client.snapshot.selected = "前"
            XCTAssertFalse(selected.replace(with: "ご", using: client))
            XCTAssertEqual(client.inserted, ["ka"])
        }
    }
    func testChangedHostStopsBeforeAnotherDeleteOrInsertion() async throws {
        try await MainActor.run {
            let client = CommittedClient(); client.snapshot.before = "前きょう"
            let target = try XCTUnwrap(CommittedTextTarget(snapshot: client.snapshot, suffix: "きょう"))
            client.changesDocumentOnDelete = true
            XCTAssertFalse(target.replace(with: "今日", using: client))
            XCTAssertEqual(client.deletions, 1); XCTAssertTrue(client.inserted.isEmpty)
        }
    }
    func testAlreadyMatchingTextDoesNotDeleteOrInsert() async throws {
        try await MainActor.run {
            let client = CommittedClient()
            let target = try XCTUnwrap(CommittedTextTarget(snapshot: client.snapshot, suffix: "か"))
            XCTAssertTrue(target.replace(with: "か", using: client))
            XCTAssertEqual(client.deletions, 0); XCTAssertTrue(client.inserted.isEmpty)
        }
    }
    func testUnknownContextOversizedAndCompoundSuffixesAreRejected() {
        var snapshot = DocumentSnapshot(documentID: UUID(), before: "前😀", after: "", selected: nil)
        XCTAssertNil(CommittedTextTarget(snapshot: snapshot, suffix: "😀"))
        XCTAssertNil(CommittedTextTarget(snapshot: snapshot, suffix: "か"))
        snapshot.selected = String(repeating: "か", count: 129)
        XCTAssertNil(CommittedTextTarget(snapshot: snapshot))
        snapshot.selected = "か"; snapshot.documentID = nil
        XCTAssertNil(CommittedTextTarget(snapshot: snapshot))
        snapshot.documentID = UUID(); snapshot.selected = nil; snapshot.before = "か"; snapshot.after = nil
        XCTAssertNil(CommittedTextTarget(snapshot: snapshot, suffix: "か"))
    }
}
