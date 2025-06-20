import Foundation
import Scryfall

/// Processor for downloading and converting Scryfall card data
public struct CardDataProcessor {
    private let defaultOutputDir = "Sources/Database/Resources"
    
    public init() {}
    
    /// Process card data from Scryfall
    public func process(outputDir: String? = nil, force: Bool = false) async throws {
        let targetDir = outputDir ?? defaultOutputDir
        let outputFileURL = URL(fileURLWithPath: "\(targetDir)/all_cards.mtgdata")
        
        // Check if we need to refresh the data
        if !force && shouldSkipUpdate(for: outputFileURL) {
            print("📋 Card data is recent, skipping update (use --force to override)")
            return
        }
        
        print("📡 Fetching latest card data from Scryfall...")
        guard let jsonData = try await Scryfall.fetchLatest() else {
            throw CardDataError.fetchFailed("Failed to fetch data from Scryfall")
        }
        print("✅ Downloaded \(jsonData.count) bytes of card data")

        // Parse JSON
        print("🔍 Parsing Scryfall card data...")
        let decoder = JSONDecoder()
        var scryfallCards = try decoder.decode([ScryfallCard].self, from: jsonData)
        print("📊 Parsed \(scryfallCards.count) cards")

        // Filter out cards that are not legal
        print("🔧 Filtering cards...")
        let originalCount = scryfallCards.count
        scryfallCards = scryfallCards.filter { !($0.notLegal()) }
        print("✅ Filtered to \(scryfallCards.count) legal cards (removed \(originalCount - scryfallCards.count))")

        // Flatten card faces
        print("🔀 Flattening card faces...")
        scryfallCards = Scryfall.flattenCardFaces(cards: scryfallCards)
        print("✅ Flattened to \(scryfallCards.count) card entries")

        // Encode the data
        print("📦 Encoding data...")
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(scryfallCards)
        print("✅ Encoded \(encodedData.count) bytes")

        // Compress the data
        print("🗜️ Compressing data...")
        guard let compressedData = await Scryfall.compress(data: encodedData) else {
            throw CardDataError.compressionFailed("Failed to compress data")
        }
        let compressionRatio = Double(compressedData.count) / Double(encodedData.count)
        print("✅ Compressed to \(compressedData.count) bytes (ratio: \(String(format: "%.1f%%", compressionRatio * 100)))")

        // Ensure output directory exists
        let outputDirectory = outputFileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: outputDirectory, 
            withIntermediateDirectories: true,
            attributes: nil
        )

        // Write the compressed data to file
        print("💾 Writing to \(outputFileURL.path)...")
        try compressedData.write(to: outputFileURL)
        
        // Verify the written file
        let writtenSize = try FileManager.default.attributesOfItem(atPath: outputFileURL.path)[.size] as? Int ?? 0
        print("✅ Successfully wrote \(writtenSize) bytes to all_cards.landlord")
        
        print("🎉 Card data processing completed successfully!")
    }
    
    /// Check if we should skip updating based on file age
    private func shouldSkipUpdate(for fileURL: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return false
        }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let modificationDate = attributes[.modificationDate] as? Date {
                let hoursSinceUpdate = abs(modificationDate.timeIntervalSinceNow) / 3600
                // Skip if file is less than 6 hours old
                return hoursSinceUpdate < 6
            }
        } catch {
            print("⚠️ Could not check file age: \(error.localizedDescription)")
        }
        
        return false
    }
}

/// Errors that can occur during card data processing
public enum CardDataError: Error, LocalizedError {
    case fetchFailed(String)
    case compressionFailed(String)
    case processingFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .fetchFailed(let message):
            return "Card data fetch failed: \(message)"
        case .compressionFailed(let message):
            return "Card data compression failed: \(message)"
        case .processingFailed(let message):
            return "Card data processing failed: \(message)"
        }
    }
}