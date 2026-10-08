import SwiftUI
import UniformTypeIdentifiers
import KeyboardCore

struct ThemeGallery: View {
    @ObservedObject var model: AppModel
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                Text("静かな光を、毎日の入力に。").font(.title3).frame(maxWidth: .infinity, alignment: .leading)
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
                        Button("このテーマを適用") { model.applyTheme(selection) }.buttonStyle(.borderedProminent)
                    }.padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                }
                NavigationLink("現在のテーマを編集") { ThemeEditor(model: model) }
                Text("すべて端末内で利用できます。テーマはキーの配置を変更しません。") .font(.footnote)
            }.padding()
        }.navigationTitle("テーマギャラリー")
    }
    private func selection(_ id: String) -> ThemeSelection { var value = ThemeSelection(); value.presetID = id; return value }
}

struct ThemeEditor: View {
    @ObservedObject var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: ThemeSelection
    @State private var tokens: ThemeTokens
    @State private var imageData: Data?
    @State private var image: UIImage?
    @State private var importing = false
    @State private var busy = false
    @State private var failure: String?
    init(model: AppModel) {
        self.model = model
        _draft = State(initialValue: model.appearance)
        _tokens = State(initialValue: model.appearance.tokens)
        _image = State(initialValue: model.themeImage)
    }
    private var preview: ThemeSelection {
        var value = draft
        value.custom = tokens == ThemeCatalog.preset(draft.presetID).tokens ? nil : tokens
        return value
    }
    var body: some View {
        Form {
            Section { KeyboardPreview(selection: preview, profile: model.preferences.portrait, image: image) }
            Section("カラー") {
                ThemeColorPicker(title: "背景", hex: $tokens.background)
                ThemeColorPicker(title: "キー", hex: $tokens.key)
                ThemeColorPicker(title: "文字", hex: $tokens.text)
                ThemeColorPicker(title: "アクセント", hex: $tokens.accent)
                Text("読みやすさのため、文字とキーのコントラストが不足する色は表示時に補正します。") .font(.footnote)
            }
            Section("キーの表現") {
                Text("角丸 \(Int(tokens.cornerRadius))"); Slider(value: $tokens.cornerRadius, in: 0...20, step: 1)
                Text("不透明度 \(Int(tokens.opacity * 100))%"); Slider(value: $tokens.opacity, in: 0.65...1, step: 0.01)
                Text("枠線 \(tokens.borderWidth, specifier: "%.1f")"); Slider(value: $tokens.borderWidth, in: 0...3, step: 0.5)
                Text("影 \(Int(tokens.shadowOpacity * 100))%"); Slider(value: $tokens.shadowOpacity, in: 0...0.3, step: 0.01)
                Toggle("静かな星の背景", isOn: $tokens.stars)
                Toggle("ダークな画面表示", isOn: $tokens.dark)
            }
            Section("背景画像") {
                Button(busy ? "画像を処理中…" : "端末内の画像を選択") { importing = true }.disabled(busy)
                Button("画像を外す", role: .destructive) { draft.imageName = nil; imageData = nil; image = nil }
                Text("ネットワーク不要の静止画像を選択してください。1024px以下に縮小し、位置情報などのメタデータを引き継がず保存します。背景は淡く表示します。") .font(.footnote)
                if let failure { Text(failure).foregroundStyle(.red) }
            }
            Section {
                Button("変更を保存") { if model.applyTheme(preview, imageData: imageData) { dismiss() } }.disabled(busy)
                Button("このテーマの初期状態に戻す") { draft.custom = nil; draft.imageName = nil; tokens = ThemeCatalog.preset(draft.presetID).tokens; imageData = nil; image = nil }
                Button("未使用の背景画像を削除", role: .destructive) { model.cleanThemeImages() }
            }
        }.navigationTitle("テーマ編集")
            .fileImporter(isPresented: $importing, allowedContentTypes: [.image]) { result in
                switch result {
                case .failure(let error): failure = error.localizedDescription
                case .success(let url):
                    busy = true; failure = nil
                    Task { @MainActor in
                        do {
                            let normalized = try await Task.detached(priority: .userInitiated) { try ThemeImageImporter.normalize(url) }.value
                            imageData = normalized; image = UIImage(data: normalized)
                        } catch { failure = error.localizedDescription }
                        busy = false
                    }
                }
            }
    }
}

private struct ThemeColorPicker: View {
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
    @State private var landscape = false
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Picker("設定の向き", selection: $landscape) { Text("縦").tag(false); Text("横").tag(true) }.pickerStyle(.segmented)
                KeyboardPreview(selection: model.appearance, profile: model.preferences.profile(landscape: landscape), image: model.themeImage)
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
                KeyboardPreview(selection: model.appearance, profile: model.preferences.portrait, image: model.themeImage)
                NavigationLink { ThemeGallery(model: model) } label: { Label("テーマを選ぶ", systemImage: "paintpalette") }.buttonStyle(.borderedProminent)
                NavigationLink("テーマをカスタマイズ") { ThemeEditor(model: model) }
                NavigationLink("プレビュー") { PreviewScreen(model: model) }
                NavigationLink("キーボード設定") { SettingsView(model: model) }
                NavigationLink("キーボードの使い方") { OnboardingView() }
                NavigationLink("プライバシー・アプリ情報") { PrivacyInfoView() }
                Text("文字入力・変換・テーマは端末内で処理します。画像や入力内容を送信しません。") .font(.footnote)
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
                Text("テーマ画像は縮小して保存し、元画像の位置情報を引き継ぎません。未使用画像はテーマ編集から削除できます。")
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
