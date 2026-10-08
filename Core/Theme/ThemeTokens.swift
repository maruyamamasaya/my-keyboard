import Foundation

public struct ThemeTokens: Codable, Equatable, Sendable {
    public var background: String
    public var key: String
    public var text: String
    public var accent: String
    public var cornerRadius: Double = 10
    public var opacity: Double = 0.94
    public var borderWidth: Double = 1
    public var shadowOpacity: Double = 0.16
    public var stars: Bool = false
    public var dark: Bool = true
    public init(background: String, key: String, text: String, accent: String, stars: Bool = false, dark: Bool = true) {
        self.background = background; self.key = key; self.text = text; self.accent = accent
        self.stars = stars; self.dark = dark
    }
    public static func validColor(_ value: String) -> Bool {
        value.count == 7 && value.first == "#" && value.dropFirst().allSatisfy { $0.isASCII && $0.isHexDigit }
    }
    public func sanitized() -> Self {
        var result = self
        let fallback = ThemeCatalog.blueCosmos.tokens
        if !Self.validColor(background) { result.background = fallback.background }
        if !Self.validColor(key) { result.key = fallback.key }
        if !Self.validColor(text) { result.text = fallback.text }
        if !Self.validColor(accent) { result.accent = fallback.accent }
        func clamp(_ value: Double, _ range: ClosedRange<Double>, _ fallback: Double) -> Double {
            value.isFinite ? min(range.upperBound, max(range.lowerBound, value)) : fallback
        }
        result.cornerRadius = clamp(cornerRadius, 0...20, 10)
        result.opacity = clamp(opacity, 0.65...1, 0.94)
        result.borderWidth = clamp(borderWidth, 0...3, 1)
        result.shadowOpacity = clamp(shadowOpacity, 0...0.3, 0.16)
        return result
    }
    public var readable: Self {
        var value = sanitized()
        func channels(_ hex: String) -> [Double] {
            let rgb = UInt32(hex.dropFirst(), radix: 16) ?? 0
            return [Double((rgb >> 16) & 255) / 255, Double((rgb >> 8) & 255) / 255, Double(rgb & 255) / 255]
        }
        func luminance(_ rgb: [Double]) -> Double {
            let linear = rgb.map { $0 <= 0.04045 ? $0 / 12.92 : pow(($0 + 0.055) / 1.055, 2.4) }
            return linear[0] * 0.2126 + linear[1] * 0.7152 + linear[2] * 0.0722
        }
        let key = channels(value.key), background = channels(value.background)
        let surface = luminance(zip(key, background).map { $0.0 * value.opacity + $0.1 * (1 - value.opacity) })
        let keyLuminance = luminance(key)
        let text = luminance(channels(value.text))
        func ratio(_ a: Double, _ b: Double) -> Double { (max(a, b) + 0.05) / (min(a, b) + 0.05) }
        if ratio(surface, text) < 4.5 || ratio(keyLuminance, text) < 4.5 {
            value.opacity = 1
            value.text = (keyLuminance + 0.05) / 0.05 > 1.05 / (keyLuminance + 0.05) ? "#000000" : "#FFFFFF"
        }
        return value
    }
    public var canvasText: String {
        var surface = self; surface.key = background; surface.opacity = 1
        return surface.readable.text
    }
    public var canvasAccent: String {
        var surface = self; surface.key = background; surface.text = accent; surface.opacity = 1
        return surface.readable.text
    }
}

public struct ThemePreset: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let tokens: ThemeTokens
}

public enum ThemeCatalog {
    public static let blueCosmos = ThemePreset(id: "blue-cosmos", name: "Blue Cosmos", tokens:
        {
            var tokens: ThemeTokens = .init(background: "#080F26", key: "#203D68", text: "#F2F7FF", accent: "#70DEFF", stars: true)
            tokens.cornerRadius = 14; tokens.borderWidth = 1.2; tokens.shadowOpacity = 0.24
            return tokens
        }())
    public static let presets: [ThemePreset] = [blueCosmos,
        .init(id: "minimal-light", name: "Minimal Light", tokens: .init(background: "#E8EDF3", key: "#FFFFFF", text: "#152238", accent: "#2258A0", dark: false)),
        .init(id: "minimal-dark", name: "Minimal Dark", tokens: .init(background: "#14171D", key: "#2C323C", text: "#F4F6FA", accent: "#B9D5FF")),
        .init(id: "living-aurora", name: "Living Aurora", tokens: .init(background: "#101E25", key: "#243C43", text: "#F0FBFA", accent: "#A1E5D2")),
        .init(id: "pulse-neon", name: "Pulse Neon", tokens: .init(background: "#191329", key: "#332745", text: "#FCF2FF", accent: "#E6B0FF"))]
    public static func preset(_ id: String) -> ThemePreset { presets.first { $0.id == id } ?? blueCosmos }
}

/// Appearance is stored independently of input and orientation preferences.
public struct ThemeSelection: Codable, Equatable, Sendable {
    public var schemaVersion = 1
    public var presetID = "blue-cosmos"
    public var custom: ThemeTokens?
    public var imageName: String?
    public init() {}
    public var tokens: ThemeTokens {
        var value = custom ?? ThemeCatalog.preset(presetID).tokens
        let fixed = ThemeCatalog.blueCosmos.tokens
        value.cornerRadius = fixed.cornerRadius; value.opacity = fixed.opacity
        value.borderWidth = fixed.borderWidth; value.shadowOpacity = fixed.shadowOpacity
        value.stars = fixed.stars; value.dark = fixed.dark
        return value.readable
    }
    public var safeImageName: String? {
        guard let imageName, imageName.hasSuffix(".jpg"), UUID(uuidString: String(imageName.dropLast(4))) != nil else { return nil }
        return imageName
    }
    public static func migrating(_ legacy: KeyboardTheme) -> Self {
        var selection = Self()
        if legacy == .light { selection.presetID = "minimal-light" }
        if legacy == .dark { selection.presetID = "minimal-dark" }
        return selection
    }
}
