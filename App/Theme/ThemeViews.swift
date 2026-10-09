import SwiftUI
import UniformTypeIdentifiers
import KeyboardCore

struct ThemeGallery: View {
    @ObservedObject var model: AppModel
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(ThemeCatalog.presets) { preset in
                    let selection = selection(preset.id)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(preset.name).font(.headline)
                            Spacer()
                            if model.appearance.presetID == preset.id {
                                Label(model.appearance.custom == nil && model.appearance.imageName == nil ? "選択中" : "カスタム適用中", systemImage: "checkmark.circle.fill").font(.caption)
                            }
                        }
                        if let description = desktopDescription(preset.id) {
                            Text(description).font(.subheadline).foregroundStyle(.secondary)
                        }
                        KeyboardPreview(selection: selection)
                            .clipShape(RoundedRectangle(cornerRadius: preset.id == "windows-98" ? 2 : 12))
                        Button("このカラーを適用") { model.applyTheme(selection) }.buttonStyle(.borderedProminent)
                    }.padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                }
            }.padding()
        }.navigationTitle("カラーパレット")
    }
    private func desktopDescription(_ id: String) -> String? {
        switch id {
        case "game-boy": return "グレーと液晶の緑、基板が透ける懐かしい携帯ゲーム機。"
        case "game-boy-color-violet": return "透明なバイオレットの樹脂と、その奥に見える電子部品。"
        case "super-famicom": return "グレーのキーと赤・黄・青・緑の操作ボタン。"
        case "windows-31": return "青いデスクトップと、ビットマップ風の文字。"
        case "windows-95": return "灰色の立体キーと、懐かしい青緑のデスクトップ。"
        case "terminal": return "黒い画面に緑の等幅文字。静かなターミナル。"
        case "windows-98": return "青緑のデスクトップと、クラシックな立体キー。"
        case "windows-xp": return "青空と緑の丘、クリーム色のキー。"
        case "windows-vista": return "青緑の光と、深いガラスの質感。"
        default: return nil
        }
    }
    private func selection(_ id: String) -> ThemeSelection { var value = ThemeSelection(); value.presetID = id; return value }
}

struct ThemeEditor: View {
    @ObservedObject var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: ThemeSelection
    @State private var tokens: ThemeTokens
    init(model: AppModel) {
        self.model = model
        _draft = State(initialValue: model.appearance)
        _tokens = State(initialValue: model.appearance.tokens)
    }
    private var preview: ThemeSelection {
        var value = draft; value.custom = tokens; value.imageName = nil
        return value
    }
    var body: some View {
        Form {
            Section { KeyboardPreview(selection: preview) }
            Section("カラー") {
                ThemeColorPicker(title: "背景", hex: $tokens.background)
                ThemeColorPicker(title: "キー", hex: $tokens.key)
                ThemeColorPicker(title: "文字", hex: $tokens.text)
                ThemeColorPicker(title: "アクセント", hex: $tokens.accent)
            }
            Section {
                Button("カラーを保存") { if model.applyTheme(preview) { dismiss() } }
                Button("このパレットのカラーに戻す") { tokens = ThemeCatalog.preset(draft.presetID).tokens }
            }
        }.navigationTitle("カラー編集")
    }
}

struct ThemeColorPicker: View {
    let title: String
    @Binding var hex: String
    var body: some View {
        ColorPicker(title, selection: Binding(get: { Color(themeHex: hex) }, set: { value in
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            if UIColor(value).getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
                hex = String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
            }
        }), supportsOpacity: false)
    }
}

struct PreviewScreen: View {
    @ObservedObject var model: AppModel
    @State private var mode: KeyboardPreviewMode = .japanese
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Picker("配列", selection: $mode) {
                    ForEach(KeyboardPreviewMode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
                KeyboardPreview(selection: model.appearance, profile: LayoutProfile(), showsCandidates: model.preferences.showsCandidates, mode: mode)
            }.padding()
        }.navigationTitle("キーボードプレビュー")
    }
}

struct PrivacyInfoView: View {
    private var version: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "開発版" }
    var body: some View {
        List {
            Section("MyKeyboard") {
                LabeledContent("バージョン", value: version)
                LabeledContent("通信", value: "なし")
            }
            Section("端末内のデータ") {
                LabeledContent("設定・カラー・辞書", value: "本体とキーボードで共有")
                LabeledContent("変換学習", value: "キーボード内に保存")
                LabeledContent("クリップボード履歴", value: "手動保存")
                LabeledContent("入力内容の送信", value: "なし")
            }
            Section("フルアクセス") {
                Text("キーボードから履歴を保存する場合に必要です。基本入力は許可なしで使えます。")
            }
            Section {
                NavigationLink("使い方と有効化") { OnboardingView() }
                NavigationLink("オープンソースライセンス") { LicenseView() }
            }
        }.navigationTitle("アプリ情報")
    }
}
