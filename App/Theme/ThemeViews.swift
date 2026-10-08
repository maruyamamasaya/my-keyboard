import SwiftUI
import UniformTypeIdentifiers
import KeyboardCore

struct ThemeGallery: View {
    @ObservedObject var model: AppModel
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                Text("好きなカラーを、毎日の入力に。").font(.title3).frame(maxWidth: .infinity, alignment: .leading)
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
                        KeyboardPreview(selection: selection)
                        Button("このカラーを適用") { model.applyTheme(selection) }.buttonStyle(.borderedProminent)
                    }.padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                }
                NavigationLink("カラーを編集") { ThemeEditor(model: model) }
                Text("すべて端末内で利用できます。テーマはキーの配置を変更しません。") .font(.footnote)
            }.padding()
        }.navigationTitle("カラーパレット")
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
                Text("文字が読みづらい組み合わせは、表示時にコントラストを補正します。") .font(.footnote)
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
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                KeyboardPreview(selection: model.appearance, profile: LayoutProfile(), showsCandidates: model.preferences.showsCandidates)
                Text("高さ・幅・フリック・変換候補の実際の動作は、iPhoneでキーボードを有効にして確認します。")
            }.padding()
        }.navigationTitle("キーボードプレビュー")
    }
}

struct DashboardView: View {
    @ObservedObject var model: AppModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("あなたの言葉に、\n静かな余白を。").font(.largeTitle.bold())
                Text("MY KEYBOARD · OFFLINE").font(.caption.weight(.semibold))
                KeyboardPreview(selection: model.appearance, showsCandidates: model.preferences.showsCandidates)
                NavigationLink { ThemeGallery(model: model) } label: { Label("テーマを選ぶ", systemImage: "paintpalette") }.buttonStyle(.borderedProminent)
                NavigationLink("カラーを編集") { ThemeEditor(model: model) }
                NavigationLink("プレビュー") { PreviewScreen(model: model) }
                NavigationLink("キーボード設定") { SettingsView(model: model) }
                NavigationLink("キーボードの使い方") { OnboardingView() }
                NavigationLink("プライバシー・アプリ情報") { PrivacyInfoView() }
                Text("文字入力・変換・テーマは端末内で処理します。入力内容を送信しません。") .font(.footnote)
            }.padding(20)
        }.navigationTitle("MyKeyboard")
    }
}

struct PrivacyInfoView: View {
    private var version: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "開発版" }
    var body: some View {
        List {
            Section("MyKeyboard") {
                LabeledContent("バージョン", value: version)
                Text("完全オフラインの日本語フリックキーボード")
            }
            Section("端末内のデータ") {
                Text("設定・テーマ・ユーザー辞書は本体とキーボードで共有します。学習はキーボード内に保存します。")
                Text("クリップボード履歴は手動で保存した内容だけを扱います。コピーの常時監視は行いません。")
                Text("サイズとキーの表現は固定です。背景・キー・文字・アクセントのカラーを変更できます。")
            }
            Section("フルアクセス") {
                Text("共有履歴の保存にはフルアクセスが必要です。本アプリは入力内容を送信する機能を持ちません。設定を許可しない場合も基本入力を利用する設計です。")
            }
            Section {
                NavigationLink("使い方と有効化") { OnboardingView() }
                NavigationLink("オープンソースライセンス") { LicenseView() }
            }
        }.navigationTitle("プライバシー・情報")
    }
}
