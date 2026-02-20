// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Clippy",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "Clippy", targets: ["Clippy"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/LaunchAtLogin-Modern.git", from: "1.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "Clippy",
            dependencies: [
                .product(name: "LaunchAtLogin", package: "LaunchAtLogin-Modern"),
            ],
            path: "Clippy/Sources",
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
