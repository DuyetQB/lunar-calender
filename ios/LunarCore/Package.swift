// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LunarCore",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "LunarCore", targets: ["LunarCore"]),
    ],
    targets: [
        .target(name: "LunarCore", path: "Sources/LunarCore"),
        .testTarget(name: "LunarCoreTests", dependencies: ["LunarCore"], path: "Tests"),
    ]
)
