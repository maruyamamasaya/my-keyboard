import XCTest
@testable import KeyboardCore

final class CharacterCatalogTests: XCTestCase {
    func testCompoundEmojiAndCodeRemainSingleSelectableEntries() {
        XCTAssertTrue(CharacterCatalog.contains("🐻‍❄️", in: .emoji))
        XCTAssertTrue(CharacterCatalog.contains("🇯🇵", in: .emoji))
        XCTAssertTrue(CharacterCatalog.contains("👍🏽", in: .emoji))
        XCTAssertTrue(CharacterCatalog.contains("❤️‍🔥", in: .emoji))
        XCTAssertTrue(CharacterCatalog.contains("https://", in: .symbol))
        XCTAssertTrue(CharacterCatalog.contains("<!--", in: .symbol))
        XCTAssertFalse(CharacterCatalog.contains("", in: .emoji))
        for palette in CharacterPalette.allCases {
            let categories = CharacterCatalog.categories(for: palette)
            XCTAssertEqual(Set(categories.map(\.id)).count, categories.count)
            XCTAssertTrue(categories.allSatisfy { !$0.characters.isEmpty && !$0.characters.contains("") })
        }
    }
    func testRecentsDeduplicateOrderAndLimitWithoutBreakingSequences() {
        var recents = RecentCharacters(["👍🏽", "🇯🇵", "👍🏽", ""])
        XCTAssertEqual(recents.items, ["👍🏽", "🇯🇵"])
        recents.record("🇯🇵")
        XCTAssertEqual(recents.items, ["🇯🇵", "👍🏽"])
        for i in 0..<50 { recents.record("\(i)") }
        XCTAssertEqual(recents.items.count, 40)
        XCTAssertEqual(recents.items.first, "49")
        XCTAssertEqual(recents.items.last, "10")
        recents.record("")
        XCTAssertEqual(recents.items.count, 40)
    }
}
