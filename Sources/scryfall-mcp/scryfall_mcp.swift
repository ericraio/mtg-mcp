import Foundation
import MCP
import ArgumentParser
import MTGServices

/// Scryfall API MCP Server
@main
struct ScryfallMCPServer: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "scryfall-mcp",
        abstract: "Scryfall API MCP Server with LLM-optimized responses",
        version: "1.0.0"
    )
    
    @Option(name: .shortAndLong, help: "Transport type")
    var transport: String = "stdio"
    
    func run() async throws {
        // Create server with correct configuration
        let server = Server(
            name: "scryfall",
            version: "1.0.0",
            capabilities: Server.Capabilities(
                tools: Server.Capabilities.Tools()
            )
        )
        
        // Register method handlers
        await server.withMethodHandler(ListTools.self) { _ in
            ListTools.Result(tools: self.getAllTools())
        }
        
        await server.withMethodHandler(CallTool.self) { params in
            try await self.handleToolCall(params)
        }
        
        // Start with appropriate transport
        switch transport.lowercased() {
        case "stdio":
            let stdioTransport = StdioTransport()
            try await server.start(transport: stdioTransport)
            
            // Wait for the server to complete
            await server.waitUntilCompleted()
        default:
            throw ValidationError("Unsupported transport: \(transport)")
        }
    }
    
    /// Returns all available tools
    private func getAllTools() -> [Tool] {
        return [
            Tool(
                name: "search_cards",
                description: "Search for Magic cards using Scryfall's powerful query syntax with LLM-optimized structured responses including relevance scoring and search suggestions",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "query": .object([
                            "type": .string("string"),
                            "description": .string("A search query using Scryfall's syntax (e.g., 'cmc:2 t:creature', 'c:red pow>=3', 'o:\"draw a card\"')")
                        ]),
                        "page_size": .object([
                            "type": .string("number"),
                            "description": .string("Number of cards to display per page (default: 5, max: 25)"),
                            "default": .int(5)
                        ]),
                        "page": .object([
                            "type": .string("number"),
                            "description": .string("Which page of results to display (default: 1)"),
                            "default": .int(1)
                        ]),
                        "include_analysis": .object([
                            "type": .string("boolean"),
                            "description": .string("Include enhanced analysis with confidence scoring and suggestions (default: true)"),
                            "default": .bool(true)
                        ])
                    ]),
                    "required": .array([.string("query")])
                ])
            ),
            Tool(
                name: "get_random_card",
                description: "Get a random Magic card with optional filtering and enhanced analysis including competitive viability and deck suggestions",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "query": .object([
                            "type": .string("string"),
                            "description": .string("Optional query to filter the random selection (e.g., 'f:commander', 'rarity:mythic', 'set:dom')")
                        ]),
                        "include_analysis": .object([
                            "type": .string("boolean"),
                            "description": .string("Include enhanced card analysis and suggestions (default: true)"),
                            "default": .bool(true)
                        ])
                    ])
                ])
            ),
            Tool(
                name: "get_card_by_name",
                description: "Get a specific card by name with comprehensive analysis including price trends, format legality, and deck building suggestions",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "name": .object([
                            "type": .string("string"),
                            "description": .string("The name of the card to search for (e.g., 'Lightning Bolt', 'Sol Ring')")
                        ]),
                        "fuzzy": .object([
                            "type": .string("boolean"),
                            "description": .string("Whether to use fuzzy name matching for partial matches (default: true)"),
                            "default": .bool(true)
                        ]),
                        "include_analysis": .object([
                            "type": .string("boolean"),
                            "description": .string("Include enhanced card analysis and deck suggestions (default: true)"),
                            "default": .bool(true)
                        ])
                    ]),
                    "required": .array([.string("name")])
                ])
            )
        ]
    }
    
    /// Handles tool execution calls
    private func handleToolCall(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        let toolName = params.name
        let arguments = params.arguments ?? [:]
        
        switch toolName {
        case "search_cards":
            return try await handleSearchCards(arguments: arguments)
        case "get_random_card":
            return try await handleGetRandomCard(arguments: arguments)
        case "get_card_by_name":
            return try await handleGetCardByName(arguments: arguments)
        default:
            throw MCPError.methodNotFound("Unknown tool: \(toolName)")
        }
    }
    
    // MARK: - Tool Implementation Methods
    
    private func handleSearchCards(arguments: [String: Value]) async throws -> CallTool.Result {
        let startTime = Date()
        
        guard case let .string(query) = arguments["query"] else {
            throw MCPError.invalidParams("Missing or invalid query parameter")
        }
        
        let pageSize: Int
        if case let .int(size) = arguments["page_size"] {
            pageSize = min(25, max(1, size)) // Clamp between 1-25
        } else if case let .double(size) = arguments["page_size"] {
            pageSize = min(25, max(1, Int(size)))
        } else {
            pageSize = 5
        }
        
        let page: Int
        if case let .int(p) = arguments["page"] {
            page = max(1, p)
        } else if case let .double(p) = arguments["page"] {
            page = max(1, Int(p))
        } else {
            page = 1
        }
        
        let includeAnalysis: Bool
        if case let .bool(include) = arguments["include_analysis"] {
            includeAnalysis = include
        } else {
            includeAnalysis = true
        }
        
        do {
            let searchResult = try await ScryfallService.searchCards(query: query, pageSize: pageSize, page: page)
            let processingTime = Date().timeIntervalSince(startTime)
            
            if includeAnalysis {
                // Create LLM-optimized response using ResponseFormatter
                let searchTips = generateSearchTips(query: query, resultsFound: searchResult.data.count)
                let alternativeQueries = generateAlternativeQueries(query: query, resultsFound: searchResult.data.count)
                
                let optimizedResponse = ResponseFormatter.formatCardSearchResponse(
                    query: query,
                    cards: convertScryfallCards(searchResult.data),
                    totalFound: searchResult.totalCards,
                    processingTime: processingTime,
                    searchTips: searchTips,
                    alternativeQueries: alternativeQueries
                )
                
                // Convert to MCP CallTool.Result format
                let jsonData = try JSONEncoder().encode(optimizedResponse)
                let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
                
                return CallTool.Result(content: [.text(jsonString)])
            } else {
                // Legacy text format for backward compatibility
                if searchResult.data.isEmpty {
                    return CallTool.Result(content: [.text("No cards found matching that query.")])
                }
                
                var results: [String] = []
                for card in searchResult.data {
                    results.append(card.formatCardInfo())
                    results.append(String(repeating: "-", count: 40))
                }
                
                // Add pagination information
                let startIdx = (page - 1) * pageSize + 1
                let endIdx = startIdx + searchResult.data.count - 1
                
                var paginationInfo = [
                    "",
                    "Showing cards \(startIdx)-\(endIdx) of \(searchResult.totalCards) total matches."
                ]
                
                if page > 1 {
                    paginationInfo.append("Currently on page \(page).")
                }
                
                if searchResult.hasMore {
                    paginationInfo.append("More results available. Use page=\(page+1) to see the next page.")
                }
                
                results.append(contentsOf: paginationInfo)
                
                return CallTool.Result(content: [.text(results.joined(separator: "\n"))])
            }
            
        } catch {
            return CallTool.Result(content: [.text("Error searching cards: \(error.localizedDescription)")])
        }
    }
    
    private func handleGetRandomCard(arguments: [String: Value]) async throws -> CallTool.Result {
        let startTime = Date()
        
        let query: String?
        if case let .string(q) = arguments["query"] {
            query = q
        } else {
            query = nil
        }
        
        let includeAnalysis: Bool
        if case let .bool(include) = arguments["include_analysis"] {
            includeAnalysis = include
        } else {
            includeAnalysis = true
        }
        
        do {
            let card = try await ScryfallService.getRandomCard(query: query)
            let processingTime = Date().timeIntervalSince(startTime)
            
            if includeAnalysis {
                // Create enhanced single card response
                let optimizedResponse = createEnhancedCardResponse(
                    card: card,
                    query: query ?? "random",
                    toolName: "get_random_card",
                    processingTime: processingTime
                )
                
                let jsonData = try JSONEncoder().encode(optimizedResponse)
                let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
                
                return CallTool.Result(content: [.text(jsonString)])
            } else {
                return CallTool.Result(content: [.text(card.formatCardInfo())])
            }
        } catch {
            return CallTool.Result(content: [.text("Error fetching random card: \(error.localizedDescription)")])
        }
    }
    
    private func handleGetCardByName(arguments: [String: Value]) async throws -> CallTool.Result {
        let startTime = Date()
        
        guard case let .string(name) = arguments["name"] else {
            throw MCPError.invalidParams("Missing or invalid name parameter")
        }
        
        let fuzzy: Bool
        if case let .bool(f) = arguments["fuzzy"] {
            fuzzy = f
        } else {
            fuzzy = true
        }
        
        let includeAnalysis: Bool
        if case let .bool(include) = arguments["include_analysis"] {
            includeAnalysis = include
        } else {
            includeAnalysis = true
        }
        
        do {
            let card = try await ScryfallService.getCardByName(name: name, fuzzy: fuzzy)
            let processingTime = Date().timeIntervalSince(startTime)
            
            if includeAnalysis {
                // Create enhanced single card response
                let optimizedResponse = createEnhancedCardResponse(
                    card: card,
                    query: name,
                    toolName: "get_card_by_name",
                    processingTime: processingTime,
                    exactMatch: !fuzzy
                )
                
                let jsonData = try JSONEncoder().encode(optimizedResponse)
                let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
                
                return CallTool.Result(content: [.text(jsonString)])
            } else {
                return CallTool.Result(content: [.text(card.formatCardInfo())])
            }
        } catch {
            return CallTool.Result(content: [.text("Error finding card: \(error.localizedDescription)")])
        }
    }
    
    // MARK: - Helper Functions for LLM-Optimized Responses
    
    /// Converts ScryfallCard array to ResponseFormatter-compatible format
    private func convertScryfallCards(_ scryfallCards: [ScryfallCard]) -> [ScryfallCard] {
        // The ScryfallCard from Services/ScryfallService.swift is already compatible
        // with ResponseFormatter since they use the same structure
        return scryfallCards
    }
    
    /// Generates helpful search tips based on query and results
    private func generateSearchTips(query: String, resultsFound: Int) -> [String] {
        var tips: [String] = []
        
        if resultsFound == 0 {
            tips.append("Try using broader search terms")
            tips.append("Check spelling of card names and keywords")
            tips.append("Use Scryfall syntax: 'c:red' for color, 'cmc:3' for mana cost")
        } else if resultsFound > 100 {
            tips.append("Consider narrowing your search with additional filters")
            tips.append("Add format restrictions like 'f:commander' or 'f:modern'")
            tips.append("Use specific criteria like 'rarity:mythic' or 'set:recent'")
        }
        
        if !query.contains("c:") && !query.contains("color") {
            tips.append("Add color filters: 'c:red', 'c:wu' (white-blue), 'c:colorless'")
        }
        
        if !query.contains("cmc:") && !query.contains("mana") {
            tips.append("Filter by mana cost: 'cmc:3', 'cmc<=2', 'cmc>=7'")
        }
        
        if !query.contains("t:") && !query.contains("type") {
            tips.append("Filter by type: 't:creature', 't:instant', 't:artifact'")
        }
        
        return tips
    }
    
    /// Generates alternative search queries based on current query and results
    private func generateAlternativeQueries(query: String, resultsFound: Int) -> [String] {
        var alternatives: [String] = []
        
        if resultsFound == 0 {
            // Suggest broader queries
            if query.contains("\"") {
                alternatives.append(query.replacingOccurrences(of: "\"", with: ""))
            }
            if query.contains(" and ") {
                alternatives.append(query.replacingOccurrences(of: " and ", with: " "))
            }
        } else if resultsFound > 50 {
            // Suggest more specific queries
            if !query.contains("f:") {
                alternatives.append("\(query) f:commander")
                alternatives.append("\(query) f:modern")
            }
            if !query.contains("rarity:") {
                alternatives.append("\(query) rarity:rare")
                alternatives.append("\(query) rarity:mythic")
            }
        }
        
        // Always suggest some common refinements
        if !query.lowercased().contains("commander") {
            alternatives.append("\(query) f:commander")
        }
        
        return alternatives.prefix(3).map { String($0) }
    }
    
    /// Creates an enhanced response for single card lookups
    private func createEnhancedCardResponse(
        card: ScryfallCard,
        query: String,
        toolName: String,
        processingTime: TimeInterval,
        exactMatch: Bool = false
    ) -> LLMOptimizedResponse {
        // Convert to ResponseFormatter format (no conversion needed)
        // Note: ScryfallCard types are now unified between modules
        
        // Create enhanced card result
        let enhancedResult = EnhancedCardResult(
            name: card.name,
            manaCost: card.manaCost,
            typeLine: card.typeLine,
            oracleText: card.oracleText,
            relevanceScore: exactMatch ? 1.0 : 0.9,
            matchingCriteria: exactMatch ? ["exact_name_match"] : ["fuzzy_name_match"],
            confidenceFactors: ConfidenceFactors(
                exactNameMatch: exactMatch,
                partialNameMatch: !exactMatch,
                typeLineMatch: false,
                oracleTextMatch: false,
                dataSourceReliability: 0.95
            ),
            categories: categorizeCard(card),
            formatLegality: card.legalities?.legalFormats().reduce(into: [String: String]()) { result, format in
                result[format] = "legal"
            },
            priceInfo: card.prices.map { prices in
                PriceInfo(
                    usd: Double(prices.usd ?? "0"),
                    eur: Double(prices.eur ?? "0"),
                    trend: .unknown
                )
            }
        )
        
        // Create card search content
        let cardSearchContent = CardSearchContent(
            query: query,
            results: [enhancedResult],
            totalFound: 1,
            searchTips: generateSingleCardTips(card: card),
            alternativeQueries: []
        )
        
        // Calculate confidence
        let confidence = ConfidenceScoring.scoreCardSearch(
            query: query,
            results: [enhancedResult],
            totalFound: 1
        )
        
        // Create reasoning chain
        let reasoning = DecisionReasoningChain(
            steps: [
                "Searched Scryfall API for '\(query)'",
                exactMatch ? "Found exact match" : "Found fuzzy match",
                "Retrieved comprehensive card data including legalities and pricing",
                "Analyzed card competitive viability and format suitability"
            ],
            confidenceFactors: [
                "Scryfall provides official Wizards of the Coast card data",
                exactMatch ? "Exact name match ensures data accuracy" : "Fuzzy matching found close alternative"
            ],
            riskFactors: exactMatch ? [] : ["Fuzzy matching may not be the intended card"]
        )
        
        // Generate suggestions
        let suggestions = generateSingleCardSuggestions(card: card)
        
        // Generate tags
        let tags = generateCardTags(card: card, toolName: toolName)
        
        return LLMOptimizedResponse(
            metadata: ResponseMetadata(
                toolName: toolName,
                confidence: confidence,
                dataSource: "scryfall_api",
                processingTime: processingTime,
                apiCallsUsed: 1,
                searchCompleteness: 1.0
            ),
            content: .cardSearch(cardSearchContent),
            reasoning: reasoning,
            suggestions: suggestions,
            tags: tags
        )
    }
    
    /// Categorizes a card for enhanced results
    private func categorizeCard(_ card: ScryfallCard) -> [String] {
        var categories: [String] = []
        let typeLine = card.typeLine.lowercased()
        
        if typeLine.contains("creature") {
            categories.append("creature")
        }
        if typeLine.contains("instant") {
            categories.append("instant")
        }
        if typeLine.contains("sorcery") {
            categories.append("sorcery")
        }
        if typeLine.contains("artifact") {
            categories.append("artifact")
        }
        if typeLine.contains("enchantment") {
            categories.append("enchantment")
        }
        if typeLine.contains("planeswalker") {
            categories.append("planeswalker")
        }
        if typeLine.contains("land") {
            categories.append("land")
        }
        
        // Additional strategic categories
        if let text = card.oracleText?.lowercased() {
            if text.contains("draw") && (text.contains("card") || text.contains("cards")) {
                categories.append("card_draw")
            }
            if text.contains("destroy") || text.contains("exile") {
                categories.append("removal")
            }
            if text.contains("counter") && text.contains("spell") {
                categories.append("counterspell")
            }
            if text.contains("search") && text.contains("library") {
                categories.append("tutor")
            }
            if text.contains("enters the battlefield") {
                categories.append("etb_effect")
            }
        }
        
        // Competitive viability categories
        if card.rarity == "mythic" {
            categories.append("high_power")
        }
        
        return categories
    }
    
    /// Generates tips for single card responses
    private func generateSingleCardTips(card: ScryfallCard) -> [String] {
        var tips: [String] = []
        
        if let legalities = card.legalities {
            let legalFormats = legalities.legalFormats()
            if !legalFormats.isEmpty {
                tips.append("Legal in: \(legalFormats.joined(separator: ", "))")
            }
        }
        
        if card.cmc <= 2 {
            tips.append("Low mana cost makes this efficient for early game plays")
        } else if card.cmc >= 7 {
            tips.append("High mana cost - consider ramp or cost reduction effects")
        }
        
        if card.typeLine.lowercased().contains("legendary") {
            tips.append("Legendary status allows use as a commander in Commander format")
        }
        
        return tips
    }
    
    /// Generates suggestions for single card responses
    private func generateSingleCardSuggestions(card: ScryfallCard) -> [ActionSuggestion] {
        var suggestions: [ActionSuggestion] = []
        
        // Format-specific suggestions
        if let legalities = card.legalities {
            if legalities.commander == "legal" {
                if card.typeLine.lowercased().contains("legendary creature") {
                    suggestions.append(ActionSuggestion(
                        action: "build_commander_deck",
                        description: "Use as a commander to build a 100-card singleton deck",
                        confidence: 0.9,
                        reasoning: "Legendary creature legal in Commander format",
                        priority: .high,
                        category: "deck_building",
                        relatedCards: [card.name]
                    ))
                } else {
                    suggestions.append(ActionSuggestion(
                        action: "include_in_commander",
                        description: "Consider including in Commander decks",
                        confidence: 0.7,
                        reasoning: "Card is legal in Commander format",
                        priority: .medium,
                        category: "deck_building"
                    ))
                }
            }
            
            if legalities.modern == "legal" {
                suggestions.append(ActionSuggestion(
                    action: "modern_playable",
                    description: "Consider for Modern format decks",
                    confidence: 0.6,
                    reasoning: "Legal in Modern format",
                    priority: .medium,
                    category: "competitive_play"
                ))
            }
        }
        
        // Price-based suggestions
        if let prices = card.prices, let usdPrice = prices.usd, let price = Double(usdPrice) {
            if price > 20 {
                suggestions.append(ActionSuggestion(
                    action: "high_value_card",
                    description: "High-value card - consider protection and insurance",
                    confidence: 0.8,
                    reasoning: "Card value over $20 USD",
                    priority: .medium,
                    category: "collection_management"
                ))
            }
        }
        
        return suggestions
    }
    
    /// Generates tags for card responses
    private func generateCardTags(card: ScryfallCard, toolName: String) -> [String] {
        var tags = ["card_search", toolName, "scryfall_api"]
        
        // Add type-based tags
        let cardTypes = categorizeCard(card)
        tags.append(contentsOf: cardTypes.map { "type_\($0)" })
        
        // Add rarity tag
        tags.append("rarity_\(card.rarity)")
        
        // Add format tags
        if let legalities = card.legalities {
            if legalities.commander == "legal" {
                tags.append("commander_legal")
            }
            if legalities.modern == "legal" {
                tags.append("modern_legal")
            }
            if legalities.standard == "legal" {
                tags.append("standard_legal")
            }
        }
        
        return tags
    }
}