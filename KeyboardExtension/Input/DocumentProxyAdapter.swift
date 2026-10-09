import UIKit
import CoreFoundation
import KeyboardCore

@MainActor struct DocumentProxyAdapter: LiveTextClient, CommittedTextClient {
    let proxy: any UITextDocumentProxy
    var snapshot: DocumentSnapshot {
        .init(documentID: DocumentIdentity.read(from: proxy as? NSObject), before: proxy.documentContextBeforeInput,
              after: proxy.documentContextAfterInput, selected: proxy.selectedText)
    }
    func setMarkedText(_ text: String, selectedRange: NSRange) { proxy.setMarkedText(text, selectedRange: selectedRange) }
    func unmarkText() { proxy.unmarkText() }
    func insertText(_ text: String) { proxy.insertText(text) }
    func deleteBackward() { proxy.deleteBackward() }
    // No arbitrary range replacement exists. Check after every primitive; stop on mismatch.
    func replace(_ recent: RecentCommit, with text: String) -> Bool {
        guard recent.canReplace(in: snapshot), let before = recent.snapshot.before else { return false }
        var expected = before
        for _ in recent.text {
            guard snapshot.before == expected, snapshot.after == recent.snapshot.after,
                  snapshot.documentID == recent.snapshot.documentID, (snapshot.selected ?? "").isEmpty else { return false }
            proxy.deleteBackward()
            expected.removeLast()
        }
        guard snapshot.before == expected, snapshot.after == recent.snapshot.after,
              snapshot.documentID == recent.snapshot.documentID, (snapshot.selected ?? "").isEmpty else { return false }
        proxy.insertText(text)
        return true
    }
    func deleteWord() -> Bool {
        guard let before = proxy.documentContextBeforeInput, !before.isEmpty,
              (proxy.selectedText ?? "").isEmpty else { return false }
        let trimmed = before.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        if trimmed.count < before.count {
            return deleteSuffix(String(before.dropFirst(trimmed.count)))
        }
        let tokenizer = CFStringTokenizerCreate(nil, before as CFString,
            CFRange(location: 0, length: before.utf16.count), kCFStringTokenizerUnitWord, CFLocaleCreate(nil, CFLocaleIdentifier(rawValue: "ja_JP" as CFString)))
        var last = CFRange(location: kCFNotFound, length: 0)
        while !CFStringTokenizerAdvanceToNextToken(tokenizer).isEmpty { last = CFStringTokenizerGetCurrentTokenRange(tokenizer) }
        guard last.location != kCFNotFound, last.location + last.length == before.utf16.count,
              let range = Range(NSRange(location: last.location, length: last.length), in: before) else { return false }
        // A token at the start may be truncated host context. Do not guess its full boundary.
        guard range.lowerBound != before.startIndex else { return false }
        return deleteSuffix(String(before[range]))
    }
    private func deleteSuffix(_ text: String) -> Bool {
        guard text.count <= 32, text.allSatisfy({ String($0).utf16.count == 1 }), let before = snapshot.before else { return false }
        let recent = RecentCommit(reading: text, text: text, snapshot: snapshot)
        guard before.hasSuffix(text) else { return false }
        return replace(recent, with: "")
    }
}
