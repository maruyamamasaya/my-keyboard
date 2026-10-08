import Foundation

public struct ConversionSegment: Equatable, Sendable {
    public let reading: String
    public var text: String
    public init(reading: String, text: String) { self.reading = reading; self.text = text }
}

/// Edits only a validated segment of the still-uncommitted reading.
public struct WordReconversion: Equatable, Sendable {
    public private(set) var segments: [ConversionSegment]
    public private(set) var selectedIndex = 0
    public var text: String { segments.map(\.text).joined() }
    public var selected: ConversionSegment { segments[selectedIndex] }
    public init?(reading: String, choice: ConversionChoice) {
        guard !reading.isEmpty else { return nil }
        let parts = choice.segments
        if !parts.isEmpty && parts.allSatisfy({ !$0.reading.isEmpty && !$0.text.isEmpty }) &&
            parts.map(\.reading).joined() == reading && parts.map(\.text).joined() == choice.text {
            segments = parts
        } else {
            // Unknown boundaries stay a single segment; never guess a destructive range.
            segments = [.init(reading: reading, text: choice.text.isEmpty ? reading : choice.text)]
        }
    }
    public mutating func move(_ offset: Int) { selectedIndex = min(segments.count - 1, max(0, selectedIndex + offset)) }
    public mutating func choose(_ text: String) {
        guard !text.isEmpty else { return }; segments[selectedIndex].text = text
    }
}
