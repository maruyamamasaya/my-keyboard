import SwiftUI
import KeyboardCore

struct SettingsView: View {
    @ObservedObject var model: AppModel
    var body: some View {
        Form {
            Section("カラー") {
                NavigationLink("カラーパレット") { ThemeGallery(model: model) }
                NavigationLink("カラーを編集") { ThemeEditor(model: model) }
                NavigationLink("キーボードプレビュー") { PreviewScreen(model: model) }
                KeyboardPreview(selection: model.appearance, showsCandidates: model.preferences.showsCandidates)
                Text("縦横とも高さ360・幅100%・キー間隔3で固定。カラーはキーボードを開き直すと反映されます。")
            }
            Section("変換候補") {
                Toggle("候補を表示", isOn: $model.preferences.showsCandidates)
                Text("既定は非表示。キーボードの目のアイコンでも一時的に切り替えられます。単語の再変換中は候補を表示します。")
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
