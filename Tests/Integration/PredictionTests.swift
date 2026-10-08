import XCTest
import KeyboardCore

final class PredictionTests: XCTestCase {
    func testOfflinePredictionConversionAndUserDictionary() async {
        await MainActor.run {
            let engine = AzooKeyConversion(), preferences = KeyboardPreferences()
            let predicted = engine.candidates(for: "きょ", preferences: preferences, dictionary: [])
            XCTAssertTrue(predicted.contains(where: { $0.isPrediction }))
            XCTAssertTrue(predicted.contains(where: { !$0.isPrediction }))
            let normal = engine.candidates(for: "きょう", preferences: preferences, dictionary: [], prediction: false)
            XCTAssertTrue(normal.contains(where: { $0.text == "今日" }))
            XCTAssertFalse(normal.contains(where: { $0.isPrediction }))
            let custom = engine.candidates(for: "きょう", preferences: preferences,
                                           dictionary: [.init(reading: "きょう", text: "独自候補")])
            XCTAssertEqual(custom.first?.text, "独自候補")
            print("Offline conversion last latency (ms): \(engine.lastLatencyMilliseconds)")
            engine.close()
        }
    }
}
