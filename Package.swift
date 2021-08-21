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
    dependencies: [
        .package(url: "https://github.com/bloomberg/xcdiff", .upToNextMinor(from: "0.7.0")),
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
    ],
    swiftLanguageVersions: [.v5]
)
