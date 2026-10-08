import UIKit
import XCTest

@MainActor private final class KeyboardHostField: UITextField {
    let keyboard = KeyboardViewController()

}

final class KeyboardLifecycleTests: XCTestCase {
    @MainActor func testUIKitHostsCompactKeyboardAtRequestedHeight() async throws {
        let window: UIWindow
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene { window = UIWindow(windowScene: scene) }
        else { window = UIWindow(frame: UIScreen.main.bounds) }
        let root = UIViewController(), field = KeyboardHostField(frame: CGRect(x: 20, y: 80, width: 250, height: 44))
        window.rootViewController = root; window.makeKeyAndVisible()
        field.keyboard.loadViewIfNeeded()
        field.inputView = field.keyboard.inputView
        root.view.addSubview(field)
        defer { field.resignFirstResponder(); window.isHidden = true }
        XCTAssertTrue(field.becomeFirstResponder())
        try await Task.sleep(nanoseconds: 500_000_000)
        field.keyboard.view.layoutIfNeeded()
        XCTAssertNotNil(field.keyboard.view.window)
        XCTAssertEqual(field.keyboard.view.bounds.height, 300, accuracy: 1)
        func flicks(in view: UIView) -> [FlickButton] {
            (view as? FlickButton).map { [$0] } ?? view.subviews.flatMap { flicks(in: $0) }
        }
        let keys = flicks(in: field.keyboard.view)
        XCTAssertEqual(keys.count, 12)
        XCTAssertTrue(keys.allSatisfy { $0.bounds.height >= 44 && $0.bounds.height <= 54 })
        print("UIKit keyboard height: \(field.keyboard.view.bounds.height); key height: \(keys.first?.bounds.height ?? 0)")
    }
    func testTwentyReappearancesReuseGridAndKeepControlsVisible() async {
        await MainActor.run {
            let keyboard = KeyboardViewController()
            keyboard.loadViewIfNeeded()
            XCTAssertEqual(keyboard.inputView?.allowsSelfSizing, true)
            let fitting = keyboard.view.systemLayoutSizeFitting(
                CGSize(width: 393, height: 360), withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel)
            XCTAssertEqual(fitting.height, 300, accuracy: 0.5)
            keyboard.view.frame = CGRect(x: 0, y: 0, width: 393, height: 300)
            func controls(in view: UIView) -> [UIControl] {
                (view as? UIControl).map { [$0] } ?? view.subviews.flatMap { controls(in: $0) }
            }
            for modeButton in [nil, "あA", "記号"] as [String?] {
                if let modeButton {
                    if modeButton == "記号" && !controls(in: keyboard.view).contains(where: { $0.accessibilityLabel == "記号" }) {
                        controls(in: keyboard.view).first { $0.accessibilityLabel == "あA" }?.sendActions(for: .touchUpInside)
                    }
                    let toggle = controls(in: keyboard.view).first { $0.accessibilityLabel == modeButton }
                    XCTAssertNotNil(toggle, "Missing \(modeButton); controls: \(controls(in: keyboard.view).compactMap(\.accessibilityLabel))")
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
