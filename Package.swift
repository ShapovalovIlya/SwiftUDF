// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUDF",
    platforms: [
        .macOS(.v11),
        .iOS(.v13)
    ],
    products: [
        .library(name: "SwiftUDF", targets: ["SwiftUDF"]),
    ],
    targets: [
        .target(name: "SwiftUDF"),
        .testTarget(
            name: "SwiftUDFTests",
            dependencies: ["SwiftUDF"]),
    ]
)
