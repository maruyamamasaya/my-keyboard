import Foundation
import KeyboardCore

/// Only the containing app writes appearance. Readers never modify the shared files.
struct ThemeStore {
    private let directory: URL
    init() throws {
        directory = try SharedContainer.url().appendingPathComponent("Themes", isDirectory: true)
    }
    init(directory: URL) { self.directory = directory }
    func load(legacy: KeyboardTheme = .system) -> ThemeSelection {
        let url = directory.appendingPathComponent("selection.json")
        guard let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize, size <= 8192,
              let data = try? Data(contentsOf: url), data.count <= 8192,
              let value = try? JSONDecoder().decode(ThemeSelection.self, from: data), value.schemaVersion == 1 else {
            return .migrating(legacy)
        }
        return value
    }
    func save(_ value: ThemeSelection) throws {
        try SharedContainer.preparePrivateDirectory(directory)
        var safe = value; safe.custom = value.custom?.sanitized(); safe.imageName = value.safeImageName
        try JSONEncoder().encode(safe).write(to: directory.appendingPathComponent("selection.json"), options: .atomic)
    }
    func imageData(_ selection: ThemeSelection) -> Data? {
        guard let name = selection.safeImageName else { return nil }
        let url = directory.appendingPathComponent(name)
        guard let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize, size <= 1_048_576,
              let data = try? Data(contentsOf: url), data.count <= 1_048_576 else { return nil }
        return data
    }
    func saveImage(_ data: Data) throws -> String {
        guard data.count <= 1_048_576 else { throw ThemeImageError.tooLarge }
        try SharedContainer.preparePrivateDirectory(directory)
        let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil).filter {
            var selection = ThemeSelection(); selection.imageName = $0.lastPathComponent; return selection.safeImageName != nil
        }
        guard files.count < 20 else { throw ThemeImageError.capacityReached }
        let name = UUID().uuidString + ".jpg"
        try data.write(to: directory.appendingPathComponent(name), options: .atomic)
        return name
    }
    /// Explicit app action; keep the current image and remove only our UUID-named files.
    func removeUnusedImages(keeping selection: ThemeSelection) throws {
        guard FileManager.default.fileExists(atPath: directory.path) else { return }
        for url in try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) {
            var check = ThemeSelection(); check.imageName = url.lastPathComponent
            if check.safeImageName != nil && check.safeImageName != selection.safeImageName {
                try FileManager.default.removeItem(at: url)
            }
        }
    }
}

enum ThemeImageError: LocalizedError {
    case tooLarge, unsupported, capacityReached
    var errorDescription: String? {
        switch self {
        case .tooLarge: return "画像が大きすぎます。入力は20MB・4000万画素までです。"
        case .unsupported: return "端末内の静止画像を選択してください。画像を読み込めませんでした。"
        case .capacityReached: return "背景画像の保存上限です。テーマ編集から未使用の背景画像を削除してください。"
        }
    }
}
