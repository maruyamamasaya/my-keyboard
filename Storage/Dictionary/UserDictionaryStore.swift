import Foundation

struct DictionaryEntry: Codable, Identifiable, Equatable {
    var id = UUID()
    var reading: String
    var text: String
}
struct UserDictionaryStore {
    private struct Snapshot: Codable { var version = 1; var entries: [DictionaryEntry] }
    private var file: URL { get throws { try SharedContainer.url().appendingPathComponent("dictionary-v1.json") } }
    func load() throws -> [DictionaryEntry] {
        let url = try file
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        let snapshot = try JSONDecoder().decode(Snapshot.self, from: Data(contentsOf: url))
        guard snapshot.version == 1 else { throw StorageError.unsupportedSchema }
        return snapshot.entries
    }
    func save(_ entries: [DictionaryEntry]) throws {
        guard entries.count <= 1000, entries.allSatisfy({
            !$0.reading.isEmpty && !$0.text.isEmpty && $0.reading.count <= 128 && $0.text.count <= 128
        }) else { throw StorageError.invalidDictionary }
        let data = try JSONEncoder().encode(Snapshot(entries: entries))
        #if os(iOS)
        try data.write(to: file, options: [.atomic, .completeFileProtection])
        #else
        try data.write(to: file, options: .atomic)
        #endif
        var url = try file
        var values = URLResourceValues(); values.isExcludedFromBackup = true
        try url.setResourceValues(values)
    }
}
