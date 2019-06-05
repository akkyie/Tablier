// swift-tools-version:4.2

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
        .package(url: "https://github.com/antitypical/Result.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "Tablier",
            dependencies: ["Result"]
        ),
        .testTarget(
            name: "TablierTests",
            dependencies: ["Tablier"]
        ),
    ],
    swiftLanguageVersions: [.v4_2]
)
