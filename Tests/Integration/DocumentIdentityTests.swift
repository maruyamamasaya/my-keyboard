import Foundation
import XCTest

private final class HostIdentity: NSObject {
    @objc var documentIdentifier: NSUUID?
    init(_ identifier: NSUUID?) { documentIdentifier = identifier }
}
final class DocumentIdentityTests: XCTestCase {
    func testNullableObjectiveCIdentifierDoesNotTrap() async {
        await MainActor.run {
            XCTAssertNil(DocumentIdentity.read(from: HostIdentity(nil)))
            XCTAssertNil(DocumentIdentity.read(from: NSObject()))
            let id = UUID()
            XCTAssertEqual(DocumentIdentity.read(from: HostIdentity(id as NSUUID)), id)
        }
    }
}
