// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ANSIMarkdown",
    products: [
        .library(
            name: "ANSIMarkdown",
            targets: ["ANSIMarkdown"]),
        .executable(
            name: "ANSIMarkdownDemo",
            targets: ["ANSIMarkdownDemo"]),
    ],
    targets: [
        .target(
            name: "ANSIMarkdown"),
        .executableTarget(
            name: "ANSIMarkdownDemo",
            dependencies: ["ANSIMarkdown"]),
        .testTarget(
            name: "ANSIMarkdownTests",
            dependencies: ["ANSIMarkdown"]
        ),
    ]
)
