import UIKit
import XCTest

final class KeyboardLifecycleTests: XCTestCase {
    func testTwentyReappearancesReuseGridAndKeepControlsVisible() async {
        await MainActor.run {
            let keyboard = KeyboardViewController()
            keyboard.loadViewIfNeeded()
            keyboard.view.frame = CGRect(x: 0, y: 0, width: 393, height: 340)
            func controls(in view: UIView) -> [UIControl] {
                (view as? UIControl).map { [$0] } ?? view.subviews.flatMap { controls(in: $0) }
            }
            for modeButton in [nil, "あA", "記号"] as [String?] {
                if let modeButton {
                    let toggle = controls(in: keyboard.view).first { $0.accessibilityLabel == modeButton }
                    XCTAssertNotNil(toggle)
                    toggle?.sendActions(for: .touchUpInside)
                }
                let initialKeys = controls(in: keyboard.view).filter { $0 is FlickButton }
                XCTAssertEqual(initialKeys.count, 12)
                for _ in 0..<20 {
                    keyboard.viewWillAppear(false)
                    keyboard.view.layoutIfNeeded()
                    keyboard.viewDidAppear(false)
                    keyboard.textDidChange(nil)
                    let keys = controls(in: keyboard.view).filter { $0 is FlickButton }
                    XCTAssertEqual(keys.map(ObjectIdentifier.init), initialKeys.map(ObjectIdentifier.init))
                    XCTAssertTrue(keys.allSatisfy { !$0.isHidden && $0.bounds.height > 0 })
                    XCTAssertTrue(controls(in: keyboard.view).contains { $0.accessibilityLabel == "キーボードを閉じる" })
                    keyboard.viewWillDisappear(false)
                    keyboard.viewDidDisappear(false)
                }
            }
        }
    }
}
