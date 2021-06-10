// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CombineX",
    products: [
        .library(name: "CombineX", targets: ["CombineX", "CXFoundation"]),
        .library(name: "CXCompatible", targets: ["CXCompatible"]),
    ],
    targets: [
        .target(name: "CXLibc"),
        .target(name: "CXUtility", dependencies: ["CXLibc"]),
        .target(name: "CXNamespace"),
        .target(name: "CombineX", dependencies: ["CXLibc", "CXUtility", "CXNamespace"]),
        .target(name: "CXFoundation", dependencies: ["CXUtility", "CXNamespace", "CombineX"]),
        .target(name: "CXCompatible", dependencies: ["CXNamespace"]),
    ]
)
