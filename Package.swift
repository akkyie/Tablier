// swift-tools-version:4.0

import PackageDescription

var packageDependencies: [Package.Dependency] = []
var tablierDependencies: [Target.Dependency] = []

#if swift(>=5)
#else
    packageDependencies.append(.package(url: "https://github.com/antitypical/Result.git", from: "5.0.0"))
    tablierDependencies.append("Result")
#endif

let package = Package(
    name: "Tablier",
    products: [
        .library(
            name: "Tablier",
            targets: ["Tablier"]
        ),
    ],
    dependencies: packageDependencies,
    targets: [
        .target(
            name: "Tablier",
            dependencies: tablierDependencies
        ),
        .testTarget(
            name: "TablierTests",
            dependencies: ["Tablier"]
        ),
    ]
)
