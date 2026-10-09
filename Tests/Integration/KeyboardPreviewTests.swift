import SwiftUI
import UIKit
import XCTest
import KeyboardCore

final class KeyboardPreviewTests: XCTestCase {
    @MainActor func testPaletteRendering() async throws {
        for id in ThemeCatalog.presets.map(\.id) {
            var selection = ThemeSelection(); selection.presetID = id
            if let style = selection.tokens.desktopStyle, let name = DesktopWallpaper.assetName(style) {
                let wallpaper = try XCTUnwrap(UIImage(named: name, in: Bundle(for: CosmosBackgroundView.self), compatibleWith: nil))
                let bitmap = try XCTUnwrap(wallpaper.cgImage)
                XCTAssertGreaterThanOrEqual(bitmap.width, 1170)
                XCTAssertGreaterThanOrEqual(bitmap.height, 900)
            }
            let host = UIHostingController(rootView: KeyboardPreview(selection: selection))
            let window: UIWindow
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                window = UIWindow(windowScene: scene)
            } else {
                window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 300))
            }
            window.rootViewController = host; window.makeKeyAndVisible()
            defer { window.isHidden = true }
            try await Task.sleep(nanoseconds: 100_000_000)
            host.view.layoutIfNeeded()
            func canvas(in view: UIView) -> UIView? {
                if view is CosmosBackgroundView { return view.superview }
                return view.subviews.compactMap { canvas(in: $0) }.first
            }
            let keyboard = try XCTUnwrap(canvas(in: host.view))
            XCTAssertGreaterThan(keyboard.bounds.height, 0)
            func surfaces(in view: UIView) -> [UIView] {
                let key = view is FlickButton || (view as? KeyboardActionButton).map { $0.keyRole == .utility || $0.keyRole == .primary } == true
                return (key ? [view] : []) + view.subviews.flatMap { surfaces(in: $0) }
            }
            for key in surfaces(in: keyboard) {
                XCTAssertEqual(try XCTUnwrap(key.backgroundColor).cgColor.alpha, 0.8, accuracy: 0.001, id)
            }
            let image = UIGraphicsImageRenderer(bounds: keyboard.bounds).image { renderer in
                keyboard.layer.render(in: renderer.cgContext)
            }
            let attachment = XCTAttachment(image: image); attachment.name = id; attachment.lifetime = .keepAlways
            add(attachment)
            XCTAssertNotNil(image.cgImage)
        }
    }
    @MainActor func testNativePreviewMatchesAllKeyLayouts() async throws {
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
            let expected = mode == .english ? FlickMap.english(uppercase: false) : mode == .symbols ? FlickMap.engineeringSymbols : mode == .developerSymbols ? FlickMap.developerSymbols : FlickMap.japanese
            XCTAssertEqual(rendered.map { $0.key.label }, expected.map(\.label))
            XCTAssertTrue(rendered.allSatisfy { !$0.isUserInteractionEnabled && $0.bounds.height > 0 })
            XCTAssertEqual(rendered.first.map { Double($0.layer.cornerRadius) }, theme.tokens.cornerRadius)
        }
    }
}
