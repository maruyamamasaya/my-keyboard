import Foundation

@MainActor public protocol LiveTextClient {
    var snapshot: DocumentSnapshot { get }
    func setMarkedText(_ text: String, selectedRange: NSRange)
    func unmarkText()
}

/// Owns only the current marked input; never deletes committed host text.
@MainActor public final class LiveTextSession {
    private var expected: DocumentSnapshot?
    public var isActive: Bool { expected != nil }
    public init() {}
    public func matches(_ snapshot: DocumentSnapshot) -> Bool { snapshot.documentID != nil && expected == snapshot }
    public func abandon() { expected = nil }
    @discardableResult public func update(_ text: String, cursorUTF16: Int, using client: any LiveTextClient) -> Bool {
        guard client.snapshot.documentID != nil, expected == nil || matches(client.snapshot) else { abandon(); return false }
        guard !text.isEmpty else { cancel(using: client); return true }
        client.setMarkedText(text, selectedRange: NSRange(location: min(text.utf16.count, max(0, cursorUTF16)), length: 0))
        expected = client.snapshot
        return true
    }
    @discardableResult public func finish(_ text: String, using client: any LiveTextClient) -> Bool {
        guard isActive, matches(client.snapshot) else { abandon(); return false }
        client.setMarkedText(text, selectedRange: NSRange(location: text.utf16.count, length: 0))
        client.unmarkText(); abandon()
        return true
    }
    public func cancel(using client: any LiveTextClient) {
        if isActive && matches(client.snapshot) {
            client.setMarkedText("", selectedRange: NSRange(location: 0, length: 0))
            client.unmarkText()
        }
        abandon()
    }
}
