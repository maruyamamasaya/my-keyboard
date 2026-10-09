import UIKit
import KeyboardCore

enum FlickTypography { case kana, latin, code }

final class FlickButton: UIControl {
    let key: FlickKey
    var onCommit: ((String) -> Void)?
    private var normalFont: UIFont?
    private let title = UILabel()
    private var origin = CGPoint.zero
    private var direction: FlickDirection = .center
    private var tokens = ThemeCatalog.blueCosmos.tokens
    private var strong = false
    private var guides: [UILabel] = []
    private let relief = CAGradientLayer()
    private let bevel = DesktopBevel()
    func applyTheme(_ tokens: ThemeTokens, strong: Bool) {
        self.tokens = tokens; self.strong = strong
        bevel.isHidden = tokens.desktopStyle != .classic
        title.textColor = UIColor(themeHex: tokens.text)
        title.font = tokens.desktopStyle == nil ? normalFont : .monospacedSystemFont(ofSize: normalFont?.pointSize ?? 20, weight: .medium)
        if tokens.desktopStyle == .bliss || tokens.desktopStyle == .aurora || tokens.desktopStyle?.isConsole == true {
            title.font = .systemFont(ofSize: normalFont?.pointSize ?? 20, weight: .medium)
        }
        PixelTypography.apply(title, style: tokens.desktopStyle)
        KeyboardKeyStyle.apply(self, tokens: tokens, strong: strong)
        relief.isHidden = strong || tokens.desktopStyle == .terminal
        relief.colors = [UIColor.white.withAlphaComponent(0.16).cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.20).cgColor]
        relief.locations = [0, 0.45, 1]
        relief.startPoint = CGPoint(x: 0.5, y: 0); relief.endPoint = CGPoint(x: 0.5, y: 1)
        if tokens.desktopStyle == .classic {
            relief.colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.45).cgColor]
            relief.locations = [0, 0.035, 0.036, 0.94, 1]
        } else if tokens.desktopStyle == .aurora {
            relief.colors = [UIColor.white.withAlphaComponent(0.3).cgColor, UIColor.white.withAlphaComponent(0.06).cgColor, UIColor.black.withAlphaComponent(0.25).cgColor]
            relief.locations = [0, 0.48, 1]
        }
        DesktopSurface.configure(relief, style: tokens.desktopStyle)
        for label in guides { PixelTypography.apply(label, style: tokens.desktopStyle); label.textColor = UIColor(themeHex: tokens.text); label.alpha = strong ? 1 : 0.45 }
    }
    init(key: FlickKey, typography: FlickTypography = .kana) {
        self.key = key
        super.init(frame: .zero)
        layer.insertSublayer(relief, at: 0)
        layer.addSublayer(bevel)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 6
        title.text = key.label
        switch typography {
        case .kana: title.font = .systemFont(ofSize: 20, weight: .light)
        case .latin:
            let font = UIFont.systemFont(ofSize: 16, weight: .medium)
            title.font = UIFont(descriptor: font.fontDescriptor.withDesign(.rounded) ?? font.fontDescriptor, size: 16)
        case .code: title.font = .monospacedSystemFont(ofSize: 17, weight: .regular)
        }
        normalFont = title.font
        title.adjustsFontSizeToFitWidth = true; title.minimumScaleFactor = 0.6
        title.textAlignment = .center; title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)
        for index in 1...4 {
            let label = UILabel(); label.text = key.characters.count > index ? key.characters[index] : ""
            label.font = .systemFont(ofSize: 9, weight: .regular); label.textAlignment = .center
            label.alpha = 0.45; label.isAccessibilityElement = false
            addSubview(label); guides.append(label)
        }
        NSLayoutConstraint.activate([title.centerXAnchor.constraint(equalTo: centerXAnchor), title.centerYAnchor.constraint(equalTo: centerYAnchor), title.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -8)])
        isAccessibilityElement = true; accessibilityLabel = key.label; accessibilityTraits = .button
        accessibilityCustomActions = key.characters.enumerated().filter { !$0.element.isEmpty }.map { index, text in
            UIAccessibilityCustomAction(name: text) { [weak self] _ in
                guard let self else { return false }
                self.onCommit?(self.key.characters[index]); return true
            }
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layoutSubviews() {
        super.layoutSubviews()
        let locations = [CGPoint(x: 13, y: bounds.midY), CGPoint(x: bounds.midX, y: 9), CGPoint(x: bounds.width - 13, y: bounds.midY), CGPoint(x: bounds.midX, y: bounds.height - 9)]
        for (label, point) in zip(guides, locations) { label.frame = CGRect(x: point.x - 10, y: point.y - 7, width: 20, height: 14) }
        CATransaction.begin(); CATransaction.setDisableActions(true)
        bevel.frame = bounds; bevel.setNeedsLayout()
        relief.frame = bounds; relief.cornerRadius = tokens.cornerRadius
        CATransaction.commit()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: tokens.cornerRadius).cgPath
    }
    private func feedback(_ pressed: Bool) {
        bevel.pressed = pressed
        guides.forEach { $0.alpha = pressed || strong ? 1 : 0.45 }
        KeyboardKeyStyle.apply(self, tokens: tokens, pressed: pressed, strong: strong)
    }
    override func accessibilityActivate() -> Bool { onCommit?(key.text(.center)); return true }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        origin = touch.location(in: self); direction = .center; feedback(true)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        direction = FlickMap.direction(dx: Double(point.x - origin.x), dy: Double(point.y - origin.y))
        title.text = key.text(direction).isEmpty ? key.label : key.text(direction)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            direction = FlickMap.direction(dx: Double(point.x - origin.x), dy: Double(point.y - origin.y))
        }
        let text = key.text(direction)
        feedback(false); title.text = key.label
        if !text.isEmpty { onCommit?(text) }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { feedback(false); title.text = key.label }
}
