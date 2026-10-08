import UIKit
import XCTest
import KeyboardCore

final class CharacterPickerTests: XCTestCase {
    @MainActor func testCategoriesInsertCompoundTextAndRecentsStaySeparated() throws {
        let picker = CharacterPickerView(palette: .emoji, tokens: ThemeCatalog.blueCosmos.tokens,
                                         emojiRecents: .init(), symbolRecents: .init())
        picker.frame = CGRect(x: 0, y: 0, width: 393, height: 208)
        picker.layoutIfNeeded()
        let host = UITextView(); host.text = "前後"; host.selectedRange = NSRange(location: 1, length: 0)
        picker.onSelect = { host.insertText($0) }
        func descendants<T: UIView>(_ view: UIView, _: T.Type) -> [T] {
            (view as? T).map { [$0] } ?? view.subviews.flatMap { descendants($0, T.self) }
        }
        let collection = try XCTUnwrap(descendants(picker, UICollectionView.self).first)
        func category(_ id: String) throws {
            let button = try XCTUnwrap(descendants(picker, UIButton.self).first { $0.accessibilityIdentifier == "character-category-\(id)" })
            button.sendActions(for: .touchUpInside); picker.layoutIfNeeded()
        }
        try category("nature")
        let bear = try XCTUnwrap(CharacterCatalog.emoji.first { $0.id == "nature" }?.characters.firstIndex(of: "🐻‍❄️"))
        collection.delegate?.collectionView?(collection, didSelectItemAt: IndexPath(item: bear, section: 0))
        XCTAssertEqual(host.text, "前🐻‍❄️後")
        try category("recent")
        XCTAssertEqual(collection.numberOfItems(inSection: 0), 1)
        XCTAssertEqual(collection.dataSource?.collectionView(collection, cellForItemAt: IndexPath(item: 0, section: 0)).accessibilityLabel, "🐻‍❄️")
        let tabs = try XCTUnwrap(descendants(picker, UISegmentedControl.self).first)
        tabs.selectedSegmentIndex = 1; tabs.sendActions(for: .valueChanged)
        try category("recent")
        XCTAssertEqual(collection.numberOfItems(inSection: 0), 0)
        try category("brackets")
        let pair = try XCTUnwrap(CharacterCatalog.symbols.first { $0.id == "brackets" }?.characters.firstIndex(of: "「」"))
        collection.delegate?.collectionView?(collection, didSelectItemAt: IndexPath(item: pair, section: 0))
        XCTAssertEqual(host.text, "前🐻‍❄️「」後")
        try category("recent")
        XCTAssertEqual(collection.numberOfItems(inSection: 0), 1)
        for width in [320.0, 393.0, 700.0] {
            picker.frame.size.width = width; picker.layoutIfNeeded()
            let itemSize = (collection.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collection, layout: collection.collectionViewLayout, sizeForItemAt: IndexPath(item: 0, section: 0))
            XCTAssertGreaterThanOrEqual(itemSize?.width ?? 0, 44)
            XCTAssertGreaterThanOrEqual(collection.bounds.height, 44)
        }
    }
    @MainActor func testControllerCanReturnFromBothPalettesAndKeepRecents() throws {
        let keyboard = KeyboardViewController(); keyboard.loadViewIfNeeded()
        keyboard.view.frame = CGRect(x: 0, y: 0, width: 393, height: 300)
        func descendants<T: UIView>(_ view: UIView, _: T.Type) -> [T] {
            (view as? T).map { [$0] } ?? view.subviews.flatMap { descendants($0, T.self) }
        }
        func tap(_ title: String) throws {
            let button = try XCTUnwrap(descendants(keyboard.view, UIButton.self).first { $0.accessibilityLabel == title })
            button.sendActions(for: .touchUpInside); keyboard.view.layoutIfNeeded()
        }
        func capture(_ name: String) {
            let image = UIGraphicsImageRenderer(bounds: keyboard.view.bounds).image { keyboard.view.layer.render(in: $0.cgContext) }
            let attachment = XCTAttachment(image: image); attachment.name = name; attachment.lifetime = .keepAlways
            add(attachment)
        }
        try tap("☺")
        XCTAssertEqual(descendants(keyboard.view, CharacterPickerView.self).count, 1)
        capture("emoji-picker")
        let emojiGrid = try XCTUnwrap(descendants(keyboard.view, UICollectionView.self).first)
        emojiGrid.delegate?.collectionView?(emojiGrid, didSelectItemAt: IndexPath(item: 0, section: 0))
        try tap("かな")
        XCTAssertEqual(descendants(keyboard.view, FlickButton.self).count, 12)
        try tap("☺")
        let recentButton = try XCTUnwrap(descendants(keyboard.view, UIButton.self).first { $0.accessibilityIdentifier == "character-category-recent" })
        recentButton.sendActions(for: .touchUpInside)
        let recentGrid = try XCTUnwrap(descendants(keyboard.view, UICollectionView.self).first)
        XCTAssertEqual(recentGrid.numberOfItems(inSection: 0), 1)
        XCTAssertEqual(recentGrid.dataSource?.collectionView(recentGrid, cellForItemAt: IndexPath(item: 0, section: 0)).accessibilityLabel, "😀")
        try tap("かな")
        try tap("記号")
        try tap("一覧")
        XCTAssertEqual(descendants(keyboard.view, CharacterPickerView.self).count, 1)
        try tap("記号キー")
        XCTAssertEqual(descendants(keyboard.view, FlickButton.self).count, 12)
        try tap("一覧")
        XCTAssertEqual(descendants(keyboard.view, CharacterPickerView.self).count, 1)
        capture("symbol-picker")
        XCTAssertNotNil(descendants(keyboard.view, UIButton.self).first { $0.accessibilityLabel == "次のキーボード" })
        XCTAssertNotNil(descendants(keyboard.view, UIButton.self).first { $0.accessibilityLabel == "キーボードを閉じる" })
    }
}
