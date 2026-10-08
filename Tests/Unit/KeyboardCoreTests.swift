import XCTest
@testable import KeyboardCore

final class KeyboardCoreTests: XCTestCase {
    func testPredictionIsSelectableWithoutCompletingLiveInput() {
        var state = Composition(); state.insert("きょ")
        let prediction = ConversionChoice("今日は", token: 0, isPrediction: true)
        state.apply([prediction, .init("巨", token: 1)], revision: state.revision)
        XCTAssertEqual(state.candidates.first, prediction)
        XCTAssertEqual(state.liveChoice.text, "巨")
        state.apply([prediction], revision: state.revision)
        XCTAssertEqual(state.liveChoice.text, "きょ")
    }
    func testCompositionEditsGraphemesAtCursor() {
        var state = Composition()
        XCTAssertTrue(state.insert("あ👨‍👩‍👧‍👦い"))
        state.moveCursor(-1)
        XCTAssertTrue(state.deleteBackward())
        XCTAssertEqual(state.reading, "あい")
        XCTAssertEqual(state.cursor, 1)
        state.insert("う")
        XCTAssertEqual(state.reading, "あうい")
    }
    func testStaleCandidatesAreRejectedAfterDeletion() {
        var state = Composition()
        state.insert("かき")
        let revision = state.revision
        state.deleteBackward()
        XCTAssertFalse(state.apply([.init("柿")], revision: revision))
        XCTAssertTrue(state.candidates.isEmpty)
    }
    func testInputCapAndCandidateDeduplication() {
        var state = Composition(maximumLength: 2)
        state.insert("かな")
        XCTAssertFalse(state.insert("あ"))
        XCTAssertTrue(state.apply([.init("仮名"), .init("仮名"), .init("")], revision: state.revision))
        XCTAssertEqual(state.candidates.map(\.text), ["仮名"])
        state.reset()
        XCTAssertEqual(state.cursor, 0)
        XCTAssertTrue(state.candidates.isEmpty)
    }
    func testKanaModificationAndScriptConversion() {
        var state = Composition()
        state.insert("は")
        state.modifyPreviousKana(); XCTAssertEqual(state.reading, "ば")
        state.modifyPreviousKana(); XCTAssertEqual(state.reading, "ぱ")
        state.modifyPreviousKana(); XCTAssertEqual(state.reading, "は")
        XCTAssertEqual(KanaModifier.katakana("がっこう ABC😀"), "ガッコウ ABC😀")
    }
    func testFlickThresholdAndEmptyDirection() {
        XCTAssertEqual(FlickMap.direction(dx: 2, dy: -10), .center)
        XCTAssertEqual(FlickMap.direction(dx: -30, dy: 5), .left)
        XCTAssertEqual(FlickMap.direction(dx: 0, dy: -30), .up)
        XCTAssertEqual(FlickMap.japanese[7].text(.left), "")
        XCTAssertEqual(FlickMap.japanese[0].text(.down), "お")
    }
    func testLayoutRejectsNonfiniteAndOutOfRangeValues() {
        var layout = LayoutProfile()
        layout.height = .nan; layout.spacing = 100; layout.widthFraction = 0
        let safe = layout.sanitized()
        XCTAssertEqual(safe.height, 340)
        XCTAssertEqual(safe.spacing, 3)
        XCTAssertEqual(safe.widthFraction, 1)
        var preferences = KeyboardPreferences()
        layout.alignment = .right
        preferences.portrait = layout; preferences.landscape = layout
        XCTAssertEqual(preferences.profile(landscape: false), LayoutProfile())
        XCTAssertEqual(preferences.profile(landscape: true), LayoutProfile())
    }
    func testReconversionRejectsChangedContextAndUnicode() {
        let snapshot = DocumentSnapshot(documentID: UUID(), before: "前漢字", after: "", selected: nil)
        let commit = RecentCommit(reading: "かんじ", text: "漢字", snapshot: snapshot)
        XCTAssertTrue(commit.canReplace(in: snapshot))
        var changed = snapshot; changed.after = "後"
        XCTAssertFalse(commit.canReplace(in: changed))
        changed = snapshot; changed.documentID = UUID()
        XCTAssertFalse(commit.canReplace(in: changed))
        changed = snapshot; changed.selected = "漢字"
        XCTAssertFalse(commit.canReplace(in: changed))
        changed = snapshot; changed.before = nil
        XCTAssertFalse(commit.canReplace(in: changed))
        let emoji = RecentCommit(reading: "えもじ", text: "😀", snapshot: snapshot)
        XCTAssertFalse(emoji.canReplace(in: snapshot))
    }
    func testClipboardBounds() {
        XCTAssertFalse(ClipboardPolicy.accepts(" \n"))
        XCTAssertFalse(ClipboardPolicy.accepts(String(repeating: "あ", count: 6000)))
        XCTAssertTrue(ClipboardPolicy.accepts("定型文"))
        var preferences = KeyboardPreferences(); preferences.clipboardLimit = -1
        XCTAssertEqual(preferences.safeClipboardLimit, 1)
    }
}
