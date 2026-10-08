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
    override init(frame: CGRect) {
        super.init(frame: frame)
        sheen.isHidden = true
        layer.insertSublayer(sheen, at: 0)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func setSheen(_ visible: Bool) {
        sheen.isHidden = !visible
        sheen.colors = [UIColor.white.withAlphaComponent(0.22).cgColor, UIColor.white.withAlphaComponent(0).cgColor]
        sheen.startPoint = CGPoint(x: 0, y: 0); sheen.endPoint = CGPoint(x: 1, y: 1)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin(); CATransaction.setDisableActions(true)
        sheen.frame = bounds; sheen.cornerRadius = layer.cornerRadius
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        CATransaction.commit()
    }
}

/// Distinct surfaces communicate typing, switching and the main action.
enum KeyboardKeyStyle {
    static func apply(_ control: UIView, tokens: ThemeTokens, pressed: Bool = false, strong: Bool = false) {
        let role = (control as? KeyboardActionButton)?.keyRole ?? .character
        var surface = tokens
        if role == .primary {
            surface.key = tokens.accent == ThemeCatalog.blueCosmos.tokens.accent ? "#176BFF" : tokens.accent
            surface.text = "#FFFFFF"; surface.opacity = 1; surface = surface.readable
        } else if role == .utility {
            surface.key = tokens.background; surface.opacity = 1; surface = surface.readable
        }
        control.backgroundColor = (role == .toolbar || role == .candidate) ? .clear : UIColor(themeHex: surface.key).withAlphaComponent(strong ? 1 : surface.opacity)
        control.layer.cornerRadius = role == .primary ? min(20, tokens.cornerRadius + 3) : tokens.cornerRadius
        control.layer.borderWidth = (role == .toolbar || role == .candidate) ? 0 : strong ? max(2, tokens.borderWidth) : tokens.borderWidth
        control.layer.borderColor = UIColor(themeHex: pressed || tokens.stars ? tokens.accent : tokens.text).withAlphaComponent(pressed || strong ? 1 : (role == .utility ? 0.12 : 0.32)).cgColor
        control.layer.shadowColor = (role == .primary ? UIColor(themeHex: tokens.accent) : UIColor.black).cgColor
        control.layer.shadowOpacity = strong || role == .toolbar || role == .candidate || role == .utility ? 0 : Float(role == .primary ? min(0.3, tokens.shadowOpacity + 0.08) : tokens.shadowOpacity)
        control.layer.shadowRadius = role == .primary ? 8 : 2
        control.layer.shadowOffset = CGSize(width: 0, height: role == .primary ? 4 : 2)
        if let button = control as? UIButton {
            let foreground = role == .toolbar ? tokens.canvasAccent : role == .candidate ? tokens.canvasText : surface.text
            button.setTitleColor(UIColor(themeHex: foreground), for: .normal)
            button.setTitleColor(UIColor(themeHex: foreground), for: .highlighted)
            button.tintColor = UIColor(themeHex: foreground)
            button.titleLabel?.font = .systemFont(ofSize: role == .primary ? 18 : 14, weight: role == .primary ? .regular : .light)
        }
        (control as? KeyboardActionButton)?.setSheen(role == .primary && !strong)
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
                    RadialGradient(colors: [Color(themeHex: tokens.accent).opacity(0.22), .clear], center: .topTrailing, startRadius: 0, endRadius: 280)
                    Canvas { context, size in
                        for index in 0..<24 {
                            let x = CGFloat((index * 47 + 13) % 101) / 101 * size.width
                            let y = CGFloat((index * 31 + 7) % 97) / 97 * size.height
                            context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 1.5, height: 1.5)), with: .color(Color(themeHex: tokens.accent).opacity(0.22)))
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
        guard tokens.stars else { return }
        if let context = UIGraphicsGetCurrentContext(), let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [UIColor(themeHex: tokens.accent).withAlphaComponent(0.22).cgColor, UIColor(themeHex: tokens.background).withAlphaComponent(0).cgColor] as CFArray, locations: [0, 1]) {
            context.drawRadialGradient(gradient, startCenter: CGPoint(x: bounds.maxX, y: 0), startRadius: 0, endCenter: CGPoint(x: bounds.maxX, y: 0), endRadius: max(bounds.width, bounds.height), options: [])
        }
        UIColor(themeHex: tokens.accent).withAlphaComponent(0.22).setFill()
        for index in 0..<24 {
            let x = CGFloat((index * 47 + 13) % 101) / 101 * bounds.width
            let y = CGFloat((index * 31 + 7) % 97) / 97 * bounds.height
            UIBezierPath(ovalIn: CGRect(x: x, y: y, width: 1.5, height: 1.5)).fill()
        }
    }
}
