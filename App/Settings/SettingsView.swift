import SwiftUI
import KeyboardCore

struct SettingsView: View {
    @ObservedObject var model: AppModel
    @State private var landscape = false
    var body: some View {
        Form {
            Section("レイアウト") {
                Picker("向き", selection: $landscape) { Text("縦").tag(false); Text("横").tag(true) }.pickerStyle(.segmented)
                ProfileSettings(profile: landscape ? $model.preferences.landscape : $model.preferences.portrait)
                NavigationLink("テーマギャラリー") { ThemeGallery(model: model) }
                NavigationLink("キーボードプレビュー") { PreviewScreen(model: model) }
                KeyboardPreview(selection: model.appearance, profile: landscape ? model.preferences.landscape : model.preferences.portrait, image: model.themeImage)
                Text("設定はキーボードを開き直すと読み込まれます。端末と入力先によって高さは調整されます。")
            }
            Section("変換学習") {
                Toggle("候補の選好を端末に保存", isOn: $model.preferences.learningEnabled)
                Button("学習をリセット", role: .destructive) { model.preferences.learningResetID = UUID() }
                Text("拡張を次に開いて変換するとリセットされます。入力全文の履歴ではありません。")
            }
            Section("クリップボード") {
                Toggle("手動の履歴保存を有効にする", isOn: $model.preferences.clipboardEnabled)
                Stepper("保存上限 \(model.preferences.safeClipboardLimit) 件", value: $model.preferences.clipboardLimit, in: 1...200)
                Text("1件16KBまで。未ピンの項目は30日で期限切れとなり、次に履歴を開くと削除します。ピンも件数上限に含みます。自動監視はしません。")
            }
        }.navigationTitle("設定")
    }
}
struct ProfileSettings: View {
    @Binding var profile: LayoutProfile
    var body: some View {
        VStack(alignment: .leading) {
            Text("高さ \(Int(profile.sanitized().height))")
            Slider(value: $profile.height, in: 320...420, step: 5)
            Text("幅 \(Int(profile.sanitized().widthFraction * 100))%（キーサイズ）")
            Slider(value: $profile.widthFraction, in: 0.7...1, step: 0.05)
            Text("キー間隔 \(Int(profile.sanitized().spacing))")
            Slider(value: $profile.spacing, in: 0...12, step: 1)
            Picker("配置", selection: $profile.alignment) {
                Text("左").tag(KeyboardAlignment.left); Text("中央").tag(KeyboardAlignment.center); Text("右").tag(KeyboardAlignment.right)
            }.pickerStyle(.segmented)
        }
    }
}
