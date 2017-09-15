// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Cassowary",
    products: [
        .library(
            name: "Simplex",
            targets: ["Simplex"]
        ),
        .library(
            name: "Cassowary",
            targets: ["Cassowary"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Simplex",
            dependencies: []
        ),
        .testTarget(
            name: "SimplexTests",
            dependencies: ["Simplex"]
        ),
        .target(
            name: "Cassowary",
            dependencies: ["Simplex"]
        ),
        .testTarget(
            name: "CassowaryTests",
            dependencies: ["Simplex", "Cassowary"]
        ),
    ]
)
