import SwiftUI
import KeyboardCore

/// A visual sample, not a host-input or conversion simulator.
struct KeyboardPreview: View {
    let selection: ThemeSelection
    var profile = LayoutProfile()
    var image: UIImage? = nil
    var showsCandidates = true
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceTransparency) private var solid
    var body: some View {
        let tokens = selection.tokens
        let safe = profile.sanitized()
        VStack(spacing: 6) {
            HStack(spacing: 18) { Text("今日は"); Text("今日"); Text("きょう") }.foregroundStyle(Color(themeHex: tokens.canvasText)).font(.system(size: 14, weight: .light)).padding(6).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 12).frame(height: 44).opacity(showsCandidates ? 1 : 0).accessibilityHidden(!showsCandidates)
            GeometryReader { geometry in
                VStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Text("◎　◉　✦ 履歴　　←　→　　確定　　取消").font(.caption).lineLimit(1).minimumScaleFactor(0.8)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.down").frame(width: 32, height: 32)
                    }.frame(height: 32)
                    HStack(spacing: safe.spacing) {
                        VStack(spacing: safe.spacing) {
                            ForEach(["記号", "123", "あA", "☺"], id: \.self) { key($0, tokens: tokens, utility: true) }
                        }.frame(width: (geometry.size.width * safe.widthFraction - safe.spacing * 4) / 5)
                        VStack(spacing: safe.spacing) {
                            ForEach(0..<4, id: \.self) { row in
                                HStack(spacing: safe.spacing) {
                                    ForEach(0..<3, id: \.self) { column in
                                        key(FlickMap.japanese[row * 3 + column].label, tokens: tokens)
                                    }
                                }
                            }
                        }
                        GeometryReader { side in
                            let height = (side.size.height - safe.spacing * 3) / 4
                            VStack(spacing: safe.spacing) {
                                key("⌫", tokens: tokens, utility: true).frame(height: height)
                                key("空白", tokens: tokens, utility: true).frame(height: height)
                                key("改行\n↵", tokens: tokens, accent: true).frame(height: height * 2 + safe.spacing)
                            }
                        }.frame(width: (geometry.size.width * safe.widthFraction - safe.spacing * 4) / 5)
                    }
                }.frame(width: geometry.size.width * safe.widthFraction, height: geometry.size.height)
                    .frame(maxWidth: .infinity, alignment: safe.alignment == .left ? .leading : safe.alignment == .right ? .trailing : .center)
            }.frame(height: safe.height - 110)
            Text("見た目のサンプル・入力操作は実機で確認").font(.caption2).foregroundStyle(Color(themeHex: tokens.canvasText))
        }.padding(.horizontal, 10).padding(.top, 22).padding(.bottom, 10).foregroundStyle(Color(themeHex: tokens.text))
            .background(CosmosBackground(tokens: tokens, image: image)).clipShape(RoundedRectangle(cornerRadius: 16))
            .accessibilityElement(children: .combine).accessibilityLabel("キーボードの外観プレビュー")
    }
    private func key(_ title: String, tokens: ThemeTokens, accent: Bool = false, utility: Bool = false) -> some View {
        var surface = tokens
        if utility { surface.key = tokens.background; surface.opacity = 1; surface = surface.readable }
        if accent { surface.key = tokens.accent == ThemeCatalog.blueCosmos.tokens.accent ? "#176BFF" : tokens.accent; surface.text = "#FFFFFF"; surface.opacity = 1; surface = surface.readable }
        return Text(title).font(.system(size: accent ? 18 : utility ? 14 : 20, weight: .light))
            .multilineTextAlignment(.center)
            .foregroundStyle(Color(themeHex: surface.text))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(themeHex: surface.key).opacity(solid || contrast == .increased || image != nil ? 1 : surface.opacity))
            .overlay { if accent && !solid && contrast != .increased { LinearGradient(colors: [.white.opacity(0.22), .clear], startPoint: .topLeading, endPoint: .bottomTrailing).allowsHitTesting(false) } }
            .overlay {
                if !utility && !accent && !solid && contrast != .increased {
                    LinearGradient(colors: [.white.opacity(0.16), .clear, .black.opacity(0.20)], startPoint: .top, endPoint: .bottom).allowsHitTesting(false)
                }
            }
            .overlay {
                if !utility && !accent {
                    GeometryReader { geometry in
                        let letters = FlickMap.japanese.first { $0.label == title }?.characters ?? []
                        ForEach(1..<min(5, max(1, letters.count)), id: \.self) { index in
                            Text(letters[index]).font(.system(size: 9, weight: .regular)).opacity(0.45)
                                .position(x: index == 1 ? 11 : index == 3 ? geometry.size.width - 11 : geometry.size.width / 2,
                                          y: index == 2 ? 9 : index == 4 ? geometry.size.height - 9 : geometry.size.height / 2)
                        }
                    }.allowsHitTesting(false).accessibilityHidden(true)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: surface.cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: surface.cornerRadius).stroke(Color(themeHex: surface.stars ? surface.accent : surface.text).opacity(contrast == .increased ? 1 : 0.35), lineWidth: contrast == .increased ? max(2, surface.borderWidth) : surface.borderWidth))
            .shadow(color: accent && !solid && contrast != .increased ? Color(themeHex: tokens.accent).opacity(0.3) : .clear, radius: 8, y: 4)
    }

}
