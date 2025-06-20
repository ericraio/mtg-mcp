import Foundation
import Card

/// Service for interacting with the Scryfall API
public struct ScryfallService {
    private static let baseURL = "https://api.scryfall.com"
    private static let userAgent = "MTG-MCP-Server/1.0"
    
    /// Searches for cards using Scryfall query syntax
    public static func searchCards(query: String, pageSize: Int = 5, page: Int = 1) async throws -> ScryfallSearchResult {
        var components = URLComponents(string: "\(baseURL)/cards/search")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "format", value: "json")
        ]
        
        guard let url = components.url else {
            throw ScryfallError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ScryfallError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw ScryfallError.httpError(httpResponse.statusCode)
        }
        
        let searchResult = try JSONDecoder().decode(ScryfallSearchResult.self, from: data)
        
        // Apply pagination
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, searchResult.data.count)
        
        if startIndex >= searchResult.data.count {
            return ScryfallSearchResult(data: [], totalCards: searchResult.totalCards, hasMore: false, nextPage: nil)
        }
        
        let paginatedCards = Array(searchResult.data[startIndex..<endIndex])
        let hasMore = endIndex < searchResult.data.count || searchResult.hasMore
        
        return ScryfallSearchResult(
            data: paginatedCards,
            totalCards: searchResult.totalCards,
            hasMore: hasMore,
            nextPage: searchResult.nextPage
        )
    }
    
    /// Gets a random card, optionally filtered by query
    public static func getRandomCard(query: String? = nil) async throws -> ScryfallCard {
        var components = URLComponents(string: "\(baseURL)/cards/random")!
        
        if let query = query {
            components.queryItems = [URLQueryItem(name: "q", value: query)]
        }
        
        guard let url = components.url else {
            throw ScryfallError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ScryfallError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw ScryfallError.httpError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(ScryfallCard.self, from: data)
    }
    
    /// Gets a card by name (exact or fuzzy matching)
    public static func getCardByName(name: String, fuzzy: Bool = true) async throws -> ScryfallCard {
        let searchType = fuzzy ? "fuzzy" : "exact"
        var components = URLComponents(string: "\(baseURL)/cards/named")!
        components.queryItems = [URLQueryItem(name: searchType, value: name)]
        
        guard let url = components.url else {
            throw ScryfallError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ScryfallError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw ScryfallError.httpError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(ScryfallCard.self, from: data)
    }
}

/// Scryfall API errors
public enum ScryfallError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from Scryfall API"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}

/// Scryfall search result
public struct ScryfallSearchResult: Codable {
    public let data: [ScryfallCard]
    public let totalCards: Int
    public let hasMore: Bool
    public let nextPage: String?
    
    private enum CodingKeys: String, CodingKey {
        case data
        case totalCards = "total_cards"
        case hasMore = "has_more"
        case nextPage = "next_page"
    }
}

/// Scryfall card representation
public struct ScryfallCard: Codable {
    public let id: String
    public let name: String
    public let manaCost: String?
    public let cmc: Double
    public let typeLine: String
    public let oracleText: String?
    public let power: String?
    public let toughness: String?
    public let loyalty: String?
    public let rarity: String
    public let setName: String?
    public let setCode: String?
    public let prices: ScryfallPrices?
    public let legalities: ScryfallLegalities?
    public let imageUris: ScryfallImageUris?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, cmc, power, toughness, loyalty, rarity, prices, legalities
        case manaCost = "mana_cost"
        case typeLine = "type_line"
        case oracleText = "oracle_text"
        case setName = "set_name"
        case setCode = "set"
        case imageUris = "image_uris"
    }
    
    /// Converts Scryfall card to internal Card model
    public func toCard() -> Card {
        let rarity = Rarity(from: self.rarity)
        
        return Card(
            id: id,
            name: name,
            manaCostString: manaCost ?? "",
            rarity: rarity
        )
    }
    
    /// Formats card information for display
    public func formatCardInfo() -> String {
        var info: [String] = []
        
        info.append("Name: \(name)")
        
        if let manaCost = manaCost, !manaCost.isEmpty {
            info.append("Mana Cost: \(manaCost)")
        }
        
        info.append("Type: \(typeLine)")
        
        if let oracleText = oracleText, !oracleText.isEmpty {
            info.append("Text: \(oracleText)")
        }
        
        if let power = power, let toughness = toughness {
            info.append("Power/Toughness: \(power)/\(toughness)")
        }
        
        if let loyalty = loyalty {
            info.append("Loyalty: \(loyalty)")
        }
        
        if let price = prices?.usd {
            info.append("Price (USD): $\(price)")
        }
        
        if let legalities = legalities {
            let legalFormats = legalities.legalFormats()
            if !legalFormats.isEmpty {
                info.append("Legal in: \(legalFormats.joined(separator: ", "))")
            }
        }
        
        return info.joined(separator: "\n")
    }
}

/// Scryfall price information
public struct ScryfallPrices: Codable {
    public let usd: String?
    public let usdFoil: String?
    public let eur: String?
    
    private enum CodingKeys: String, CodingKey {
        case usd
        case usdFoil = "usd_foil"
        case eur
    }
}

/// Scryfall legality information
public struct ScryfallLegalities: Codable {
    public let standard: String?
    public let pioneer: String?
    public let modern: String?
    public let legacy: String?
    public let vintage: String?
    public let commander: String?
    public let brawl: String?
    public let historic: String?
    public let alchemy: String?
    public let explorer: String?
    
    /// Returns list of formats where the card is legal
    public func legalFormats() -> [String] {
        var formats: [String] = []
        
        if standard == "legal" { formats.append("Standard") }
        if pioneer == "legal" { formats.append("Pioneer") }
        if modern == "legal" { formats.append("Modern") }
        if legacy == "legal" { formats.append("Legacy") }
        if vintage == "legal" { formats.append("Vintage") }
        if commander == "legal" { formats.append("Commander") }
        if brawl == "legal" { formats.append("Brawl") }
        if historic == "legal" { formats.append("Historic") }
        if alchemy == "legal" { formats.append("Alchemy") }
        if explorer == "legal" { formats.append("Explorer") }
        
        return formats
    }
}

/// Scryfall image URIs
public struct ScryfallImageUris: Codable {
    public let small: String?
    public let normal: String?
    public let large: String?
    public let png: String?
    public let artCrop: String?
    public let borderCrop: String?
    
    private enum CodingKeys: String, CodingKey {
        case small, normal, large, png
        case artCrop = "art_crop"
        case borderCrop = "border_crop"
    }
}