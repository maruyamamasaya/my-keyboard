import Foundation
import KeyboardCore

struct PreferencesStore {
    private let defaults: UserDefaults
    init() throws {
        _ = try SharedContainer.url()
        guard let defaults = UserDefaults(suiteName: SharedContainer.identifier) else { throw StorageError.groupUnavailable }
        self.defaults = defaults
    }
    func load() -> KeyboardPreferences {
        guard let data = defaults.data(forKey: "keyboard.preferences.v1"),
              let value = try? JSONDecoder().decode(KeyboardPreferences.self, from: data) else { return .init() }
        return value
    }
    // App owns writes; extension only loads a snapshot.
    func save(_ value: KeyboardPreferences) throws {
        defaults.set(try JSONEncoder().encode(value), forKey: "keyboard.preferences.v1")
    }
}
