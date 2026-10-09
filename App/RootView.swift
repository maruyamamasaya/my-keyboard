import SwiftUI
import KeyboardCore

struct RootView: View {
    @ObservedObject var model: AppModel
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        TabView {
            NavigationStack { ThemeGallery(model: model) }.tabItem { Label("ホーム", systemImage: "house") }
            NavigationStack { ClipboardView(model: model) }.tabItem { Label("履歴", systemImage: "clipboard") }
            NavigationStack { DictionaryView(model: model) }.tabItem { Label("辞書", systemImage: "book") }
            NavigationStack { SettingsView(model: model) }.tabItem { Label("設定", systemImage: "gearshape") }
        }
        .tint(.blue)
        .onChange(of: scenePhase) { _, phase in if phase == .active { model.reloadAppearance() } }
        .onChange(of: model.preferences) { _, _ in model.savePreferences() }
    }
}
