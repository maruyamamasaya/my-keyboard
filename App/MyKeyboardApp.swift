import SwiftUI
import KeyboardCore

@main struct MyKeyboardApp: App {
    @StateObject private var model = AppModel()
    var body: some Scene {
        WindowGroup {
            RootView(model: model)
                .alert("確認", isPresented: Binding(get: { model.message != nil }, set: { if !$0 { model.message = nil } })) {
                    Button("OK") { model.message = nil }
                } message: { Text(model.message ?? "") }
        }
    }
}

@MainActor final class AppModel: ObservableObject {
    @Published var preferences = KeyboardPreferences()
    @Published var dictionary: [DictionaryEntry] = []
    @Published var history: [ClipboardItem] = []
    @Published var message: String?
    @Published private(set) var appearance = ThemeSelection()
    @Published private(set) var themeImage: UIImage?
    private var preferencesStore: PreferencesStore?
    private var clipboard: ClipboardStore?

    init() {
        do {
            let store = try PreferencesStore()
            preferencesStore = store
            preferences = store.load()
            appearance = (try? ThemeStore())?.load(legacy: preferences.theme) ?? .init()
            themeImage = nil
            try store.save(preferences)
            dictionary = try UserDictionaryStore().load()
        } catch { message = error.localizedDescription }
    }
    @discardableResult func applyTheme(_ selection: ThemeSelection, imageData: Data? = nil) -> Bool {
        do {
            let store = try ThemeStore()
            var next = selection
            next.imageName = nil
            try store.save(next)
            appearance = next
            themeImage = nil
            return true
        } catch { message = error.localizedDescription; return false }
    }
    func reloadAppearance() {
        appearance = (try? ThemeStore())?.load(legacy: preferences.theme) ?? appearance
    }
    func cleanThemeImages() {
        do { try ThemeStore().removeUnusedImages(keeping: appearance) }
        catch { message = error.localizedDescription }
    }
    func savePreferences() {
        do {
            guard let preferencesStore else { throw StorageError.groupUnavailable }
            try preferencesStore.save(preferences)
            if !preferences.clipboardEnabled { clipboard = nil; history = [] }
        } catch { message = error.localizedDescription }
    }
    func saveEntry(_ entry: DictionaryEntry) {
        do {
            var next = dictionary.filter { $0.id != entry.id }
            next.append(entry)
            try UserDictionaryStore().save(next)
            dictionary = next
        } catch { message = error.localizedDescription }
    }
    func removeEntries(_ offsets: IndexSet) {
        do {
            let next = dictionary.enumerated().filter { !offsets.contains($0.offset) }.map(\.element)
            try UserDictionaryStore().save(next); dictionary = next
        } catch { message = error.localizedDescription }
    }
    func historyAction(search: String = "", _ action: (ClipboardStore) throws -> Void = { _ in }) {
        do {
            guard preferences.clipboardEnabled else { throw StorageError.clipboardDisabled }
            if clipboard == nil { clipboard = try ClipboardStore(writable: true) }
            guard let clipboard else { throw StorageError.groupUnavailable }
            try clipboard.prune()
            try action(clipboard)
            history = try clipboard.list(search: search, limit: preferences.safeClipboardLimit)
        } catch { message = error.localizedDescription }
    }
}
