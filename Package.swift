// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CombineX",
    products: [
        .library(name: "CombineX", targets: ["CombineX", "CXFoundation"]),
        .library(name: "CXCompatible", targets: ["CXCompatible"]),
    ],
    targets: [
        .target(name: "CXUtility"),
        .target(name: "CombineX", dependencies: ["CXUtility"]),
        .target(name: "CXFoundation", dependencies: ["CXUtility", "CombineX"]),
        .target(name: "CXCompatible"),
    ]
)
