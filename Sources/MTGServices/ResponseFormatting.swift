import Foundation

// MARK: - ScryfallService Integration
// Note: ScryfallCard types are now available from ScryfallService.swift in this module

// MARK: - Response Formatting System for LLM-Optimized MTG MCP

/// Core response formatting engine that creates structured, LLM-friendly responses
public struct ResponseFormatter {
    
    // MARK: - Main Formatting Functions
    
    /// Formats a complete LLM-optimized response with metadata and structured content
    public static func formatResponse<T: Codable>(
        toolName: String,
        content: T,
        confidence: Double,
        dataSource: String,
        processingTime: TimeInterval,
        reasoning: DecisionReasoningChain? = nil,
        suggestions: [ActionSuggestion] = [],
        tags: [String] = [],
        apiCallsUsed: Int? = nil,
        searchCompleteness: Double? = nil
    ) -> LLMOptimizedResponse {
        
        let metadata = ResponseMetadata(
            toolName: toolName,
            confidence: confidence,
            dataSource: dataSource,
            processingTime: processingTime,
            apiCallsUsed: apiCallsUsed,
            searchCompleteness: searchCompleteness
        )
        
        // Convert content to appropriate ResponseContent type
        let responseContent = convertToResponseContent(content)
        
        return LLMOptimizedResponse(
            metadata: metadata,
            content: responseContent,
            reasoning: reasoning,
            suggestions: suggestions,
            tags: tags
        )
    }
    
    /// Creates a formatted card search response optimized for LLM understanding
    public static func formatCardSearchResponse(
        query: String,
        cards: [ScryfallCard],
        totalFound: Int,
        processingTime: TimeInterval,
        confidence: Double? = nil,
        searchTips: [String] = [],
        alternativeQueries: [String] = []
    ) -> LLMOptimizedResponse {
        
        let enhancedResults = cards.map { card in
            createEnhancedCardResult(from: card, query: query)
        }
        
        let cardSearchContent = CardSearchContent(
            query: query,
            results: enhancedResults,
            totalFound: totalFound,
            searchTips: searchTips,
            alternativeQueries: alternativeQueries
        )
        
        let finalConfidence = confidence ?? ConfidenceScoring.scoreCardSearch(
            query: query,
            results: enhancedResults,
            totalFound: totalFound
        )
        
        let reasoning = createCardSearchReasoning(
            query: query,
            resultsCount: cards.count,
            totalFound: totalFound
        )
        
        let suggestions = generateCardSearchSuggestions(
            query: query,
            results: enhancedResults,
            totalFound: totalFound
        )
        
        let tags = generateCardSearchTags(query: query, results: enhancedResults)
        
        return formatResponse(
            toolName: "search_cards",
            content: cardSearchContent,
            confidence: finalConfidence,
            dataSource: "scryfall_api",
            processingTime: processingTime,
            reasoning: reasoning,
            suggestions: suggestions,
            tags: tags,
            apiCallsUsed: 1,
            searchCompleteness: Double(cards.count) / Double(max(totalFound, 1))
        )
    }
    
    /// Creates a formatted combo lookup response optimized for LLM understanding
    public static func formatComboLookupResponse(
        queriedCards: [String],
        combos: [ComboResult],
        relatedCombos: [ComboResult] = [],
        nearMisses: [NearMissCombo] = [],
        processingTime: TimeInterval,
        confidence: Double? = nil,
        apiSuccess: Bool = true
    ) -> LLMOptimizedResponse {
        
        let comboContent = ComboLookupContent(
            queriedCards: queriedCards,
            combosFound: combos,
            relatedCombos: relatedCombos,
            nearMisses: nearMisses,
            deckSynergies: analyzeDeckSynergies(from: combos)
        )
        
        let finalConfidence = confidence ?? ConfidenceScoring.scoreComboLookup(
            queriedCards: queriedCards,
            combosFound: combos,
            apiCallSuccess: apiSuccess
        )
        
        let reasoning = createComboLookupReasoning(
            queriedCards: queriedCards,
            combosFound: combos.count,
            apiSuccess: apiSuccess
        )
        
        let suggestions = generateComboSuggestions(
            queriedCards: queriedCards,
            combos: combos,
            nearMisses: nearMisses
        )
        
        let tags = generateComboTags(combos: combos)
        
        return formatResponse(
            toolName: "lookup_combo",
            content: comboContent,
            confidence: finalConfidence,
            dataSource: "commander_spellbook_api",
            processingTime: processingTime,
            reasoning: reasoning,
            suggestions: suggestions,
            tags: tags,
            apiCallsUsed: 1
        )
    }
    
    /// Creates a formatted game action response optimized for LLM understanding
    public static func formatGameActionResponse(
        action: String,
        result: String,
        gameState: GameStateSnapshot,
        processingTime: TimeInterval,
        playAnalysis: PlayAnalysis? = nil,
        confidence: Double? = nil,
        simulationBacked: Bool = false
    ) -> LLMOptimizedResponse {
        
        let gameActionContent = GameActionContent(
            action: action,
            result: result,
            gameStateUpdate: gameState,
            playAnalysis: playAnalysis
        )
        
        let finalConfidence = confidence ?? ConfidenceScoring.scoreGameAction(
            actionType: action,
            gameStateValidity: true,
            simulationBacked: simulationBacked
        )
        
        let reasoning = createGameActionReasoning(
            action: action,
            simulationBacked: simulationBacked
        )
        
        let suggestions = generateGameActionSuggestions(
            action: action,
            gameState: gameState,
            playAnalysis: playAnalysis
        )
        
        let tags = generateGameActionTags(action: action, gameState: gameState)
        
        return formatResponse(
            toolName: extractToolNameFromAction(action),
            content: gameActionContent,
            confidence: finalConfidence,
            dataSource: simulationBacked ? "simulation_engine" : "heuristic_analysis",
            processingTime: processingTime,
            reasoning: reasoning,
            suggestions: suggestions,
            tags: tags
        )
    }
    
    /// Creates a formatted EDHREC analysis response optimized for LLM understanding
    public static func formatEDHRecResponse(
        commander: String,
        totalDecks: Int,
        recommendations: [EDHRecRecommendation],
        deckComparison: DeckComparison,
        categories: [CategorySummary],
        processingTime: TimeInterval,
        confidence: Double? = nil,
        apiSuccess: Bool = true
    ) -> LLMOptimizedResponse {
        
        let edhrecContent = EDHRecAnalysisContent(
            commander: commander,
            totalDecks: totalDecks,
            recommendations: recommendations,
            deckComparison: deckComparison,
            categoryBreakdown: categories
        )
        
        let finalConfidence = confidence ?? ConfidenceScoring.scoreEDHRecAnalysis(
            commanderFound: apiSuccess,
            deckCount: totalDecks,
            categoriesAvailable: categories.count,
            apiResponseComplete: apiSuccess
        )
        
        let reasoning = createEDHRecReasoning(
            commander: commander,
            totalDecks: totalDecks,
            apiSuccess: apiSuccess
        )
        
        let suggestions = generateEDHRecSuggestions(
            recommendations: recommendations,
            deckComparison: deckComparison
        )
        
        let tags = generateEDHRecTags(
            commander: commander,
            categories: categories,
            powerLevel: deckComparison.powerLevelEstimate
        )
        
        return formatResponse(
            toolName: "analyze_edhrec",
            content: edhrecContent,
            confidence: finalConfidence,
            dataSource: "edhrec_api",
            processingTime: processingTime,
            reasoning: reasoning,
            suggestions: suggestions,
            tags: tags,
            apiCallsUsed: 1
        )
    }
    
    // MARK: - Helper Functions for Content Creation
    
    /// Converts generic content to appropriate ResponseContent enum case
    private static func convertToResponseContent<T: Codable>(_ content: T) -> ResponseContent {
        // Use type inspection to determine appropriate ResponseContent case
        switch content {
        case let cardSearch as CardSearchContent:
            return .cardSearch(cardSearch)
        case let comboLookup as ComboLookupContent:
            return .comboLookup(comboLookup)
        case let gameAction as GameActionContent:
            return .gameAction(gameAction)
        case let edhrecAnalysis as EDHRecAnalysisContent:
            return .edhrecAnalysis(edhrecAnalysis)
        case let deckAnalysis as DeckAnalysisContent:
            return .deckAnalysis(deckAnalysis)
        case let ruleValidation as RuleValidationContent:
            return .ruleValidation(ruleValidation)
        case let simulation as SimulationContent:
            return .simulation(simulation)
        default:
            // Fallback - create a basic game action content
            return .gameAction(GameActionContent(
                action: "unknown",
                result: "Content type not recognized",
                gameStateUpdate: GameStateSnapshot(cardsInDeck: 0, cardsInHand: 0, handComposition: [:])
            ))
        }
    }
    
    /// Creates an enhanced card result from Scryfall data
    private static func createEnhancedCardResult(from card: ScryfallCard, query: String) -> EnhancedCardResult {
        let relevanceScore = calculateCardRelevance(card: card, query: query)
        let matchingCriteria = identifyMatchingCriteria(card: card, query: query)
        let confidenceFactors = createConfidenceFactors(card: card, query: query)
        let categories = categorizeCard(card)
        
        let formatLegality = card.legalities?.legalFormats().reduce(into: [String: String]()) { result, format in
            result[format] = "legal"
        }
        
        let priceInfo = card.prices.map { prices in
            PriceInfo(
                usd: Double(prices.usd ?? "0"),
                eur: Double(prices.eur ?? "0"),
                trend: .unknown
            )
        }
        
        return EnhancedCardResult(
            name: card.name,
            manaCost: card.manaCost,
            typeLine: card.typeLine,
            oracleText: card.oracleText,
            relevanceScore: relevanceScore,
            matchingCriteria: matchingCriteria,
            confidenceFactors: confidenceFactors,
            categories: categories,
            formatLegality: formatLegality,
            priceInfo: priceInfo
        )
    }
    
    /// Calculates relevance score for a card against a search query
    private static func calculateCardRelevance(card: ScryfallCard, query: String) -> Double {
        let queryLower = query.lowercased()
        let cardName = card.name.lowercased()
        let cardText = (card.oracleText ?? "").lowercased()
        let cardType = card.typeLine.lowercased()
        
        var relevance = 0.0
        
        // Exact name match gets highest score
        if cardName == queryLower {
            relevance += 1.0
        } else if cardName.contains(queryLower) {
            relevance += 0.8
        }
        
        // Type line matches
        if cardType.contains(queryLower) {
            relevance += 0.6
        }
        
        // Oracle text matches
        if cardText.contains(queryLower) {
            relevance += 0.4
        }
        
        // Mana cost matches (simplified)
        if query.contains("{") && card.manaCost?.contains(queryLower) == true {
            relevance += 0.5
        }
        
        return min(1.0, relevance)
    }
    
    /// Identifies which criteria matched the search query
    private static func identifyMatchingCriteria(card: ScryfallCard, query: String) -> [String] {
        var criteria: [String] = []
        let queryLower = query.lowercased()
        
        if card.name.lowercased().contains(queryLower) {
            criteria.append("name_match")
        }
        
        if card.typeLine.lowercased().contains(queryLower) {
            criteria.append("type_match")
        }
        
        if (card.oracleText ?? "").lowercased().contains(queryLower) {
            criteria.append("text_match")
        }
        
        if card.manaCost?.lowercased().contains(queryLower) == true {
            criteria.append("mana_cost_match")
        }
        
        return criteria
    }
    
    /// Creates confidence factors for card search results
    private static func createConfidenceFactors(card: ScryfallCard, query: String) -> ConfidenceFactors {
        let queryLower = query.lowercased()
        
        return ConfidenceFactors(
            exactNameMatch: card.name.lowercased() == queryLower,
            partialNameMatch: card.name.lowercased().contains(queryLower),
            typeLineMatch: card.typeLine.lowercased().contains(queryLower),
            oracleTextMatch: (card.oracleText ?? "").lowercased().contains(queryLower),
            dataSourceReliability: 0.95 // Scryfall is highly reliable
        )
    }
    
    /// Categorizes a card for enhanced results
    private static func categorizeCard(_ card: ScryfallCard) -> [String] {
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
            if text.contains("draw") && text.contains("card") {
                categories.append("card_draw")
            }
            if text.contains("destroy") || text.contains("exile") {
                categories.append("removal")
            }
            if text.contains("counter") && text.contains("spell") {
                categories.append("counterspell")
            }
        }
        
        return categories
    }
    
    // MARK: - Reasoning Chain Creation
    
    /// Creates reasoning chain for card search
    private static func createCardSearchReasoning(
        query: String,
        resultsCount: Int,
        totalFound: Int
    ) -> DecisionReasoningChain {
        var steps: [String] = []
        var confidenceFactors: [String] = []
        var riskFactors: [String] = []
        
        steps.append("Parsed search query: '\(query)'")
        steps.append("Executed Scryfall API search")
        steps.append("Retrieved \(resultsCount) results from \(totalFound) total matches")
        steps.append("Calculated relevance scores for each result")
        steps.append("Applied confidence scoring based on match quality")
        
        if resultsCount > 0 {
            confidenceFactors.append("Scryfall API provides high-quality, official card data")
            confidenceFactors.append("Results include comprehensive card metadata")
        }
        
        if totalFound > resultsCount {
            riskFactors.append("Results truncated - additional matches available")
        }
        
        if query.count < 3 {
            riskFactors.append("Short query may produce overly broad results")
        }
        
        return DecisionReasoningChain(
            steps: steps,
            confidenceFactors: confidenceFactors,
            riskFactors: riskFactors
        )
    }
    
    /// Creates reasoning chain for combo lookup
    private static func createComboLookupReasoning(
        queriedCards: [String],
        combosFound: Int,
        apiSuccess: Bool
    ) -> DecisionReasoningChain {
        var steps: [String] = []
        var confidenceFactors: [String] = []
        var riskFactors: [String] = []
        
        steps.append("Analyzed \(queriedCards.count) input cards: \(queriedCards.joined(separator: ", "))")
        
        if apiSuccess {
            steps.append("Successfully queried Commander Spellbook API")
            steps.append("Found \(combosFound) matching combos")
            steps.append("Analyzed combo complexity and popularity")
            confidenceFactors.append("Commander Spellbook provides curated combo data")
        } else {
            steps.append("API query failed - using fallback analysis")
            riskFactors.append("Network issues may affect data completeness")
        }
        
        if combosFound == 0 {
            steps.append("No direct combos found - analyzed card synergies")
            riskFactors.append("Cards may combo with pieces not in database")
        }
        
        return DecisionReasoningChain(
            steps: steps,
            confidenceFactors: confidenceFactors,
            riskFactors: riskFactors
        )
    }
    
    /// Creates reasoning chain for game actions
    private static func createGameActionReasoning(
        action: String,
        simulationBacked: Bool
    ) -> DecisionReasoningChain {
        var steps: [String] = []
        var confidenceFactors: [String] = []
        var riskFactors: [String] = []
        
        steps.append("Processed game action: \(action)")
        
        if simulationBacked {
            steps.append("Validated action using simulation engine")
            steps.append("Calculated probabilities and outcomes")
            confidenceFactors.append("Simulation provides statistical validation")
        } else {
            steps.append("Applied heuristic analysis")
            riskFactors.append("Analysis based on general principles, not simulation")
        }
        
        steps.append("Updated game state accordingly")
        
        return DecisionReasoningChain(
            steps: steps,
            confidenceFactors: confidenceFactors,
            riskFactors: riskFactors
        )
    }
    
    /// Creates reasoning chain for EDHREC analysis
    private static func createEDHRecReasoning(
        commander: String,
        totalDecks: Int,
        apiSuccess: Bool
    ) -> DecisionReasoningChain {
        var steps: [String] = []
        var confidenceFactors: [String] = []
        var riskFactors: [String] = []
        
        steps.append("Sanitized commander name: \(commander)")
        
        if apiSuccess {
            steps.append("Successfully fetched EDHREC data")
            steps.append("Analyzed \(totalDecks) submitted decks")
            steps.append("Extracted card recommendations and statistics")
            confidenceFactors.append("EDHREC provides community-driven statistics")
            
            if totalDecks >= 100 {
                confidenceFactors.append("Large sample size increases reliability")
            } else {
                riskFactors.append("Small sample size may limit statistical significance")
            }
        } else {
            steps.append("EDHREC data not available - used fallback recommendations")
            riskFactors.append("Without real data, recommendations are generic")
        }
        
        return DecisionReasoningChain(
            steps: steps,
            confidenceFactors: confidenceFactors,
            riskFactors: riskFactors
        )
    }
    
    // MARK: - Suggestion Generation
    
    /// Generates suggestions for card search results
    private static func generateCardSearchSuggestions(
        query: String,
        results: [EnhancedCardResult],
        totalFound: Int
    ) -> [ActionSuggestion] {
        var suggestions: [ActionSuggestion] = []
        
        if results.isEmpty {
            suggestions.append(ActionSuggestion(
                action: "refine_search",
                description: "Try a broader or different search query",
                confidence: 0.8,
                reasoning: "No results found for current query",
                priority: .high,
                category: "search_optimization"
            ))
        } else if totalFound > results.count {
            suggestions.append(ActionSuggestion(
                action: "expand_results",
                description: "View additional results from \(totalFound) total matches",
                confidence: 0.9,
                reasoning: "More results available than currently shown",
                priority: .medium,
                category: "result_expansion"
            ))
        }
        
        if query.count < 3 {
            suggestions.append(ActionSuggestion(
                action: "specify_search",
                description: "Use more specific search terms for better results",
                confidence: 0.7,
                reasoning: "Short queries may be too broad",
                priority: .low,
                category: "search_optimization"
            ))
        }
        
        return suggestions
    }
    
    /// Generates suggestions for combo lookup results
    private static func generateComboSuggestions(
        queriedCards: [String],
        combos: [ComboResult],
        nearMisses: [NearMissCombo]
    ) -> [ActionSuggestion] {
        var suggestions: [ActionSuggestion] = []
        
        if !nearMisses.isEmpty {
            let topMiss = nearMisses.first!
            suggestions.append(ActionSuggestion(
                action: "add_missing_combo_pieces",
                description: "Add \(topMiss.missingCards.joined(separator: ", ")) to enable \(topMiss.wouldResult)",
                confidence: 0.8,
                reasoning: "Near-miss combo identified with high synergy",
                priority: .high,
                category: "deck_optimization",
                relatedCards: topMiss.missingCards
            ))
        }
        
        if combos.isEmpty && queriedCards.count >= 2 {
            suggestions.append(ActionSuggestion(
                action: "explore_synergies",
                description: "Look for synergistic interactions between these cards",
                confidence: 0.6,
                reasoning: "No direct combos found but cards may still synergize",
                priority: .medium,
                category: "card_analysis"
            ))
        }
        
        return suggestions
    }
    
    /// Generates suggestions for game actions
    private static func generateGameActionSuggestions(
        action: String,
        gameState: GameStateSnapshot,
        playAnalysis: PlayAnalysis?
    ) -> [ActionSuggestion] {
        var suggestions: [ActionSuggestion] = []
        
        if let analysis = playAnalysis {
            suggestions.append(ActionSuggestion(
                action: "consider_alternative",
                description: analysis.alternativePlays.first ?? "Consider other play options",
                confidence: 0.7,
                reasoning: "Alternative plays may offer better outcomes",
                priority: .medium,
                category: "strategic_analysis"
            ))
        }
        
        if gameState.cardsInHand < 3 {
            suggestions.append(ActionSuggestion(
                action: "prioritize_card_draw",
                description: "Focus on card advantage with low hand size",
                confidence: 0.8,
                reasoning: "Low hand size limits strategic options",
                priority: .high,
                category: "resource_management"
            ))
        }
        
        return suggestions
    }
    
    /// Generates suggestions for EDHREC analysis
    private static func generateEDHRecSuggestions(
        recommendations: [EDHRecRecommendation],
        deckComparison: DeckComparison
    ) -> [ActionSuggestion] {
        var suggestions: [ActionSuggestion] = []
        
        if !deckComparison.missingStaples.isEmpty {
            let topStaple = deckComparison.missingStaples.first!
            suggestions.append(ActionSuggestion(
                action: "add_staple_card",
                description: "Consider adding \(topStaple) - popular in similar decks",
                confidence: 0.8,
                reasoning: "Missing commonly played staple card",
                priority: .high,
                category: "deck_optimization",
                relatedCards: [topStaple]
            ))
        }
        
        if deckComparison.optimizationScore < 0.7 {
            suggestions.append(ActionSuggestion(
                action: "optimize_deck_composition",
                description: "Review deck composition for better archetype alignment",
                confidence: 0.7,
                reasoning: "Deck optimization score indicates room for improvement",
                priority: .medium,
                category: "deck_tuning"
            ))
        }
        
        return suggestions
    }
    
    // MARK: - Tag Generation
    
    /// Generates tags for card search results
    private static func generateCardSearchTags(query: String, results: [EnhancedCardResult]) -> [String] {
        var tags: [String] = ["card_search", "scryfall_api"]
        
        // Add result quality tags
        if results.isEmpty {
            tags.append("no_results")
        } else if results.count == 1 {
            tags.append("single_result")
        } else {
            tags.append("multiple_results")
        }
        
        // Add card type tags based on results
        let cardTypes = Set(results.flatMap { $0.categories })
        tags.append(contentsOf: cardTypes.map { "type_" + $0 })
        
        return tags
    }
    
    /// Generates tags for combo lookup results
    private static func generateComboTags(combos: [ComboResult]) -> [String] {
        var tags: [String] = ["combo_lookup", "commander_spellbook"]
        
        if combos.isEmpty {
            tags.append("no_combos_found")
        } else {
            tags.append("combos_found")
            
            // Add combo type tags
            let comboTypes = Set(combos.map { $0.type.rawValue })
            tags.append(contentsOf: comboTypes.map { "combo_" + $0 })
            
            // Add complexity tags
            let complexities = Set(combos.map { $0.setupComplexity.rawValue })
            tags.append(contentsOf: complexities.map { "complexity_" + $0 })
        }
        
        return tags
    }
    
    /// Generates tags for game actions
    private static func generateGameActionTags(action: String, gameState: GameStateSnapshot) -> [String] {
        var tags: [String] = ["game_action", action.lowercased().replacingOccurrences(of: " ", with: "_")]
        
        // Add game state tags
        if gameState.cardsInDeck == 0 {
            tags.append("empty_deck")
        }
        
        if gameState.cardsInHand >= 7 {
            tags.append("full_hand")
        } else if gameState.cardsInHand <= 2 {
            tags.append("low_hand")
        }
        
        return tags
    }
    
    /// Generates tags for EDHREC analysis
    private static func generateEDHRecTags(
        commander: String,
        categories: [CategorySummary],
        powerLevel: DeckComparison.PowerLevel
    ) -> [String] {
        var tags: [String] = ["edhrec_analysis", "commander_format"]
        
        // Add power level tag
        tags.append("power_level_" + powerLevel.rawValue.replacingOccurrences(of: "-", with: "_"))
        
        // Add category tags
        let categoryNames = categories.map { $0.name.lowercased().replacingOccurrences(of: " ", with: "_") }
        tags.append(contentsOf: categoryNames.prefix(5)) // Limit to avoid too many tags
        
        return tags
    }
    
    // MARK: - Utility Functions
    
    /// Analyzes deck synergies from combo results
    private static func analyzeDeckSynergies(from combos: [ComboResult]) -> [SynergyCluster] {
        var synergies: [SynergyCluster] = []
        
        // Group combos by theme/result type
        let grouped = Dictionary(grouping: combos) { combo in
            if combo.result.lowercased().contains("infinite") {
                return "infinite_value"
            } else if combo.result.lowercased().contains("damage") {
                return "damage_based"
            } else if combo.result.lowercased().contains("mill") {
                return "mill_strategy"
            } else {
                return "other_synergy"
            }
        }
        
        for (theme, themeCombos) in grouped {
            let allCards = Set(themeCombos.flatMap { $0.cards })
            let strength = Double(themeCombos.count) / Double(combos.count)
            
            synergies.append(SynergyCluster(
                theme: theme.replacingOccurrences(of: "_", with: " ").capitalized,
                cards: Array(allCards),
                strength: strength,
                description: "Cards that work together for \(theme.replacingOccurrences(of: "_", with: " ")) effects"
            ))
        }
        
        return synergies
    }
    
    /// Extracts tool name from action string
    private static func extractToolNameFromAction(_ action: String) -> String {
        let actionLower = action.lowercased()
        
        if actionLower.contains("draw") {
            return "draw_card"
        } else if actionLower.contains("mulligan") {
            return "mulligan"
        } else if actionLower.contains("play") || actionLower.contains("cast") {
            return "play_card"
        } else if actionLower.contains("shuffle") {
            return "shuffle_deck"
        } else {
            return "game_action"
        }
    }
}