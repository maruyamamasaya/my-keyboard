import SwiftUI
import UIKit
import KeyboardCore

extension UIColor {
    convenience init(themeHex: String) {
        let number = UInt32(themeHex.dropFirst(), radix: 16) ?? 0
        self.init(red: CGFloat((number >> 16) & 255) / 255, green: CGFloat((number >> 8) & 255) / 255,
                  blue: CGFloat(number & 255) / 255, alpha: 1)
    }
}
extension Color {
    init(themeHex: String) { self.init(uiColor: UIColor(themeHex: themeHex)) }
}

enum KeyboardKeyRole { case character, utility, toolbar, candidate, primary }

final class KeyboardActionButton: UIButton {
    var keyRole: KeyboardKeyRole = .utility
    private let sheen = CAGradientLayer()
    private let bevel = DesktopBevel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        sheen.isHidden = true
        layer.insertSublayer(sheen, at: 0)
        layer.addSublayer(bevel)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func setClassic(_ visible: Bool, pressed: Bool) { bevel.isHidden = !visible; bevel.pressed = pressed }
    func setSheen(_ visible: Bool, style: DesktopStyle?) {
        sheen.isHidden = !visible
        sheen.locations = nil
        sheen.colors = [UIColor.white.withAlphaComponent(0.22).cgColor, UIColor.white.withAlphaComponent(0).cgColor]
        sheen.startPoint = CGPoint(x: 0, y: 0); sheen.endPoint = CGPoint(x: 1, y: 1)
        DesktopSurface.configure(sheen, style: style)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin(); CATransaction.setDisableActions(true)
        bevel.frame = bounds; bevel.setNeedsLayout()
        sheen.frame = bounds; sheen.cornerRadius = layer.cornerRadius
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        CATransaction.commit()
    }
}

/// Distinct surfaces communicate typing, switching and the main action.
enum KeyboardKeyStyle {
    private static func foreground(on key: String, tokens: ThemeTokens) -> String {
        let keyRGB = UInt32(key.dropFirst(), radix: 16) ?? 0
        let canvasRGB = UInt32(tokens.background.dropFirst(), radix: 16) ?? 0
        let channels = [16, 8, 0].map { shift in
            Int((Double((keyRGB >> shift) & 255) * tokens.opacity + Double((canvasRGB >> shift) & 255) * (1 - tokens.opacity)).rounded())
        }
        var composite = tokens
        composite.key = String(format: "#%02X%02X%02X", channels[0], channels[1], channels[2])
        composite.opacity = 1; composite.text = "#FFFFFF"
        return composite.readable.text
    }
    static func apply(_ control: UIView, tokens: ThemeTokens, pressed: Bool = false, strong: Bool = false) {
        let role = (control as? KeyboardActionButton)?.keyRole ?? .character
        var surface = tokens
        if role == .primary {
            surface.key = tokens.accent == ThemeCatalog.blueCosmos.tokens.accent ? "#176BFF" : tokens.accent
            surface.opacity = tokens.opacity
            surface.text = foreground(on: surface.key, tokens: tokens)
        } else if role == .utility && tokens.desktopStyle == nil {
            surface.key = tokens.background; surface.opacity = tokens.opacity; surface = surface.readable
        }
        if tokens.desktopStyle == .gameboyShell, role == .utility {
            surface.key = "#414247"; surface.text = "#FAF9F2"
        }
        if (tokens.desktopStyle == .superfamicom || tokens.desktopStyle == .superfamicomShell), role == .utility,
           let title = (control as? UIButton)?.accessibilityLabel,
           let color = ["記号": "#2467BD", "一覧": "#2467BD", "☆123": "#2467BD", "123": "#E8BB32", "あA": "#20894F", "☺": "#D94748"][title] {
            surface.key = color; surface.text = foreground(on: color, tokens: tokens)
        }
        control.backgroundColor = (role == .toolbar || role == .candidate) ? .clear : UIColor(themeHex: surface.key).withAlphaComponent(strong ? 1 : surface.opacity)
        control.layer.cornerRadius = tokens.desktopStyle == .classic ? 0 : role == .primary ? min(20, tokens.cornerRadius + 3) : tokens.cornerRadius
        control.layer.borderWidth = (role == .toolbar || role == .candidate) ? 0 : strong ? max(2, tokens.borderWidth) : tokens.borderWidth
        control.layer.borderColor = UIColor(themeHex: pressed || tokens.stars ? tokens.accent : tokens.text).withAlphaComponent(pressed || strong ? 1 : (role == .utility ? 0.12 : 0.32)).cgColor
        control.layer.shadowColor = (role == .primary ? UIColor(themeHex: tokens.accent) : UIColor.black).cgColor
        control.layer.shadowOpacity = strong || role == .toolbar || role == .candidate || role == .utility ? 0 : Float(role == .primary ? min(0.3, tokens.shadowOpacity + 0.08) : tokens.shadowOpacity)
        control.layer.shadowRadius = tokens.desktopStyle == .classic ? 0 : role == .primary ? 8 : 2
        control.layer.shadowOffset = CGSize(width: 0, height: role == .primary ? 4 : 2)
        if let button = control as? UIButton {
            let foreground = role == .toolbar ? tokens.canvasAccent : role == .candidate ? tokens.canvasText : surface.text
            button.setTitleColor(UIColor(themeHex: foreground), for: .normal)
            button.setTitleColor(UIColor(themeHex: foreground), for: .highlighted)
            button.tintColor = UIColor(themeHex: foreground)
            button.titleLabel?.font = .systemFont(ofSize: role == .primary ? 18 : 14, weight: role == .primary ? .regular : .light)
        }
        if tokens.desktopStyle != nil {
            control.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
            control.layer.shadowColor = UIColor.black.cgColor
            control.layer.shadowOffset = CGSize(width: 1, height: 2)
            if let button = control as? UIButton {
                button.titleLabel?.font = .monospacedSystemFont(ofSize: role == .primary ? 17 : 13, weight: .medium)
            }
        }
        if tokens.desktopStyle == .bliss || tokens.desktopStyle == .aurora || tokens.desktopStyle?.isConsole == true {
            if role != .toolbar && role != .candidate {
                control.layer.borderWidth = strong ? 2 : 0.65
                control.layer.borderColor = (tokens.desktopStyle == .bliss || tokens.desktopStyle == .gameboy || tokens.desktopStyle == .superfamicom ? UIColor(themeHex: "#7F887C").withAlphaComponent(0.75) : UIColor.white.withAlphaComponent(0.26)).cgColor
                control.layer.shadowRadius = 2
                control.layer.shadowOffset = CGSize(width: 0, height: 1)
            }
            if let button = control as? UIButton {
                button.titleLabel?.font = .systemFont(ofSize: role == .primary ? 17 : 13, weight: .medium)
            }
        }
        if tokens.desktopStyle == .terminal {
            control.layer.borderColor = UIColor(themeHex: tokens.accent).withAlphaComponent(0.36).cgColor
            control.layer.borderWidth = role == .toolbar || role == .candidate ? 0 : strong ? 2 : 0.7
            control.layer.shadowOpacity = 0
        }
        if let label = (control as? UIButton)?.titleLabel { PixelTypography.apply(label, style: tokens.desktopStyle) }
        (control as? KeyboardActionButton)?.setClassic(tokens.desktopStyle == .classic && role != .toolbar && role != .candidate, pressed: pressed)
        (control as? KeyboardActionButton)?.setSheen(tokens.desktopStyle != .terminal && (tokens.desktopStyle != nil && role != .toolbar && role != .candidate && !strong || role == .primary && !strong), style: tokens.desktopStyle)
        control.transform = pressed ? CGAffineTransform(translationX: 0, y: 1) : .identity
    }
}

struct CosmosBackground: View {
    let tokens: ThemeTokens
    var image: UIImage? = nil
    @Environment(\.accessibilityReduceTransparency) private var solid
    @Environment(\.colorSchemeContrast) private var contrast
    var body: some View {
        ZStack {
            Color(themeHex: tokens.background)
            if !solid && contrast != .increased {
                if let image { Image(uiImage: image).resizable().scaledToFill().opacity(0.22) }
                if tokens.stars {
                    RadialGradient(colors: [Color(themeHex: "#154DFF").opacity(0.34), .clear], center: .topTrailing, startRadius: 0, endRadius: 280)
                    Canvas { context, size in
                        for star in NightSky.stars(in: size) {
                            context.fill(Path(ellipseIn: star.rect), with: .color(.white.opacity(star.opacity)))
                        }
                    }
                }
            }
        }.clipped().allowsHitTesting(false).accessibilityHidden(true)
    }
}

final class CosmosBackgroundView: UIView {
    var tokens = ThemeCatalog.blueCosmos.tokens { didSet { setNeedsDisplay() } }
    var image: UIImage? { didSet { setNeedsDisplay() } }
    override init(frame: CGRect) { super.init(frame: frame); isUserInteractionEnabled = false; isAccessibilityElement = false; contentMode = .redraw }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func draw(_ rect: CGRect) {
        UIColor(themeHex: tokens.background).setFill(); UIRectFill(rect)
        guard !UIAccessibility.isReduceTransparencyEnabled, traitCollection.accessibilityContrast != .high else { return }
        if let image {
            let scale = max(bounds.width / image.size.width, bounds.height / image.size.height)
            let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            image.draw(in: CGRect(x: (bounds.width - size.width) / 2, y: (bounds.height - size.height) / 2, width: size.width, height: size.height), blendMode: .normal, alpha: 0.22)
        }
        if let style = tokens.desktopStyle {
            DesktopWallpaper.draw(style, tokens: tokens, in: bounds)
            return
        }
        guard tokens.stars else { return }
        if let context = UIGraphicsGetCurrentContext(), let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [UIColor(themeHex: "#154DFF").withAlphaComponent(0.34).cgColor, UIColor(themeHex: tokens.background).withAlphaComponent(0).cgColor] as CFArray, locations: [0, 1]) {
            context.drawRadialGradient(gradient, startCenter: CGPoint(x: bounds.maxX, y: 0), startRadius: 0, endCenter: CGPoint(x: bounds.maxX, y: 0), endRadius: max(bounds.width, bounds.height), options: [])
        }
        for star in NightSky.stars(in: bounds.size) {
            UIColor.white.withAlphaComponent(star.opacity).setFill()
            UIBezierPath(ovalIn: star.rect).fill()
            if star.rect.width > 2 {
                UIColor(themeHex: tokens.accent).withAlphaComponent(0.18).setFill()
                UIBezierPath(ovalIn: star.rect.insetBy(dx: -2, dy: -2)).fill()
            }
        }
    }
}


/// Small raster canvas deliberately preserves the texture of early desktop displays.
enum DesktopWallpaper {
    static func assetName(_ style: DesktopStyle) -> String? {
        switch style {
        case .bliss: return "DesktopXP"
        case .aurora: return "DesktopVista"
        case .gameboy: return "ConsoleGameBoy"
        case .violet: return "ConsoleViolet"
        case .superfamicom: return "ConsoleSuperFamicom"
        case .gameboyShell: return "ShellGameBoy"
        case .violetShell: return "ShellViolet"
        case .superfamicomShell: return "ShellSuperFamicom"
        default: return nil
        }
    }
    static func draw(_ style: DesktopStyle, tokens: ThemeTokens, in bounds: CGRect) {
        if let name = assetName(style), let image = UIImage(named: name, in: Bundle(for: CosmosBackgroundView.self), compatibleWith: nil) {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            context.saveGState(); context.interpolationQuality = .high
            let scale = max(bounds.width / image.size.width, bounds.height / image.size.height)
            let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            image.draw(in: CGRect(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2, width: size.width, height: size.height))
            let defaultBackground = ThemeCatalog.presets.first { $0.tokens.desktopStyle == style }?.tokens.background ?? tokens.background
            if tokens.background != defaultBackground {
                context.setBlendMode(.color)
                context.setFillColor(UIColor(themeHex: tokens.background).withAlphaComponent(0.45).cgColor)
                context.fill(bounds); context.setBlendMode(.normal)
            }
            // Soft scrim reserves a quiet readable toolbar without cutting across the scenery.
            let header = min(100, bounds.height / 3)
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [UIColor.black.withAlphaComponent(style.isConsoleShell ? 0 : style.isConsole ? 0.55 : style == .bliss ? 0.28 : 0.12).cgColor, UIColor.black.withAlphaComponent(style.isConsoleShell ? 0 : style.isConsole ? 0.55 : style == .bliss ? 0.28 : 0.12).cgColor, UIColor.clear.cgColor] as CFArray, locations: [0, 0.78, 1]) {
                context.drawLinearGradient(gradient, start: bounds.origin, end: CGPoint(x: bounds.minX, y: bounds.minY + header + 24), options: [])
            }
            context.restoreGState()
            return
        }
        let format = UIGraphicsImageRendererFormat(); format.scale = 1; format.opaque = true
        let size = CGSize(width: 160, height: 120)
        let image = UIGraphicsImageRenderer(size: size, format: format).image { renderer in
            let context = renderer.cgContext
            let rect = CGRect(origin: .zero, size: size)
            UIColor(themeHex: tokens.background).setFill(); context.fill(rect)
            func gradient(_ colors: [String], from: CGPoint, to: CGPoint) {
                guard let value = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors.map { UIColor(themeHex: $0).cgColor } as CFArray, locations: nil) else { return }
                context.drawLinearGradient(value, start: from, end: to, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
            }
            switch style {
            case .gameboy, .violet, .superfamicom, .gameboyShell, .violetShell, .superfamicomShell:
                UIColor(themeHex: tokens.accent).withAlphaComponent(0.08).setStroke()
                for y in stride(from: 10, to: 120, by: 12) {
                    let trace = UIBezierPath(); trace.move(to: CGPoint(x: 0, y: y)); trace.addLine(to: CGPoint(x: 160, y: y)); trace.lineWidth = 1; trace.stroke()
                }
            case .terminal:
                UIColor(themeHex: tokens.accent).withAlphaComponent(0.04).setFill()
                for y in stride(from: 0, to: 120, by: 2) { context.fill(CGRect(x: 0, y: y, width: 160, height: 1)) }
            case .classic:
                // Ordered stipple, rather than random noise: stable while typing.
                UIColor.white.withAlphaComponent(0.055).setFill()
                for y in stride(from: 0, to: 120, by: 2) {
                    for x in stride(from: y % 4, to: 160, by: 4) { context.fill(CGRect(x: x, y: y, width: 1, height: 1)) }
                }
            case .bliss:
                gradient([tokens.background, "#61B7EF", "#D1E9F0"], from: .zero, to: CGPoint(x: 0, y: 95))
                UIColor.white.withAlphaComponent(0.28).setFill()
                for cloud in [CGRect(x: 15, y: 22, width: 40, height: 5), CGRect(x: 94, y: 12, width: 48, height: 6)] { context.fillEllipse(in: cloud) }
                let hill = UIBezierPath(); hill.move(to: CGPoint(x: 0, y: 83))
                hill.addCurve(to: CGPoint(x: 160, y: 77), controlPoint1: CGPoint(x: 60, y: 47), controlPoint2: CGPoint(x: 105, y: 101))
                hill.addLine(to: CGPoint(x: 160, y: 120)); hill.addLine(to: CGPoint(x: 0, y: 120)); hill.close()
                context.saveGState(); hill.addClip()
                gradient(["#8DBB36", "#396A19"], from: CGPoint(x: 0, y: 65), to: CGPoint(x: 0, y: 120)); context.restoreGState()
            case .aurora, .aero:
                gradient([tokens.background, "#173E51", "#071923"], from: .zero, to: CGPoint(x: 160, y: 120))
                context.setBlendMode(.screen)
                for index in 0..<18 {
                    let ribbon = UIBezierPath(); let offset = CGFloat(index) * 2
                    ribbon.move(to: CGPoint(x: -20, y: 118 - offset))
                    ribbon.addCurve(to: CGPoint(x: 180, y: 12 + offset), controlPoint1: CGPoint(x: 65, y: 125 - offset), controlPoint2: CGPoint(x: 65, y: -12 + offset))
                    context.setStrokeColor(UIColor(themeHex: tokens.accent).withAlphaComponent(0.018 + Double(18 - index) * 0.003).cgColor)
                    context.setLineWidth(3); context.addPath(ribbon.cgPath); context.strokePath()
                }
                context.setBlendMode(.normal)
            }
            // A dark desktop header keeps candidates and toolbar legible above the scenery.
            UIColor.black.withAlphaComponent(style == .classic ? 0.12 : 0.30).setFill()
            context.fill(CGRect(x: 0, y: 0, width: 160, height: 40))
            UIColor.white.withAlphaComponent(0.2).setFill(); context.fill(CGRect(x: 0, y: 40, width: 160, height: 1))
        }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState(); context.interpolationQuality = .none
        image.draw(in: bounds); context.restoreGState()
    }
}


/// One-pixel light/shadow edges recall the raised controls of Windows 95/98.
final class DesktopBevel: CALayer {
    var pressed = false { didSet { setNeedsLayout() } }
    private let light = CAShapeLayer()
    private let dark = CAShapeLayer()
    override init() {
        super.init(); addSublayer(light); addSublayer(dark)
        light.fillColor = nil; dark.fillColor = nil
        light.lineWidth = 1; dark.lineWidth = 1
        isHidden = true
    }
    override init(layer: Any) { super.init(layer: layer) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layoutSublayers() {
        super.layoutSublayers()
        let inset = bounds.insetBy(dx: 1.5, dy: 1.5)
        let top = UIBezierPath(); top.move(to: CGPoint(x: inset.minX, y: inset.maxY))
        top.addLine(to: inset.origin); top.addLine(to: CGPoint(x: inset.maxX, y: inset.minY))
        let bottom = UIBezierPath(); bottom.move(to: CGPoint(x: inset.maxX, y: inset.minY))
        bottom.addLine(to: CGPoint(x: inset.maxX, y: inset.maxY)); bottom.addLine(to: CGPoint(x: inset.minX, y: inset.maxY))
        light.path = top.cgPath; dark.path = bottom.cgPath
        light.strokeColor = (pressed ? UIColor.darkGray : UIColor.white).cgColor
        dark.strokeColor = (pressed ? UIColor.white : UIColor.darkGray).cgColor
    }
}


/// The same subtle surface treatment is used by letter and action keys.
enum DesktopSurface {
    static func configure(_ layer: CAGradientLayer, style: DesktopStyle?) {
        guard style == .bliss || style == .aurora || style?.isConsole == true else { return }
        layer.startPoint = CGPoint(x: 0.5, y: 0); layer.endPoint = CGPoint(x: 0.5, y: 1)
        if style?.isConsoleShell == true {
            layer.colors = [UIColor.white.withAlphaComponent(0.09).cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.18).cgColor]
            layer.locations = [0, 0.65, 1]
        } else if style == .gameboy || style == .superfamicom {
            layer.colors = [UIColor.white.withAlphaComponent(0.14).cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.14).cgColor]
            layer.locations = [0, 0.55, 1]
        } else if style == .violet || style == .violetShell {
            layer.colors = [UIColor.white.withAlphaComponent(0.24).cgColor, UIColor.white.withAlphaComponent(0.04).cgColor, UIColor.black.withAlphaComponent(0.16).cgColor]
            layer.locations = [0, 0.4, 1]
        } else if style == .bliss {
            layer.colors = [UIColor.white.withAlphaComponent(0.18).cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.075).cgColor]
            layer.locations = [0, 0.6, 1]
        } else {
            layer.colors = [UIColor.white.withAlphaComponent(0.14).cgColor, UIColor.white.withAlphaComponent(0.04).cgColor, UIColor.white.withAlphaComponent(0.01).cgColor, UIColor.black.withAlphaComponent(0.10).cgColor]
            layer.locations = [0, 0.48, 0.5, 1]
        }
    }
}


/// Stable scatter prevents the sky from shifting whenever the keyboard redraws.
enum NightSky {
    struct Star { let rect: CGRect; let opacity: Double }
    static func stars(in size: CGSize) -> [Star] {
        (0..<180).map { index in
            let x = CGFloat((index * 347 + index * index * 13 + 71) % 1009) / 1009 * size.width
            let y = CGFloat((index * 229 + index * index * 17 + 43) % 1013) / 1013 * size.height
            let diameter: CGFloat = index % 23 == 0 ? 2.5 : index % 5 == 0 ? 1.5 : 0.8
            return Star(rect: CGRect(x: x, y: y, width: diameter, height: diameter), opacity: 0.32 + Double(index % 7) * 0.09)
        }
    }
}


/// Native font fallback preserves Japanese; one-point rasterization recalls bitmap-era type.
enum PixelTypography {
    static func apply(_ label: UILabel, style: DesktopStyle?) {
        let pixel = style == .classic || style == .gameboy
        label.layer.shouldRasterize = pixel
        label.layer.rasterizationScale = pixel ? 1 : UIScreen.main.scale
        label.layer.magnificationFilter = pixel ? .nearest : .linear
        if pixel {
            label.font = UIFont(name: "CourierNewPS-BoldMT", size: label.font.pointSize) ?? .monospacedSystemFont(ofSize: label.font.pointSize, weight: .bold)
        } else if style == .terminal {
            label.font = .monospacedSystemFont(ofSize: label.font.pointSize, weight: .medium)
        }
    }
}
