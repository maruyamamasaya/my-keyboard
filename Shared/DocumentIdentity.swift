import Foundation

/// UIKit can return nil during host teardown despite its nonnull Swift declaration.
@MainActor enum DocumentIdentity {
    static func read(from object: NSObject?) -> UUID? {
        let selector = NSSelectorFromString("documentIdentifier")
        guard let object, object.responds(to: selector),
              let identifier = object.perform(selector)?.takeUnretainedValue() as? NSUUID else { return nil }
        return identifier as UUID
    }
}
