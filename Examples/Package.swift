// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TablierExamples",
    products: [
        .library(
            name: "Example",
            targets: ["Example"]
        ),
    ],
    dependencies: [
        .package(path: "../"),
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "5.0.0"),
        .package(url: "https://github.com/Quick/Quick", from: "2.1.0"),
    ],
    targets: [
        .target(
            name: "Example",
            dependencies: ["RxSwift", "RxRelay", "RxTest"]
        ),
        .testTarget(
            name: "ExampleTests",
            dependencies: ["Example", "Tablier", "Quick"]
        ),
    ]
)
