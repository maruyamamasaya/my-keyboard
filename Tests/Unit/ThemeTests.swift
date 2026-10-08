import XCTest
@testable import KeyboardCore

final class ThemeTests: XCTestCase {
    func testWindowsThemesRetainPresetShapeWithCustomColors() {
        let presets = ThemeCatalog.presets.filter { $0.id.hasPrefix("windows-") }
        XCTAssertEqual(presets.count, 4)
        for preset in presets {
            var selection = ThemeSelection(); selection.presetID = preset.id
            XCTAssertEqual(selection.tokens.cornerRadius, preset.tokens.cornerRadius)
            XCTAssertFalse(selection.tokens.stars)
            var custom = preset.tokens; custom.cornerRadius = 20; custom.background = "#000000"
            selection.custom = custom
            XCTAssertEqual(selection.tokens.cornerRadius, preset.tokens.cornerRadius)
            XCTAssertEqual(selection.tokens.background, "#000000")
        }
    }
    func testDefaultMigrationAndUnknownPreset() {
        XCTAssertEqual(ThemeSelection().presetID, "blue-cosmos")
        XCTAssertEqual(ThemeSelection.migrating(.system).presetID, "blue-cosmos")
        XCTAssertEqual(ThemeSelection.migrating(.light).presetID, "minimal-light")
        XCTAssertEqual(ThemeSelection.migrating(.dark).presetID, "minimal-dark")
        XCTAssertEqual(ThemeCatalog.preset("future-theme"), ThemeCatalog.blueCosmos)
    }
    func testAppearanceRoundTripDoesNotChangeLayout() throws {
        var preferences = KeyboardPreferences(); preferences.portrait.alignment = .left
        let before = preferences
        var selection = ThemeSelection(); selection.presetID = "pulse-neon"; selection.custom = ThemeCatalog.blueCosmos.tokens
        let decoded = try JSONDecoder().decode(ThemeSelection.self, from: JSONEncoder().encode(selection))
        XCTAssertEqual(decoded, selection); XCTAssertEqual(preferences, before)
        let old = try JSONDecoder().decode(KeyboardPreferences.self, from: JSONEncoder().encode(preferences))
        XCTAssertEqual(old, before)
    }
    func testInvalidValuesAndContrastAreSafe() {
        var tokens = ThemeCatalog.blueCosmos.tokens
        tokens.background = "url(remote)"; tokens.cornerRadius = .infinity; tokens.opacity = .nan
        tokens.key = "#FFFFFF"; tokens.text = "#FFFFFF"
        let safe = tokens.readable
        XCTAssertEqual(safe.background, ThemeCatalog.blueCosmos.tokens.background); XCTAssertEqual(safe.cornerRadius, 10)
        XCTAssertEqual(safe.opacity, 1); XCTAssertEqual(safe.text, "#000000")
        tokens.key = "#000000"; tokens.background = "#FFFFFF"; tokens.opacity = 0.65; tokens.text = "#000000"
        XCTAssertEqual(tokens.readable.text, "#FFFFFF"); XCTAssertEqual(tokens.readable.opacity, 1)
    }
    func testKeyExpressionIsFixedWhileColorsRemainEditable() {
        var selection = ThemeSelection()
        var custom = ThemeCatalog.blueCosmos.tokens
        custom.cornerRadius = 0; custom.shadowOpacity = 0; custom.stars = false
        custom.accent = "#FF99CC"; selection.custom = custom
        XCTAssertEqual(selection.tokens.cornerRadius, ThemeCatalog.blueCosmos.tokens.cornerRadius)
        XCTAssertEqual(selection.tokens.shadowOpacity, ThemeCatalog.blueCosmos.tokens.shadowOpacity)
        XCTAssertTrue(selection.tokens.stars)
        XCTAssertEqual(selection.tokens.accent, "#FF99CC")
    }
    func testImageReferencesCannotEscapeStorage() {
        var selection = ThemeSelection()
        for name in ["../photo.jpg", "/tmp/photo.jpg", "https://example.com/a.jpg", "a.png", "photo.jpg"] {
            selection.imageName = name; XCTAssertNil(selection.safeImageName)
        }
        let name = UUID().uuidString + ".jpg"; selection.imageName = name
        XCTAssertEqual(selection.safeImageName, name)
    }
}
