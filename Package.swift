// swift-tools-version: 6.1
import PackageDescription

// Portable logic only. iOS targets and the converter dependency live in the Xcode project.
let package = Package(
    name: "KeyboardCore",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [.library(name: "KeyboardCore", targets: ["KeyboardCore"])],
    targets: [
        .target(name: "KeyboardCore", path: "Core"),
        .testTarget(name: "KeyboardCoreTests", dependencies: ["KeyboardCore"], path: "Tests/Unit")
    ],
    swiftLanguageModes: [.v5]
)
