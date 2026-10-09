import SwiftUI
import KeyboardCore

struct SettingsView: View {
    @ObservedObject var model: AppModel
    var body: some View {
        List {
            Section("キーボード") {
                NavigationLink("キーボード設定") { KeyboardSettingsView(model: model) }
                NavigationLink("プレビュー") { PreviewScreen(model: model) }
                NavigationLink("キーボードの使い方") { OnboardingView() }
            }
            Section("カラー") {
                NavigationLink("カラーパレット") { ThemeGallery(model: model) }
                NavigationLink("カラーを編集") { ThemeEditor(model: model) }
            }
            Section("情報") {
                NavigationLink("プライバシー・アプリ情報") { PrivacyInfoView() }
            }
        }.navigationTitle("設定")
    }
}

struct KeyboardSettingsView: View {
    @ObservedObject var model: AppModel
    @State private var feedbackTestCount = 0
    var body: some View {
        Form {
            Section("キーボード設定") {
                Toggle("入力時に振動", isOn: $model.preferences.hapticsEnabled)
                Button("振動を試す") { feedbackTestCount += 1 }
                    .sensoryFeedback(.impact(weight: .heavy, intensity: 1.0), trigger: feedbackTestCount)
                DisclosureGroup("振動しないとき") {
                    Text("iPhoneの設定 → 一般 → キーボード → キーボード → MyKeyboard → フルアクセスを許可を確認してください。")
                        .font(.footnote)
                }
                Toggle("変換候補を表示", isOn: $model.preferences.showsCandidates)
                Toggle("変換学習", isOn: $model.preferences.learningEnabled)
                Button("学習をリセット", role: .destructive) { model.preferences.learningResetID = UUID() }
            }
            Section("クリップボード") {
                Toggle("履歴を保存", isOn: $model.preferences.clipboardEnabled)
                Stepper("保存上限 \(model.preferences.safeClipboardLimit) 件", value: $model.preferences.clipboardLimit, in: 1...200)
            }
        }.navigationTitle("キーボード設定")
    }
}
