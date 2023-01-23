// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JustonUI",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "JustonUI",
            targets: ["JustonUI"]
        ),
        .library(
            name: "SystemUI",
            targets: ["SystemUI"]
        ),
        .library(
            name: "DeclarativeUI",
            targets: ["DeclarativeUI"]
        ),
    ],
    dependencies: [
        .package(
            name: "Objective42",
            path: "../Objective42"
        ),
    ],
    targets: [
        .target(
            name: "JustonUI",
            dependencies: [
                "SystemUI",
                "DeclarativeUI",
            ],
            path: "Sources/JustonUI",
            exclude: [
                "3Party/Pinnable/LICENSE",
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
        .target(
            name: "SystemUI",
            dependencies: [
                "Objective42",
            ],
            path: "Sources/SystemUI",
            publicHeadersPath: "Include",
            cSettings: [
                .define("DEBUG", to: "1", .when(configuration: .debug)),
            ]
        ),
        .target(
            name: "DeclarativeUI",
            dependencies: [],
            path: "Sources/DeclarativeUI",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
    ]
)
