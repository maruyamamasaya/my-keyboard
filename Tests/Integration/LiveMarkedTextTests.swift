import UIKit
import XCTest
import KeyboardCore

@MainActor private final class TextViewClient: LiveTextClient {
    let view = UITextView()
    let documentID = UUID()
    var snapshot: DocumentSnapshot {
        let text = view.text ?? ""
        let range = view.selectedRange
        let value = text as NSString
        return .init(documentID: documentID,
                     before: value.substring(to: min(range.location, value.length)),
                     after: value.substring(from: min(NSMaxRange(range), value.length)),
                     selected: range.length == 0 ? nil : value.substring(with: range))
    }
    func setMarkedText(_ text: String, selectedRange: NSRange) { view.setMarkedText(text, selectedRange: selectedRange) }
    func unmarkText() { view.unmarkText() }
    init() { view.text = "前後"; view.selectedRange = NSRange(location: 1, length: 0) }
}
final class LiveMarkedTextTests: XCTestCase {
    func testUIKitMarkedConversionAndCommitPreserveSurroundingText() async {
        await MainActor.run {
            let client = TextViewClient(), session = LiveTextSession()
            XCTAssertTrue(session.update("きょう", cursorUTF16: 3, using: client))
            XCTAssertNotNil(client.view.markedTextRange)
            XCTAssertTrue(session.update("今日", cursorUTF16: 2, using: client))
            XCTAssertEqual(client.view.text, "前今日後")
            XCTAssertTrue(session.finish("今日は", using: client))
            XCTAssertEqual(client.view.text, "前今日は後")
            XCTAssertNil(client.view.markedTextRange)
        }
    }
    func testWordCorrectionChangesOnlyUncommittedSegment() async throws {
        try await MainActor.run {
            let client = TextViewClient(), session = LiveTextSession()
            let segments: [ConversionSegment] = [.init(reading: "きょう", text: "今日"), .init(reading: "は", text: "は"), .init(reading: "はれ", text: "晴れ")]
            var words = try XCTUnwrap(WordReconversion(reading: "きょうははれ", choice: .init("今日は晴れ", segments: segments)))
            session.update(words.text, cursorUTF16: words.text.utf16.count, using: client)
            words.move(2); words.choose("腫れ")
            XCTAssertTrue(session.update(words.text, cursorUTF16: words.text.utf16.count, using: client))
            XCTAssertEqual(client.view.text, "前今日は腫れ後")
            XCTAssertTrue(session.finish(words.text, using: client))
            XCTAssertEqual(client.view.text, "前今日は腫れ後")
            XCTAssertNil(client.view.markedTextRange)
        }
    }
    func testTwentyMarkedSessionsCommitWithoutCarryover() async {
        await MainActor.run {
            let client = TextViewClient(), session = LiveTextSession()
            for cycle in 1...20 {
                XCTAssertTrue(session.update("きょう", cursorUTF16: 3, using: client))
                XCTAssertTrue(session.update("今日", cursorUTF16: 2, using: client))
                XCTAssertTrue(session.finish("今日", using: client))
                XCTAssertFalse(session.isActive)
                XCTAssertNil(client.view.markedTextRange)
                XCTAssertEqual(client.view.text, "前" + String(repeating: "今日", count: cycle) + "後")
            }
        }
    }
    func testUIKitCancellationRemovesOnlyOwnedMarkedText() async {
        await MainActor.run {
            let client = TextViewClient(), session = LiveTextSession()
            session.update("あ😀", cursorUTF16: 3, using: client)
            XCTAssertEqual(client.view.text, "前あ😀後")
            session.cancel(using: client)
            XCTAssertEqual(client.view.text, "前後")
            XCTAssertNil(client.view.markedTextRange)
        }
    }
}
