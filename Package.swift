// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Tablier",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Tablier",
            targets: ["Tablier"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Tablier",
            dependencies: []
        ),
        .testTarget(
            name: "TablierTests",
            dependencies: ["Tablier"]
        ),
    ]
)
