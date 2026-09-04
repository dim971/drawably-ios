// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Drawably",
    platforms: [.iOS(.v17)],
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
