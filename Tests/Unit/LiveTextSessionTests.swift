import XCTest
@testable import KeyboardCore

@MainActor private final class MarkedClient: LiveTextClient {
    var snapshot = DocumentSnapshot(documentID: UUID(), before: "前", after: "後", selected: nil)
    var marked = ""
    var range = NSRange(location: 0, length: 0)
    var updates = 0
    var unmarks = 0
    func setMarkedText(_ text: String, selectedRange: NSRange) {
        snapshot.before = "前" + text; marked = text; range = selectedRange; updates += 1
    }
    func unmarkText() { unmarks += 1; marked = "" }
}
final class LiveTextSessionTests: XCTestCase {
    func testReplacementAndCommitDoNotDuplicateInput() async {
        await MainActor.run {
            let client = MarkedClient(), session = LiveTextSession()
            XCTAssertTrue(session.update("きょう", cursorUTF16: 3, using: client))
            XCTAssertTrue(session.update("今日", cursorUTF16: 2, using: client))
            XCTAssertTrue(session.finish("今日は", using: client))
            XCTAssertEqual(client.snapshot.before, "前今日は")
            XCTAssertEqual(client.snapshot.after, "後")
            XCTAssertEqual(client.unmarks, 1); XCTAssertFalse(session.isActive)
            XCTAssertFalse(session.finish("今日は", using: client))
            XCTAssertEqual(client.snapshot.before, "前今日は")
        }
    }
    func testExternalEditOrDocumentChangeStopsOwnership() async {
        await MainActor.run {
            for changeDocument in [false, true] {
                let client = MarkedClient(), session = LiveTextSession()
                session.update("仮名", cursorUTF16: 2, using: client)
                if changeDocument { client.snapshot.documentID = UUID() }
                else { client.snapshot.before = "本人の編集" }
                let before = client.snapshot
                XCTAssertFalse(session.update("漢字", cursorUTF16: 2, using: client))
                session.cancel(using: client)
                XCTAssertEqual(client.snapshot, before); XCTAssertEqual(client.updates, 1)
            }
        }
    }
    func testMissingDocumentIdentifierDoesNotEditHost() async {
        await MainActor.run {
            let client = MarkedClient(), session = LiveTextSession()
            client.snapshot.documentID = nil
            XCTAssertFalse(session.update("仮名", cursorUTF16: 2, using: client))
            XCTAssertEqual(client.updates, 0)
            client.snapshot.documentID = UUID()
            XCTAssertTrue(session.update("仮名", cursorUTF16: 2, using: client))
            client.snapshot.documentID = nil
            XCTAssertFalse(session.finish("漢字", using: client))
            session.cancel(using: client)
            XCTAssertEqual(client.updates, 1)
            XCTAssertEqual(client.unmarks, 0)
        }
    }
    func testCancellationAndUTF16Cursor() async {
        await MainActor.run {
            let client = MarkedClient(), session = LiveTextSession()
            session.update("あ😀", cursorUTF16: 3, using: client)
            XCTAssertEqual(client.range.location, 3)
            session.cancel(using: client)
            XCTAssertEqual(client.snapshot.before, "前"); XCTAssertEqual(client.snapshot.after, "後")
            XCTAssertFalse(session.isActive)
        }
    }
}
