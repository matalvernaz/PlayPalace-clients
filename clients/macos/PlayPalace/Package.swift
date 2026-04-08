// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PlayPalace",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PlayPalace", targets: ["PlayPalace"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "PlayPalace",
            path: "Sources"
        )
    ]
)
