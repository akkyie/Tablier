// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Tablier",
    products: [
        .library(
            name: "Tablier",
            targets: ["Tablier"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Tablier",
            dependencies: []
        ),
        .testTarget(
            name: "TablierTests",
            dependencies: ["Tablier"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
