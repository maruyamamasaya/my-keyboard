import Foundation

public struct ConversionChoice: Equatable, Sendable {
    public let text: String
    public let token: Int?
    public let isPrediction: Bool
    public let segments: [ConversionSegment]
    public init(_ text: String, token: Int? = nil, segments: [ConversionSegment] = [], isPrediction: Bool = false) {
        self.text = text; self.token = token; self.segments = segments; self.isPrediction = isPrediction
    }
}

public struct Composition: Sendable {
    public private(set) var reading = ""
    public private(set) var cursor = 0
    public private(set) var revision: UInt64 = 0
    public private(set) var candidates: [ConversionChoice] = []
    public var liveChoice: ConversionChoice { candidates.first(where: { !$0.isPrediction }) ?? .init(reading) }
    public let maximumLength: Int
    public init(maximumLength: Int = 128) { self.maximumLength = max(1, maximumLength) }

    private mutating func changed() { revision &+= 1; candidates = [] }
    @discardableResult public mutating func insert(_ text: String) -> Bool {
        guard !text.isEmpty, reading.count + text.count <= maximumLength else { return false }
        let index = reading.index(reading.startIndex, offsetBy: cursor)
        reading.insert(contentsOf: text, at: index)
        cursor += text.count
        changed()
        return true
    }
    @discardableResult public mutating func deleteBackward() -> Bool {
        guard cursor > 0 else { return false }
        let index = reading.index(reading.startIndex, offsetBy: cursor - 1)
        reading.remove(at: index)
        cursor -= 1
        changed()
        return true
    }
    public mutating func moveCursor(_ offset: Int) {
        let next = min(reading.count, max(0, cursor + offset))
        guard next != cursor else { return }
        cursor = next
        changed()
    }
    public mutating func modifyPreviousKana() {
        guard cursor > 0 else { return }
        let index = reading.index(reading.startIndex, offsetBy: cursor - 1)
        guard let replacement = KanaModifier.next(reading[index]) else { return }
        reading.replaceSubrange(index...index, with: String(replacement))
        changed()
    }
    @discardableResult public mutating func apply(_ choices: [ConversionChoice], revision: UInt64) -> Bool {
        guard revision == self.revision, !reading.isEmpty else { return false }
        var seen = Set<String>()
        candidates = choices.filter { !$0.text.isEmpty && seen.insert($0.text).inserted }
        return true
    }
    public mutating func reset() { reading = ""; cursor = 0; changed() }
}

public enum KanaModifier {
    private static let cycles = ["あぁ", "いぃ", "うぅゔ", "えぇ", "おぉ", "かが", "きぎ", "くぐ", "けげ", "こご",
        "さざ", "しじ", "すず", "せぜ", "そぞ", "ただ", "ちぢ", "つっづ", "てで", "とど",
        "はばぱ", "ひびぴ", "ふぶぷ", "へべぺ", "ほぼぽ", "やゃ", "ゆゅ", "よょ", "わゎ"]
    public static func next(_ character: Character) -> Character? {
        for cycle in cycles {
            let chars = Array(cycle)
            if let index = chars.firstIndex(of: character) { return chars[(index + 1) % chars.count] }
        }
        return nil
    }
    public static func hiragana(_ text: String) -> String {
        String(String.UnicodeScalarView(text.unicodeScalars.map { scalar in
            (0x30A1...0x30F6).contains(scalar.value) ? UnicodeScalar(scalar.value - 0x60)! : scalar
        }))
    }
    public static func katakana(_ text: String) -> String {
        String(String.UnicodeScalarView(text.unicodeScalars.map { scalar in
            (0x3041...0x3096).contains(scalar.value) ? UnicodeScalar(scalar.value + 0x60)! : scalar
        }))
    }
}
