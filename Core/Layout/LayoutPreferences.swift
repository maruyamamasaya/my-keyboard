import Foundation

public enum KeyboardAlignment: String, Codable, CaseIterable, Sendable { case left, center, right }
public enum KeyboardTheme: String, Codable, CaseIterable, Sendable { case system, light, dark }
public struct LayoutProfile: Codable, Equatable, Sendable {
    public var height: Double = 340
    public var widthFraction: Double = 1
    public var spacing: Double = 5
    public var alignment: KeyboardAlignment = .center
    public init() {}
    public func sanitized() -> Self {
        var copy = self
        copy.height = height.isFinite ? min(420, max(320, height)) : 340
        copy.widthFraction = widthFraction.isFinite ? min(1, max(0.7, widthFraction)) : 1
        copy.spacing = spacing.isFinite ? min(12, max(0, spacing)) : 5
        return copy
    }
}
public struct KeyboardPreferences: Codable, Equatable, Sendable {
    public var portrait = LayoutProfile()
    public var landscape = LayoutProfile()
    public var theme: KeyboardTheme = .system
    public var learningEnabled = false
    public var learningResetID = UUID()
    public var clipboardEnabled = false
    public var clipboardLimit = 50
    public init() {}
    public func profile(landscape: Bool) -> LayoutProfile { (landscape ? self.landscape : portrait).sanitized() }
    public var safeClipboardLimit: Int { min(200, max(1, clipboardLimit)) }
}
