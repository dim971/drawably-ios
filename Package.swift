// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Drawably",
    // macOS is declared so `swift test` runs the engine goldens natively;
    // the components are SwiftUI and work on both.
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Drawably", targets: ["Drawably"])
    ],
    targets: [
        .target(
            name: "Drawably",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "DrawablyTests",
            dependencies: ["Drawably"],
            resources: [.copy("Fixtures")],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
