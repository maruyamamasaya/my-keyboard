import Foundation
import KeyboardCore
import KanaKanjiConverterModuleWithDefaultDictionary

// API audited against v0.8.5 / 8278b6b76e534f1a08e4db2a11602f499d754327.
@MainActor final class AzooKeyConversion {
    private var converter = KanaKanjiConverter()
    private var engineCandidates: [Candidate] = []
    private var learningDirectory: URL
    private var learningAvailable = true
    private var resetID: UUID?
    private(set) var lastLatencyMilliseconds: Double = 0

    init() {
        resetID = UserDefaults.standard.string(forKey: "learning.reset-id").flatMap(UUID.init(uuidString:))
        learningDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ConversionLearning", isDirectory: true)
        do { try SharedContainer.preparePrivateDirectory(learningDirectory) }
        catch { learningAvailable = false }
    }
    func candidates(for reading: String, preferences: KeyboardPreferences, dictionary: [DictionaryEntry], prediction: Bool = true) -> [ConversionChoice] {
        guard !reading.isEmpty else { return [] }
        if resetID != preferences.learningResetID {
            converter.stopComposition()
            converter = KanaKanjiConverter()
            do {
                // Delete only our explicitly owned learning directory, not the group container.
                if FileManager.default.fileExists(atPath: learningDirectory.path) {
                    try FileManager.default.removeItem(at: learningDirectory)
                }
                try SharedContainer.preparePrivateDirectory(learningDirectory)
                learningAvailable = true
                resetID = preferences.learningResetID
                UserDefaults.standard.set(preferences.learningResetID.uuidString, forKey: "learning.reset-id")
            } catch { learningAvailable = false }
        }
        var input = ComposingText()
        input.insertAtCursorPosition(reading, inputStyle: .direct)
        let start = ProcessInfo.processInfo.systemUptime
        let options = ConvertRequestOptions.withDefaultDictionary(
            N_best: 10, requireJapanesePrediction: prediction, requireEnglishPrediction: false,
            keyboardLanguage: .ja_JP, learningType: preferences.learningEnabled && learningAvailable ? .inputAndOutput : .nothing,
            maxMemoryCount: 4096, memoryDirectoryURL: learningDirectory,
            sharedContainerURL: learningDirectory, metadata: .init(versionString: "MyKeyboard 0.1")
        )
        let results = converter.requestCandidates(input, options: options)
        // Full-reading candidates only: partial clauses must not replace the entire reading.
        engineCandidates = Array(results.mainResults.filter {
            $0.inputable && $0.correspondingCount == input.input.count && $0.actions.isEmpty
        }.prefix(10))
        lastLatencyMilliseconds = (ProcessInfo.processInfo.systemUptime - start) * 1000
        let custom = dictionary.filter { $0.reading == reading }.map { ConversionChoice($0.text) }
        let engine = engineCandidates.enumerated().map { index, candidate in
            let segments = candidate.data.map { ConversionSegment(reading: KanaModifier.hiragana($0.ruby), text: $0.word) }
            return ConversionChoice(candidate.text, token: index, segments: segments, isPrediction: segments.map(\.reading).joined() != reading)
        }
        return custom + engine + [.init(reading), .init(KanaModifier.katakana(reading))]
    }
    func commit(_ choice: ConversionChoice, learning: Bool) {
        if let token = choice.token, engineCandidates.indices.contains(token) {
            let candidate = engineCandidates[token]
            if learning && learningAvailable {
                converter.updateLearningData(candidate)
                converter.sendToDicdataStore(.closeKeyboard)
            }
        }
        reset()
    }
    func reset() { converter.stopComposition(); engineCandidates = [] }
    func close() { converter.sendToDicdataStore(.closeKeyboard); reset() }
}
