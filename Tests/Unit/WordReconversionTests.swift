import XCTest
@testable import KeyboardCore

final class WordReconversionTests: XCTestCase {
    func testEditsOnlySelectedWordAndPreservesReading() throws {
        let parts: [ConversionSegment] = [.init(reading: "きょう", text: "今日"), .init(reading: "は", text: "は"), .init(reading: "はれ", text: "晴れ")]
        var editing = try XCTUnwrap(WordReconversion(reading: "きょうははれ", choice: .init("今日は晴れ", segments: parts)))
        editing.move(2); editing.choose("腫れ")
        XCTAssertEqual(editing.text, "今日は腫れ")
        XCTAssertEqual(editing.segments.map(\.reading).joined(), "きょうははれ")
        editing.move(-2); editing.choose("京")
        XCTAssertEqual(editing.text, "京は腫れ")
        XCTAssertEqual(editing.segments[1], parts[1])
    }
    func testInvalidBoundariesFallBackToWholeReading() throws {
        for parts in [[ConversionSegment(reading: "きょ", text: "今日")], [ConversionSegment(reading: "きょう", text: "別")]] {
            let editing = try XCTUnwrap(WordReconversion(reading: "きょう", choice: .init("今日", segments: parts)))
            XCTAssertEqual(editing.segments, [.init(reading: "きょう", text: "今日")])
        }
        XCTAssertNil(WordReconversion(reading: "", choice: .init("")))
    }
    func testSelectionClampsAndEmptyChoiceIsIgnored() throws {
        var editing = try XCTUnwrap(WordReconversion(reading: "あ", choice: .init("亜")))
        editing.move(-100); editing.move(100); editing.choose("")
        XCTAssertEqual(editing.selectedIndex, 0); XCTAssertEqual(editing.text, "亜")
        XCTAssertEqual(KanaModifier.hiragana("キョウ ABC😀"), "きょう ABC😀")
    }
    func testCandidateVisibilityMigrationPreservesOldPreferences() throws {
        var original = KeyboardPreferences(); original.learningEnabled = true; original.clipboardEnabled = true
        let encoded = try JSONEncoder().encode(original)
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        json.removeValue(forKey: "showsCandidates")
        let old = try JSONDecoder().decode(KeyboardPreferences.self, from: JSONSerialization.data(withJSONObject: json))
        XCTAssertTrue(old.showsCandidates); XCTAssertTrue(old.learningEnabled); XCTAssertTrue(old.clipboardEnabled)
        XCTAssertEqual(old.learningResetID, original.learningResetID)
        json["showsCandidates"] = false
        json.removeValue(forKey: "candidateVisibilityVersion")
        let migrated = try JSONDecoder().decode(KeyboardPreferences.self, from: JSONSerialization.data(withJSONObject: json))
        XCTAssertTrue(migrated.showsCandidates)
        original.showsCandidates = false
        XCTAssertEqual(try JSONDecoder().decode(KeyboardPreferences.self, from: JSONEncoder().encode(original)), original)
    }
}
