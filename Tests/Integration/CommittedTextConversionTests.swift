import UIKit
import XCTest
import KeyboardCore

@MainActor private final class CommittedHostProxy: NSObject, UITextDocumentProxy {
    let field = UITextView()
    var documentIdentifier = UUID()
    var documentInputMode: UITextInputMode? { nil }
    var hasText: Bool { field.hasText }
    var documentContextBeforeInput: String? { (field.text as NSString).substring(to: field.selectedRange.location) }
    var documentContextAfterInput: String? { (field.text as NSString).substring(from: NSMaxRange(field.selectedRange)) }
    var selectedText: String? {
        field.selectedRange.length == 0 ? nil : (field.text as NSString).substring(with: field.selectedRange)
    }
    func insertText(_ text: String) { field.insertText(text) }
    func deleteBackward() { field.deleteBackward() }
    func setMarkedText(_ text: String, selectedRange: NSRange) { field.setMarkedText(text, selectedRange: selectedRange) }
    func unmarkText() { field.unmarkText() }
    func adjustTextPosition(byCharacterOffset offset: Int) {
        field.selectedRange = NSRange(location: max(0, min((field.text as NSString).length, field.selectedRange.location + offset)), length: 0)
    }
}

@MainActor private final class CommittedKeyboard: KeyboardViewController {
    let hostProxy = CommittedHostProxy()
    override var textDocumentProxy: any UITextDocumentProxy { hostProxy }
}

final class CommittedTextConversionTests: XCTestCase {
    @MainActor private func buttons(in view: UIView) -> [UIButton] {
        (view as? UIButton).map { [$0] } ?? view.subviews.flatMap { buttons(in: $0) }
    }
    @MainActor private func tap(_ title: String, on keyboard: CommittedKeyboard) throws {
        let key = try XCTUnwrap(buttons(in: keyboard.view).first { $0.accessibilityLabel == title })
        key.sendActions(for: .touchUpInside)
    }
    @MainActor func testToolbarConvertsSelectionAndCursorWordAndSelectsKanjiCandidate() throws {
        let keyboard = CommittedKeyboard(); keyboard.loadViewIfNeeded()
        let host = keyboard.hostProxy.field
        host.text = "前😀今日後"; host.selectedRange = NSRange(location: 3, length: 2)
        try tap("かな変換", on: keyboard)
        XCTAssertEqual(host.text, "前😀きょう後")
        try tap("カナ変換", on: keyboard)
        XCTAssertEqual(host.text, "前😀キョウ後")
        try tap("ローマ字変換", on: keyboard)
        XCTAssertEqual(host.text, "前😀kyou後")
        host.text = "前きょう後"; host.selectedRange = NSRange(location: 4, length: 0)
        try tap("再変換", on: keyboard)
        XCTAssertEqual(host.text, "前きょう後")
        try tap("今日", on: keyboard)
        XCTAssertEqual(host.text, "前今日後")
    }
    @MainActor func testToolbarCancelAndFocusChangeDoNotApplyOldCandidates() throws {
        let keyboard = CommittedKeyboard(); keyboard.loadViewIfNeeded()
        let host = keyboard.hostProxy.field
        host.text = "前きょう後"; host.selectedRange = NSRange(location: 1, length: 3)
        try tap("再変換", on: keyboard)
        try tap("取消", on: keyboard)
        XCTAssertEqual(host.text, "前きょう後")
        XCTAssertEqual(host.selectedRange, NSRange(location: 1, length: 3))
        try tap("再変換", on: keyboard)
        let oldCandidate = try XCTUnwrap(buttons(in: keyboard.view).first { $0.accessibilityLabel == "今日" })
        host.selectedRange = NSRange(location: 0, length: 1)
        keyboard.textDidChange(nil)
        oldCandidate.sendActions(for: .touchUpInside)
        XCTAssertEqual(host.text, "前きょう後")
        XCTAssertEqual(host.selectedRange, NSRange(location: 0, length: 1))
    }

    @MainActor func testPaletteSwitchKeepsMarkedTextAndCanContinueTyping() throws {
        let keyboard = CommittedKeyboard(); keyboard.loadViewIfNeeded()
        keyboard.view.frame = CGRect(x: 0, y: 0, width: 393, height: 300)
        let host = keyboard.hostProxy.field
        host.text = "前"; host.selectedRange = NSRange(location: 1, length: 0)
        func flicks(_ view: UIView) -> [FlickButton] {
            (view as? FlickButton).map { [$0] } ?? view.subviews.flatMap { flicks($0) }
        }
        let key = try XCTUnwrap(flicks(keyboard.view).first { $0.key.label == "か" })
        key.onCommit?("か")
        let text = host.text; let selection = host.selectedRange
        XCTAssertNotNil(host.markedTextRange)
        try tap("カラーパレット", on: keyboard)
        let choice = try XCTUnwrap(buttons(in: keyboard.view).first { $0.accessibilityIdentifier == "keyboard-palette-" + ThemeCatalog.presets[1].id })
        choice.sendActions(for: .touchUpInside)
        XCTAssertEqual(host.text, text); XCTAssertEqual(host.selectedRange, selection)
        XCTAssertNotNil(host.markedTextRange)
        XCTAssertEqual(keyboard.view.backgroundColor, UIColor(themeHex: ThemeCatalog.presets[1].tokens.background))
        try tap("かな変換", on: keyboard)
        XCTAssertEqual(host.text, "前か"); XCTAssertNil(host.markedTextRange)
        try tap("カラーパレット", on: keyboard)
        try tap("キーボードに戻る", on: keyboard)
        XCTAssertEqual(host.text, "前か")
    }

    @MainActor func testJapaneseReadingsAndWordBoundaryPreserveOtherScripts() {
        XCTAssertEqual(CommittedTextReader.reading("今日"), "きょう")
        XCTAssertEqual(CommittedTextReader.reading("銀行"), "ぎんこう")
        XCTAssertEqual(CommittedTextReader.reading("カナ ABC😀"), "かな ABC😀")
        XCTAssertEqual(CommittedTextReader.reading("今日は"), "きょうは")
        XCTAssertEqual(CommittedTextReader.wordBeforeCursor("今日は銀行"), "銀行")
        XCTAssertEqual(CommittedTextReader.wordBeforeCursor("きょう"), "きょう")
        XCTAssertEqual(CommittedTextReader.wordBeforeCursor("前😀キョウ"), "キョウ")
        XCTAssertEqual(CommittedTextReader.wordBeforeCursor("前コンピューター"), "コンピューター")
        XCTAssertNil(CommittedTextReader.wordBeforeCursor("銀行 "))
        XCTAssertNil(CommittedTextReader.wordBeforeCursor(""))
    }
    @MainActor func testSelectedAndCursorWordConversionsInUIKit() throws {
        let proxy = CommittedHostProxy(), adapter = DocumentProxyAdapter(proxy: proxy)
        proxy.field.text = "前😀今日後"; proxy.field.selectedRange = NSRange(location: 3, length: 2)
        let selected = try XCTUnwrap(CommittedTextTarget(snapshot: adapter.snapshot))
        let reading = try XCTUnwrap(CommittedTextReader.reading(selected.text))
        XCTAssertTrue(selected.replace(with: reading, using: adapter))
        XCTAssertEqual(proxy.field.text, "前😀きょう後")
        let suffix = try XCTUnwrap(CommittedTextReader.wordBeforeCursor(adapter.snapshot.before ?? ""))
        let target = try XCTUnwrap(CommittedTextTarget(snapshot: adapter.snapshot, suffix: suffix))
        XCTAssertEqual(target.text, "きょう")
        XCTAssertTrue(target.replace(with: KanaModifier.katakana(reading), using: adapter))
        XCTAssertEqual(proxy.field.text, "前😀キョウ後")
        let katakana = try XCTUnwrap(CommittedTextTarget(snapshot: adapter.snapshot, suffix: "キョウ"))
        XCTAssertTrue(katakana.replace(with: KanaModifier.romaji(reading), using: adapter))
        XCTAssertEqual(proxy.field.text, "前😀kyou後")
    }
    @MainActor func testCandidatePreviewAndCancellationLeaveTextUntouchedAndStaleTargetIsRejected() throws {
        let proxy = CommittedHostProxy(), adapter = DocumentProxyAdapter(proxy: proxy)
        proxy.field.text = "前きょう後"; proxy.field.selectedRange = NSRange(location: 1, length: 3)
        let target = try XCTUnwrap(CommittedTextTarget(snapshot: adapter.snapshot))
        let conversion = AzooKeyConversion()
        let choices = conversion.candidates(for: target.text, preferences: .init(), dictionary: [], prediction: false)
        XCTAssertTrue(choices.contains { $0.text == "今日" })
        XCTAssertEqual(proxy.field.text, "前きょう後")
        XCTAssertEqual(proxy.field.selectedRange, NSRange(location: 1, length: 3))
        conversion.reset() // Cancel preview: the captured selection has never been edited.
        XCTAssertEqual(proxy.field.text, "前きょう後")
        proxy.field.selectedRange = NSRange(location: 0, length: 1)
        XCTAssertFalse(target.replace(with: "今日", using: adapter))
        XCTAssertEqual(proxy.field.text, "前きょう後")
    }
}
