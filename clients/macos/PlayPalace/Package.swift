// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PlayPalace",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .executable(name: "PlayPalace", targets: ["PlayPalace"])
    ],
    dependencies: [
        .package(url: "https://github.com/livekit/client-sdk-swift.git", from: "2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "PlayPalace",
            dependencies: [.product(name: "LiveKit", package: "client-sdk-swift")],
            path: "Sources"
        )
    ]
)
