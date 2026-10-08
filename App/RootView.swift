import SwiftUI
import KeyboardCore

struct RootView: View {
    @ObservedObject var model: AppModel
    var body: some View {
        TabView {
            NavigationStack { DashboardView(model: model) }.tabItem { Label("ホーム", systemImage: "sparkles") }
            NavigationStack { SettingsView(model: model) }.tabItem { Label("設定", systemImage: "gearshape") }
            NavigationStack { DictionaryView(model: model) }.tabItem { Label("辞書", systemImage: "book") }
            NavigationStack { ClipboardView(model: model) }.tabItem { Label("履歴", systemImage: "clipboard") }
        }
        .tint(Color(themeHex: model.appearance.tokens.canvasAccent))
        .preferredColorScheme(model.appearance.tokens.dark ? .dark : .light)
        .scrollContentBackground(.hidden)
        .background(CosmosBackground(tokens: model.appearance.tokens))
        .onChange(of: model.preferences) { _, _ in model.savePreferences() }
    }
}
