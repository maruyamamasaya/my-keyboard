import UIKit
import KeyboardCore

final class FlickButton: UIControl {
    let key: FlickKey
    var onCommit: ((String) -> Void)?
    private let title = UILabel()
    private var origin = CGPoint.zero
    private var direction: FlickDirection = .center
    private var tokens = ThemeCatalog.blueCosmos.tokens
    private var strong = false
    private var guides: [UILabel] = []
    func applyTheme(_ tokens: ThemeTokens, strong: Bool) {
        self.tokens = tokens; self.strong = strong
        title.textColor = UIColor(themeHex: tokens.text)
        KeyboardKeyStyle.apply(self, tokens: tokens, strong: strong)
        for label in guides { label.textColor = UIColor(themeHex: tokens.text) }
    }
    init(key: FlickKey) {
        self.key = key
        super.init(frame: .zero)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 6
        title.text = key.label; title.font = .systemFont(ofSize: 23)
        title.textAlignment = .center; title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)
        for index in 1...4 {
            let label = UILabel(); label.text = key.characters.count > index ? key.characters[index] : ""
            label.font = .systemFont(ofSize: 11, weight: .semibold); label.textAlignment = .center
            label.isHidden = true; label.isAccessibilityElement = false
            addSubview(label); guides.append(label)
        }
        NSLayoutConstraint.activate([title.centerXAnchor.constraint(equalTo: centerXAnchor), title.centerYAnchor.constraint(equalTo: centerYAnchor)])
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
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: tokens.cornerRadius).cgPath
    }
    private func feedback(_ pressed: Bool) {
        guides.forEach { $0.isHidden = !pressed }
        KeyboardKeyStyle.apply(self, tokens: tokens, pressed: pressed, strong: strong)
    }
    override func accessibilityActivate() -> Bool { onCommit?(key.label); return true }
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
