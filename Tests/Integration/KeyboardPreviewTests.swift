import SwiftUI
import UIKit
import XCTest
import KeyboardCore

final class KeyboardPreviewTests: XCTestCase {
    @MainActor func testNativePreviewMatchesAllThreeKeyLayouts() async throws {
        for mode in KeyboardPreviewMode.allCases {
            var theme = ThemeSelection(); theme.presetID = "windows-98"
            let host = UIHostingController(rootView: KeyboardPreview(selection: theme, mode: mode))
            let window: UIWindow
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                window = UIWindow(windowScene: scene)
            } else {
                window = UIWindow(frame: UIScreen.main.bounds)
            }
            window.rootViewController = host
            window.makeKeyAndVisible()
            defer { window.isHidden = true }
            host.view.layoutIfNeeded()
            try await Task.sleep(nanoseconds: 50_000_000)
            host.view.layoutIfNeeded()
            func keys(in view: UIView) -> [FlickButton] {
                (view as? FlickButton).map { [$0] } ?? view.subviews.flatMap { keys(in: $0) }
            }
            let rendered = keys(in: host.view)
            let expected = mode == .english ? FlickMap.english(uppercase: false) : mode == .symbols ? FlickMap.engineeringSymbols : FlickMap.japanese
            XCTAssertEqual(rendered.map { $0.key.label }, expected.map(\.label))
            XCTAssertTrue(rendered.allSatisfy { !$0.isUserInteractionEnabled && $0.bounds.height > 0 })
            XCTAssertEqual(rendered.first.map { Double($0.layer.cornerRadius) }, theme.tokens.cornerRadius)
        }
    }
}
