import Foundation
import KeyboardCore

enum StorageError: LocalizedError {
    case groupUnavailable, invalidDictionary, invalidClipboard, unsupportedSchema, capacityReached, clipboardDisabled
    var errorDescription: String? {
        switch self {
        case .groupUnavailable: return "共有保存先を利用できません。App Groupsの設定を確認してください。"
        case .invalidDictionary: return "読みと表記を入力してください。辞書は1,000件までです。"
        case .invalidClipboard: return "空の内容や16KBを超えるテキストは保存できません。"
        case .unsupportedSchema: return "保存データの版が対応範囲外です。アプリを更新してください。"
        case .capacityReached: return "履歴の上限です。ピンを外すか履歴を削除してください。"
        case .clipboardDisabled: return "履歴保存を設定で有効にしてください。"
        }
    }
}

enum SharedContainer {
    static var identifier: String { Bundle.main.object(forInfoDictionaryKey: "SharedAppGroup") as? String ?? "" }
    static func url() throws -> URL {
        guard !identifier.isEmpty,
              let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
            throw StorageError.groupUnavailable
        }
        return url
    }
    static func preparePrivateDirectory(_ url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        #if os(iOS)
        try FileManager.default.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: url.path)
        #endif
        var mutable = url
        var values = URLResourceValues(); values.isExcludedFromBackup = true
        try mutable.setResourceValues(values)
    }
}
