import Foundation

@MainActor public protocol CommittedTextClient {
    var snapshot: DocumentSnapshot { get }
    func insertText(_ text: String)
    func deleteBackward()
}

/// A captured selection or bounded suffix. Candidate previews never edit the host.
public struct CommittedTextTarget: Equatable, Sendable {
    public let text: String
    public let snapshot: DocumentSnapshot
    public let isSelection: Bool

    public init?(snapshot: DocumentSnapshot, suffix: String? = nil) {
        guard snapshot.documentID != nil else { return nil }
        if let selected = snapshot.selected, !selected.isEmpty {
            guard selected.count <= 128 else { return nil }
            text = selected; isSelection = true
        } else {
            guard let suffix, !suffix.isEmpty, suffix.count <= 32,
                  suffix.allSatisfy({ String($0).utf16.count == 1 }),
                  snapshot.before?.hasSuffix(suffix) == true, snapshot.after != nil else { return nil }
            text = suffix; isSelection = false
        }
        self.snapshot = snapshot
    }

    @MainActor @discardableResult public func replace(with replacement: String, using client: any CommittedTextClient) -> Bool {
        guard !replacement.isEmpty, client.snapshot == snapshot else { return false }
        if replacement == text { return true }
        if isSelection {
            // insertText replaces the user's existing selection in one host operation.
            client.insertText(replacement)
            return true
        }
        guard var expected = snapshot.before else { return false }
        for _ in text {
            guard matches(client.snapshot, before: expected) else { return false }
            client.deleteBackward()
            expected.removeLast()
            guard matches(client.snapshot, before: expected) else { return false }
        }
        client.insertText(replacement)
        return true
    }

    private func matches(_ current: DocumentSnapshot, before: String) -> Bool {
        current.documentID == snapshot.documentID && current.before == before
            && current.after == snapshot.after && (current.selected ?? "").isEmpty
    }
}
