// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "btsparkle",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "btsparkle", targets: ["btsparkle"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Matches the version previously pulled in via CocoaPods (Sparkle 2.x).
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.8.1")
    ],
    targets: [
        .target(
            name: "btsparkle",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Sparkle", package: "Sparkle")
            ]
        )
    ]
)
