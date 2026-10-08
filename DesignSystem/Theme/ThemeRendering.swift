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

/// Solid keys protect legibility against arbitrary user images and accessibility settings.
enum KeyboardKeyStyle {
    static func apply(_ control: UIView, tokens: ThemeTokens, pressed: Bool = false, strong: Bool = false) {
        control.backgroundColor = UIColor(themeHex: tokens.key).withAlphaComponent(strong ? 1 : tokens.opacity)
        control.layer.cornerRadius = tokens.cornerRadius
        control.layer.borderWidth = strong ? max(2, tokens.borderWidth) : tokens.borderWidth
        control.layer.borderColor = UIColor(themeHex: pressed ? tokens.accent : tokens.text).withAlphaComponent(pressed || strong ? 1 : 0.2).cgColor
        control.layer.shadowColor = UIColor.black.cgColor
        control.layer.shadowOpacity = strong ? 0 : Float(tokens.shadowOpacity)
        control.layer.shadowRadius = 2; control.layer.shadowOffset = CGSize(width: 0, height: 1)
        if let button = control as? UIButton {
            button.setTitleColor(UIColor(themeHex: tokens.text), for: .normal)
            button.setTitleColor(UIColor(themeHex: tokens.text), for: .highlighted)
        }
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
        UIColor(themeHex: tokens.accent).withAlphaComponent(0.22).setFill()
        for index in 0..<24 {
            let x = CGFloat((index * 47 + 13) % 101) / 101 * bounds.width
            let y = CGFloat((index * 31 + 7) % 97) / 97 * bounds.height
            UIBezierPath(ovalIn: CGRect(x: x, y: y, width: 1.5, height: 1.5)).fill()
        }
    }
}
