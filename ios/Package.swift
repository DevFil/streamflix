// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StreamFlixUtils",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "StreamFlixUtils",
            targets: ["StreamFlixUtils"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // No external dependencies required - using system frameworks
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "StreamFlixUtils",
            dependencies: [],
            path: "StreamFlix/Utils",
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("CommonCrypto", .when(platforms: [.iOS, .macOS])),
                .linkedFramework("Speech", .when(platforms: [.iOS])),
                .linkedFramework("AVFoundation", .when(platforms: [.iOS]))
            ]
        )
    ]
)
