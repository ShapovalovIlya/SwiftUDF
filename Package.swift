// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUDF",
    platforms: [
        .macOS(.v11),
        .iOS(.v14)
    ],
    products: [
        .library(name: "SwiftUDF", targets: ["SwiftUDF"]),
    ],
    dependencies: [
        Dependencies.Injected.package,
    ],
    targets: [
        .target(
            name: "SwiftUDF",
            dependencies: [
                Dependencies.Injected.product
            ]),
        .testTarget(
            name: "SwiftUDFTests",
            dependencies: ["SwiftUDF"]),
    ]
)

//MARK: - Dependencies
fileprivate enum Dependencies {
    case Injected
    
    var package: Package.Dependency {
        switch self {
        case .Injected: .package(url: "https://github.com/ShapovalovIlya/Injected.git", branch: "main")
        }
    }
    
    var product: Target.Dependency {
        switch self {
        case .Injected: .product(name: "Injected", package: "Injected")
        }
    }
}
