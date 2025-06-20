import Foundation
import SwiftGzip
import Card

/// Core error types for Scryfall API operations  
public enum ScryfallError: Error {
    case invalidURL
    case invalidData
    case invalidResponse
    case jsonParsingError(Error)
    case notFound
}

public struct Scryfall {
    public static func encode(cards: [ScryfallCard]) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(cards)
    }

    public static func fetchLatest() async throws -> Data? {
        let bulkDataURL = URL(string: "https://api.scryfall.com/bulk-data")!
        
        let (bulkData, bulkResponse) = try await URLSession.shared.data(from: bulkDataURL)

        guard let httpResponse = bulkResponse as? HTTPURLResponse else {
            throw ScryfallError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            print("HTTP Response: \(httpResponse)")
            throw ScryfallError.invalidResponse
        }

        struct BulkDataResponse: Decodable {
            struct BulkDataItem: Decodable {
                let download_uri: String
                let type: String
                let name: String
            }

            let data: [BulkDataItem]
        }

        let bulkDataResponse: BulkDataResponse
        do {
            bulkDataResponse = try JSONDecoder().decode(BulkDataResponse.self, from: bulkData)
        } catch {
            throw ScryfallError.jsonParsingError(error)
        }

        // Find the oracle cards item (usually the first one, but let's make sure)
        guard let oracleCardsItem = bulkDataResponse.data.first(where: { $0.type == "oracle_cards" }) else {
            throw ScryfallError.invalidData
        }

        // Step 3: Download the oracle cards data
        let oracleCardsURL = URL(string: oracleCardsItem.download_uri)!

        print("Downloading Oracle Cards from: \(oracleCardsURL.absoluteString)")

        let (oracleCardsData, oracleCardsResponse) = try await URLSession.shared.data(from: oracleCardsURL)

        guard let httpResponse = oracleCardsResponse as? HTTPURLResponse, 
            httpResponse.statusCode == 200 else {
            throw ScryfallError.invalidResponse
        }

        print("Downloaded \(oracleCardsData.count) bytes of Oracle Cards data")

        return oracleCardsData
    }

    public static func compress(data: Data) async -> Data? {
        let compressor = GzipCompressor(level: .bestCompression)
        do {
            return try await compressor.zip(data: data)
        } catch {
            print("Compression error: \(error)")
            return nil
        }
    }
    
    // Flatten card faces into individual cards
    public static func flattenCardFaces(cards: [ScryfallCard]) -> [ScryfallCard] {
        var result = cards
        
        for card in cards {
            guard let cardFaces = card.cardFaces else { continue }
            
            for var cardFace in cardFaces {
                if cardFace.imageUris == nil {
                    cardFace.imageUris = card.imageUris
                }
                cardFace.set = card.set
                cardFace.oracleId = card.oracleId
                cardFace.id = card.id
                cardFace.rarity = card.rarity
                cardFace.collectorNumber = card.collectorNumber
                result.append(cardFace)
            }
        }
        
        return result
    }
}