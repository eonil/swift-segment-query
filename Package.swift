// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SegmentQuery",
    platforms: [
        .macOS(.v10_11),
    ],
    products: [
        .library(name: "SegmentQuery", targets: ["SegmentQuery"]),
        .executable(name: "SegmentQueryFuzz", targets: ["SegmentQueryFuzz"]),
        .executable(name: "SegmentQueryFuzzOptimized", targets: ["SegmentQueryFuzzOptimized"]),
        .executable(name: "SegmentQueryBenchmark", targets: ["SegmentQueryBenchmark"]),
    ],
    dependencies: [
        .package(url: "https://github.com/eonil/swift-test-util", .branch("master")),
        .package(url: "https://github.com/eonil/BTree", .branch("master")),
        .package(url: "https://github.com/eonil/swift-sbtl", .branch("master")),
    ],
    targets: [
        .target(name: "SegmentQuery", dependencies: []),
//        .target(
//            name: "SegmentQuery",
//            dependencies: [],
//            swiftSettings: [SwiftSetting.unsafeFlags(["-Ounchecked", "-whole-module-optimization"])],
//            linkerSettings: [LinkerSetting.unsafeFlags([""])]),
        .target(name: "SegmentQueryFuzz", dependencies: ["SegmentQuery", "TestUtil"]),
        .target(name: "SegmentQueryFuzzOptimized", dependencies: ["SegmentQuery", "TestUtil"]),
        .target(name: "SegmentQueryBenchmark", dependencies: ["SegmentQuery", "TestUtil", "SBTL", "BTree"]),
        .testTarget(name: "SegmentQueryTests", dependencies: ["SegmentQuery"]),
    ]
)
