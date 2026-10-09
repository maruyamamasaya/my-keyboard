import Foundation

public enum KeyboardAlignment: String, Codable, CaseIterable, Sendable { case left, center, right }
public enum KeyboardTheme: String, Codable, CaseIterable, Sendable { case system, light, dark }
public struct LayoutProfile: Codable, Equatable, Sendable {
    public var height: Double = 300
    public var widthFraction: Double = 1
    public var spacing: Double = 3
    public var alignment: KeyboardAlignment = .center
    public init() {}
    public func sanitized() -> Self {
        // Retain stored fields for decoding old preferences; presentation is fixed.
        Self()
    }
}
public struct KeyboardPreferences: Codable, Equatable, Sendable {
    public var portrait = LayoutProfile()
    public var landscape = LayoutProfile()
    public var theme: KeyboardTheme = .system
    public var showsCandidates = true
    public var hapticsEnabled = true
    private var candidateVisibilityVersion = 2
    public var learningEnabled = false
    public var learningResetID = UUID()
    public var clipboardEnabled = false
    public var clipboardLimit = 50
    public init() {}
    private enum CodingKeys: String, CodingKey {
        case portrait, landscape, theme, showsCandidates, hapticsEnabled, candidateVisibilityVersion, learningEnabled, learningResetID, clipboardEnabled, clipboardLimit
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        portrait = try values.decodeIfPresent(LayoutProfile.self, forKey: .portrait) ?? .init()
        landscape = try values.decodeIfPresent(LayoutProfile.self, forKey: .landscape) ?? .init()
        theme = try values.decodeIfPresent(KeyboardTheme.self, forKey: .theme) ?? .system
        // Reset the previous hidden default once; preserve explicit choices after migration.
        let visibilityVersion = try values.decodeIfPresent(Int.self, forKey: .candidateVisibilityVersion) ?? 1
        showsCandidates = visibilityVersion >= 2 ? (try values.decodeIfPresent(Bool.self, forKey: .showsCandidates) ?? true) : true
        hapticsEnabled = try values.decodeIfPresent(Bool.self, forKey: .hapticsEnabled) ?? true
        learningEnabled = try values.decodeIfPresent(Bool.self, forKey: .learningEnabled) ?? false
        learningResetID = try values.decodeIfPresent(UUID.self, forKey: .learningResetID) ?? UUID()
        clipboardEnabled = try values.decodeIfPresent(Bool.self, forKey: .clipboardEnabled) ?? false
        clipboardLimit = try values.decodeIfPresent(Int.self, forKey: .clipboardLimit) ?? 50
    }
    public func profile(landscape: Bool) -> LayoutProfile { (landscape ? self.landscape : portrait).sanitized() }
    public var safeClipboardLimit: Int { min(200, max(1, clipboardLimit)) }
}

/// Shared geometry for the extension and the app's native preview.
public enum KeyboardGeometry {
    public static let topInset: Double = 4
    public static let bottomInset: Double = 4
    public static let candidateHeight: Double = 32
    public static let toolbarHeight: Double = 36
    public static let headerHeight = candidateHeight + toolbarHeight
    public static let sectionSpacing: Double = 4
}
