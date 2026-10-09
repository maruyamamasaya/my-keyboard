import XCTest
import KeyboardCore

final class ThemeStoreTests: XCTestCase {
    func testMissingCorruptAndFutureSchemaFallback() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = ThemeStore(directory: directory)
        XCTAssertEqual(store.load().presetID, "blue-cosmos")
        var selection = ThemeSelection(); selection.presetID = "minimal-light"
        try store.save(selection); XCTAssertEqual(store.load(), selection)
        try Data("broken".utf8).write(to: directory.appendingPathComponent("selection.json"))
        XCTAssertEqual(store.load(legacy: .dark).presetID, "minimal-dark")
        for retired in ["living-aurora", "pulse-neon", "windows-7"] {
            selection.presetID = retired
            selection.custom = ThemeCatalog.blueCosmos.tokens
            try store.save(selection)
            XCTAssertEqual(store.load().presetID, "blue-cosmos")
            XCTAssertEqual(store.load().custom, selection.custom)
        }
        selection.schemaVersion = 2; try store.save(selection)
        XCTAssertEqual(store.load().presetID, "blue-cosmos")
    }
    func testOversizedImagesAndOwnedCleanup() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = ThemeStore(directory: directory)
        XCTAssertThrowsError(try store.saveImage(Data(count: 1_048_577)))
        var selection = ThemeSelection(); selection.imageName = try store.saveImage(Data([1, 2]))
        let old = try store.saveImage(Data([3]))
        let foreign = directory.appendingPathComponent("unowned.jpg"); try Data([4]).write(to: foreign)
        try store.save(selection); try store.removeUnusedImages(keeping: selection)
        XCTAssertEqual(store.imageData(store.load()), Data([1, 2]))
        XCTAssertFalse(FileManager.default.fileExists(atPath: directory.appendingPathComponent(old).path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: foreign.path))
    }
}
