import Foundation

public enum ClipboardPolicy {
    public static let maximumUTF8Bytes = 16_384
    public static let retentionDays = 30
    public static func accepts(_ text: String) -> Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && text.utf8.count <= maximumUTF8Bytes
    }
}
