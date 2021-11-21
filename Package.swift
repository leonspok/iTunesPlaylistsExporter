// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iTunesPlaylistsExporter",
    products: [
        .executable(name: "itpexp", targets: [ "CLI" ])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "1.0.2"))
    ],
    targets: [
        .executableTarget(
            name: "CLI",
            dependencies: [
                "iTunesPlaylistsExporter",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "iTunesPlaylistsExporter",
            dependencies: []
        ),
    ]
)
