import SwiftUI
import UIKit
import KeyboardCore

enum KeyboardPreviewMode: String, CaseIterable { case japanese = "かな", english = "ABC", symbols = "記号" }

/// Uses the same native controls and geometry as the extension; never edits host text.
struct KeyboardPreview: View {
    let selection: ThemeSelection
    var profile = LayoutProfile()
    var image: UIImage? = nil
    var showsCandidates = true
    var mode: KeyboardPreviewMode = .japanese
    var body: some View {
        NativeKeyboardPreview(tokens: selection.tokens, showsCandidates: showsCandidates, mode: mode)
            .frame(height: profile.sanitized().height)
            .accessibilityLabel("キーボードの外観プレビュー")
    }
}

private struct NativeKeyboardPreview: UIViewRepresentable {
    let tokens: ThemeTokens
    let showsCandidates: Bool
    let mode: KeyboardPreviewMode
    func makeUIView(context: Context) -> PreviewKeyboardView { PreviewKeyboardView() }
    func updateUIView(_ view: PreviewKeyboardView, context: Context) { view.update(tokens: tokens, showsCandidates: showsCandidates, mode: mode) }
}

private final class PreviewKeyboardView: UIView {
    private let background = CosmosBackgroundView(frame: .zero)
    private let body = UIStackView()
    func update(tokens: ThemeTokens, showsCandidates: Bool, mode: KeyboardPreviewMode) {
        background.tokens = tokens
        backgroundColor = UIColor(themeHex: tokens.background)
        body.arrangedSubviews.forEach { body.removeArrangedSubview($0); $0.removeFromSuperview() }
        let strong = UIAccessibility.isReduceTransparencyEnabled || traitCollection.accessibilityContrast == .high
        func action(_ title: String, role: KeyboardKeyRole = .utility, symbol: String? = nil) -> KeyboardActionButton {
            let key = KeyboardActionButton(frame: .zero); key.keyRole = role; key.accessibilityLabel = title
            if let symbol { key.setImage(UIImage(systemName: symbol), for: .normal) }
            else { key.setTitle(title, for: .normal) }
            key.titleLabel?.numberOfLines = 2
            key.isUserInteractionEnabled = false
            KeyboardKeyStyle.apply(key, tokens: tokens, strong: strong)
            return key
        }
        func scroll(_ stack: UIStackView, height: Double) -> UIScrollView {
            let scroll = UIScrollView(); scroll.showsHorizontalScrollIndicator = false
            stack.translatesAutoresizingMaskIntoConstraints = false; scroll.addSubview(stack)
            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor), stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
                stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor), stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
                stack.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor), scroll.heightAnchor.constraint(equalToConstant: height)
            ])
            return scroll
        }
        let header = UIStackView(); header.axis = .vertical
        header.isLayoutMarginsRelativeArrangement = true; header.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        let candidates = UIStackView(); candidates.spacing = 6
        if showsCandidates && mode == .japanese {
            for text in ["今日は", "今日", "きょう", "京都"] {
                let key = action(text, role: .candidate); key.titleLabel?.numberOfLines = 1
                key.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
                key.setContentCompressionResistancePriority(.required, for: .horizontal)
                candidates.addArrangedSubview(key)
            }
        }
        header.addArrangedSubview(scroll(candidates, height: KeyboardGeometry.candidateHeight))
        let toolbar = UIStackView(); toolbar.spacing = 4
        for (title, symbol) in [("候補", showsCandidates ? "eye" : "eye.slash"), ("あA", "textformat"), ("履歴", "doc.on.clipboard"), ("左", "chevron.left"), ("右", "chevron.right"), ("確定", "checkmark.circle"), ("取消", "arrow.uturn.backward"), ("再変換", "arrow.triangle.2.circlepath"), ("単語削除", "delete.left.fill")] {
            let key = action(title, role: .toolbar, symbol: title == "あA" ? nil : symbol); key.widthAnchor.constraint(equalToConstant: 44).isActive = true; toolbar.addArrangedSubview(key)
        }
        let tools = UIStackView(); tools.spacing = 4
        tools.addArrangedSubview(scroll(toolbar, height: KeyboardGeometry.toolbarHeight))
        let close = action("キーボードを閉じる", role: .toolbar, symbol: "chevron.down")
        close.widthAnchor.constraint(equalToConstant: 44).isActive = true; tools.addArrangedSubview(close)
        header.addArrangedSubview(tools); body.addArrangedSubview(header)
        let spacing = CGFloat(LayoutProfile().spacing)
        func column() -> UIStackView { let stack = UIStackView(); stack.axis = .vertical; stack.spacing = spacing; stack.distribution = .fillEqually; return stack }
        let grid = UIStackView(); grid.spacing = spacing
        let left = column(), center = column(), right = column()
        grid.addArrangedSubview(left); grid.addArrangedSubview(center); grid.addArrangedSubview(right)
        NSLayoutConstraint.activate([left.widthAnchor.constraint(equalTo: right.widthAnchor), center.widthAnchor.constraint(equalTo: left.widthAnchor, multiplier: 3, constant: spacing * 2)])
        if mode == .english {
            left.distribution = .fill
            let cursor = action("→"), cancel = action("取消", symbol: "arrow.uturn.backward"), symbols = action("☆123")
            left.addArrangedSubview(cursor); left.addArrangedSubview(cancel); left.addArrangedSubview(symbols)
            NSLayoutConstraint.activate([cursor.heightAnchor.constraint(equalTo: cancel.heightAnchor), symbols.heightAnchor.constraint(equalTo: cursor.heightAnchor, multiplier: 2, constant: spacing)])
        } else {
            for title in ["記号", "123", "あA", "☺"] { left.addArrangedSubview(action(title, symbol: title == "☺" ? "face.smiling" : nil)) }
        }
        let keys = mode == .english ? FlickMap.english(uppercase: false) : mode == .symbols ? FlickMap.engineeringSymbols : FlickMap.japanese
        for rowIndex in 0..<4 {
            let row = UIStackView(); row.spacing = spacing; row.distribution = .fillEqually
            for key in keys[(rowIndex * 3)..<(rowIndex * 3 + 3)] {
                let view = FlickButton(key: key, typography: mode == .english ? .latin : mode == .symbols ? .code : .kana)
                view.applyTheme(tokens, strong: strong); view.isUserInteractionEnabled = false; row.addArrangedSubview(view)
            }
            center.addArrangedSubview(row)
        }
        right.distribution = .fill
        let delete = action("削除", symbol: "delete.left"), space = action("空白"), enter = action("改行\n↵", role: .primary)
        right.addArrangedSubview(delete); right.addArrangedSubview(space); right.addArrangedSubview(enter)
        NSLayoutConstraint.activate([delete.heightAnchor.constraint(equalTo: space.heightAnchor), enter.heightAnchor.constraint(equalTo: delete.heightAnchor, multiplier: 2, constant: spacing)])
        body.addArrangedSubview(grid)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        background.translatesAutoresizingMaskIntoConstraints = false; addSubview(background)
        body.axis = .vertical; body.spacing = KeyboardGeometry.sectionSpacing
        body.translatesAutoresizingMaskIntoConstraints = false; addSubview(body)
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: leadingAnchor), background.trailingAnchor.constraint(equalTo: trailingAnchor), background.topAnchor.constraint(equalTo: topAnchor), background.bottomAnchor.constraint(equalTo: bottomAnchor),
            body.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4), body.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            body.topAnchor.constraint(equalTo: topAnchor, constant: KeyboardGeometry.topInset), body.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -KeyboardGeometry.bottomInset)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
