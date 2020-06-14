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
    targets: [
        .target(name: "SegmentQuery", dependencies: []),
        .target(name: "SegmentQueryTestUtil", dependencies: []),
//        .target(
//            name: "SegmentQuery",
//            dependencies: [],
//            swiftSettings: [SwiftSetting.unsafeFlags(["-Ounchecked", "-whole-module-optimization"])],
//            linkerSettings: [LinkerSetting.unsafeFlags([""])]),
        .target(name: "SegmentQueryFuzz", dependencies: ["SegmentQuery","SegmentQueryTestUtil"]),
        .target(name: "SegmentQueryFuzzOptimized", dependencies: ["SegmentQuery","SegmentQueryTestUtil"]),
        .target(name: "SegmentQueryBenchmark", dependencies: ["SegmentQuery","SegmentQueryTestUtil"]),
        .testTarget(name: "SegmentQueryTests", dependencies: ["SegmentQuery","SegmentQueryTestUtil"]),
    ],
    swiftLanguageVersions: [.v5]
)
