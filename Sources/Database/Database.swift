import Foundation
import Card
import Scryfall
import SwiftGzip

public class CardData {
    // Singleton instance
    public nonisolated(unsafe) static let shared = CardData()
    
    // Cache of loaded cards
    private nonisolated(unsafe) static var DATA: [ScryfallCard] = []
    
    // Cards in this instance
    public var cards: [ScryfallCard] = []
    
    // Private initializer for singleton
    private init() {}
    
    // Create a new instance (for compatibility with original code)
    public static func newCardData() -> CardData {
        return CardData()
    }
    
    // Find a card by name (case insensitive)
    public func findByName(name: String) -> Card? {
        for card in cards {
            if card.name?.lowercased() == name.lowercased() {
                return card.convertToCard()
            }
        }
        return nil
    }
    
    // Load card data from compressed file
    public func load() async throws {
        // If already loaded, return
        if !cards.isEmpty {
            print("Card data already loaded in this instance")
            return
        }
        
        // If data is cached, use it
        if !CardData.DATA.isEmpty {
            print("Using cached card data")
            cards = CardData.DATA
            return
        }
        
        print("Starting to load card database...")
        
        // Try to load from main bundle
        guard let fileURL = Bundle.module.url(forResource: "all_cards", withExtension: "mtgdata") else {
            print("❌ Card database file not found")
            throw CardDataError.fileNotFound
        }
        
        print("Card database file found, reading data...")
        
        // Read the compressed data
        let compressedData: Data
        do {
            compressedData = try Data(contentsOf: fileURL)
            print("Read \(compressedData.count) bytes of compressed data")
        } catch {
            print("❌ Failed to read card database file: \(error.localizedDescription)")
            throw error
        }
        
        print("Decompressing card database...")
        
        // Decompress the data
        let decompressedData: Data
        do {
            guard let data = try? await decompress(data: compressedData) else {
                print("❌ Failed to decompress card database")
                throw CardDataError.decompressionFailed
            }
            decompressedData = data
            print("Decompressed to \(decompressedData.count) bytes")
        } catch {
            print("❌ Error during decompression: \(error.localizedDescription)")
            throw error
        }
        
        print("Decoding card database...")
        
        // Decode the data
        do {
            // Use JSONDecoder instead of Gob (Swift doesn't have direct Gob equivalent)
            // This assumes the file is JSON data compressed with gzip
            let decoder = JSONDecoder()
            let startTime = Date()
            cards = try decoder.decode([ScryfallCard].self, from: decompressedData)
            let elapsed = Date().timeIntervalSince(startTime)
            CardData.DATA = cards
            print("✅ Total cards loaded: \(CardData.DATA.count) in \(String(format: "%.2f", elapsed)) seconds")
        } catch {
            print("❌ Failed to decode card database: \(error.localizedDescription)")
            throw CardDataError.decodingFailed(error)
        }
    }
    
    // Helper function to decompress gzip data
    private func decompress(data: Data) async throws -> Data {
        let compressor = GzipDecompressor()
        return try await compressor.unzip(data: data)
    }
}

// Error types for CardData
enum CardDataError: Error {
    case fileNotFound
    case decompressionFailed
    case decodingFailed(Error)
}

// Extension for more Swift-like error handling
extension CardData {
    // Alternative load function that returns a Result
    func loadWithResult() async throws -> Result<Void, CardDataError> {
        do {
            try await load()
            return .success(())
        } catch let error as CardDataError {
            return .failure(error)
        } catch {
            return .failure(.decodingFailed(error))
        }
    }
}
