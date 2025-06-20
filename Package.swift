// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mtg-mcp",
    platforms: [.macOS(.v13)],
    products: [
        .executable(
            name: "mtg-mcp",
            targets: ["mtg-mcp"]
        ),
        .executable(
            name: "scryfall-mcp",
            targets: ["scryfall-mcp"]
        ),
        .executable(
            name: "edhrec-mcp",
            targets: ["edhrec-mcp"]
        ),
        .executable(
            name: "mtg",
            targets: ["mtg-data-cli"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.9.0"),
        .package(url: "https://github.com/mihai8804858/swift-gzip", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "mtg-data-cli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftGzip", package: "swift-gzip"),
                "Scryfall",
                "Database",
            ]
        ),
        .executableTarget(
            name: "mtg-mcp",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Card",
                "MTGServices",
            ]
        ),
        .executableTarget(
            name: "scryfall-mcp",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Card",
                "MTGServices",
            ]
        ),
        .executableTarget(
            name: "edhrec-mcp",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Card",
                "MTGServices",
            ]
        ),
        .testTarget(
            name: "mtg-mcpTests",
            dependencies: ["mtg-mcp", "Card", "MTGServices"],
            resources: [
                .copy("TestData")
            ]
        ),
        .target(
            name: "MTGServices",
            dependencies: [
                "Card",
                "Scryfall",
                "Database",
                .product(name: "SwiftGzip", package: "swift-gzip"),
            ]
        ),
        .target(name: "Bipartite"),
        .target(name: "Card"),
        .target(
            name: "Scryfall",
            dependencies: [
                "Card",
                .product(name: "SwiftGzip", package: "swift-gzip"),
            ]
        ),
        .target(
            name: "Deck",
            dependencies: ["Card", "Database"]
        ),
        .target(
            name: "Hand",
            dependencies: ["Card", "Bipartite", "Mulligan"]
        ),
        .target(
            name: "Simulation",
            dependencies: ["Deck", "Card", "Hand", "Mulligan"]
        ),
        .target(
            name: "Mulligan",
            dependencies: ["Card"]
        ),
        .target(
            name: "Database",
            dependencies: [
                "Card",
                "Scryfall",
                .product(name: "SwiftGzip", package: "swift-gzip"),
            ],
            resources: [
                .copy("Resources/all_cards.mtgdata"),
                .copy("Resources/all_rules.mtgdata"),
                .copy("Resources/rules")
            ]
        ),
        .testTarget(
            name: "BipartiteTests",
            dependencies: ["Bipartite"]
        ),
        .testTarget(
            name: "MulliganTests",
            dependencies: ["Mulligan"]
        ),
        .testTarget(
            name: "HandTests",
            dependencies: ["Hand", "Card"]
        ),
        .testTarget(
            name: "CardTests",
            dependencies: ["Card"]
        ),
        .testTarget(
            name: "DeckTests",
            dependencies: ["Deck", "Card"]
        ),
    ]
)
