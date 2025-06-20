import ArgumentParser
import Foundation
import Scryfall

/// Command-line tool for running Magic: The Gathering deck simulations
@main
@MainActor
struct Scryfall2Landlord: AsyncParsableCommand {
    nonisolated
        static var configuration: CommandConfiguration
    {
        CommandConfiguration(
            commandName: "landlord",
            abstract: "A tool for simulating and analyzing Magic: The Gathering deck performance",
            version: "1.0.0",
            subcommands: []
        )
    }

    mutating func run() async throws {
        guard let jsonData = try await Scryfall.fetchLatest() else {
            print("failed to fetch")
            return
        }
        print("\(jsonData)")

        // Parse JSON
        print("Parsing Scryfall card data")
        let decoder = JSONDecoder()
        var scryfallCards = try decoder.decode([ScryfallCard].self, from: jsonData)

        // Filter out cards that are not legal
        print("Filtering cards")
        scryfallCards = scryfallCards.filter { !($0.notLegal()) }

        // Flatten card faces
        print("Flattening card faces")
        scryfallCards = Scryfall.flattenCardFaces(cards: scryfallCards)

        // Encode the data
        print("Encoding data")
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(scryfallCards)

        // Compress the data
        print("Compressing data")
        guard let compressedData = await Scryfall.compress(data: encodedData) else {
            print("Failed to compress data")
            return
        }

        // Ensure output directory exists
        let outputFileURL = URL(fileURLWithPath: "Sources/Database/Resources/all_cards.landlord")
        let outputDirectory = outputFileURL.deletingLastPathComponent()

        try FileManager.default.createDirectory(
            at: outputDirectory, withIntermediateDirectories: true)

        // Write the compressed data to file
        print("Writing all_cards.landlord to \(outputFileURL.path)")
        try compressedData.write(to: outputFileURL)

        print("Conversion completed successfully")
    }
}
