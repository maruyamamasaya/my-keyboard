import SwiftUI
import KeyboardCore

/// A visual sample, not a host-input or conversion simulator.
struct KeyboardPreview: View {
    let selection: ThemeSelection
    var profile = LayoutProfile()
    var image: UIImage? = nil
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceTransparency) private var solid
    var body: some View {
        let tokens = selection.tokens
        let safe = profile.sanitized()
        VStack(spacing: 6) {
            Text("きょうは").font(.caption).foregroundStyle(Color(themeHex: tokens.canvasText)).frame(maxWidth: .infinity, alignment: .leading)
            HStack { Text("今日は"); Text("今日"); Text("きょう") }.font(.callout).padding(6).frame(maxWidth: .infinity, alignment: .leading).background(Color(themeHex: tokens.key), in: RoundedRectangle(cornerRadius: tokens.cornerRadius))
            GeometryReader { geometry in
                VStack(spacing: safe.spacing) {
                    ForEach(0..<4, id: \.self) { row in
                        HStack(spacing: safe.spacing) {
                            ForEach(0..<3, id: \.self) { column in
                                Text(FlickMap.japanese[row * 3 + column].label).frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color(themeHex: tokens.key).opacity(solid || contrast == .increased || image != nil ? 1 : tokens.opacity))
                                    .clipShape(RoundedRectangle(cornerRadius: tokens.cornerRadius))
                                    .overlay(RoundedRectangle(cornerRadius: tokens.cornerRadius).stroke(Color(themeHex: tokens.text).opacity(contrast == .increased ? 1 : 0.2), lineWidth: contrast == .increased ? max(2, tokens.borderWidth) : tokens.borderWidth))
                                    .shadow(color: .black.opacity(contrast == .increased ? 0 : tokens.shadowOpacity), radius: 2, y: 1)
                            }
                        }
                    }
                    Text("🌐　かな　←　→　⌫　空白　確定").font(.caption).frame(minHeight: 36).foregroundStyle(Color(themeHex: tokens.canvasText))
                }.frame(width: geometry.size.width * safe.widthFraction, height: geometry.size.height)
                    .frame(maxWidth: .infinity, alignment: safe.alignment == .left ? .leading : safe.alignment == .right ? .trailing : .center)
            }.frame(height: safe.height - 110)
            Text("見た目のサンプル・入力操作は実機で確認").font(.caption2).foregroundStyle(Color(themeHex: tokens.canvasText))
        }.padding(10).foregroundStyle(Color(themeHex: tokens.text))
            .background(CosmosBackground(tokens: tokens, image: image)).clipShape(RoundedRectangle(cornerRadius: 16))
            .accessibilityElement(children: .combine).accessibilityLabel("キーボードの外観プレビュー")
    }
}
