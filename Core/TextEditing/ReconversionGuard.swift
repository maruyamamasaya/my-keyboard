import Foundation

public struct DocumentSnapshot: Equatable, Sendable {
    public var documentID: UUID
    public var before: String?
    public var after: String?
    public var selected: String?
    public init(documentID: UUID, before: String?, after: String?, selected: String?) {
        self.documentID = documentID; self.before = before; self.after = after; self.selected = selected
    }
}
public struct RecentCommit: Sendable {
    public let reading: String
    public let text: String
    public let snapshot: DocumentSnapshot
    public init(reading: String, text: String, snapshot: DocumentSnapshot) {
        self.reading = reading; self.text = text; self.snapshot = snapshot
    }
    public func canReplace(in current: DocumentSnapshot) -> Bool {
        // Restrict destructive host editing to single UTF-16-unit characters until device tests.
        !reading.isEmpty && !text.isEmpty && text.allSatisfy { String($0).utf16.count == 1 }
            && current == snapshot && current.before?.hasSuffix(text) == true
            && current.after != nil && (current.selected ?? "").isEmpty
    }
}
