import Foundation

// MARK: - Confidence Scoring System for LLM-Optimized Responses

/// Core confidence scoring engine for MTG MCP responses
public struct ConfidenceScoring {
    
    // MARK: - Scoring Constants
    
    private static let maxConfidence: Double = 1.0
    private static let minConfidence: Double = 0.0
    
    // Base confidence levels for different data sources
    internal static let dataSourceConfidence: [String: Double] = [
        "scryfall_api": 0.95,
        "edhrec_api": 0.90,
        "commander_spellbook_api": 0.85,
        "gatherer_api": 0.80,
        "local_rules": 0.85,
        "mtg_comprehensive_rules": 0.95,
        "simulation_engine": 0.75,
        "heuristic_analysis": 0.60,
        "fallback_data": 0.30
    ]
    
    // MARK: - Card Search Confidence Scoring
    
    /// Calculates confidence score for card search results
    public static func scoreCardSearch(
        query: String,
        results: [EnhancedCardResult],
        totalFound: Int,
        apiSource: String = "scryfall_api"
    ) -> Double {
        var confidence = dataSourceConfidence[apiSource] ?? 0.5
        
        // Exact matches boost confidence significantly
        let exactMatches = results.filter { $0.confidenceFactors.exactNameMatch }
        if !exactMatches.isEmpty {
            confidence += 0.1 * Double(exactMatches.count) / Double(results.count)
        }
        
        // Results completeness factor
        let completenessBonus: Double
        if totalFound == 0 {
            completenessBonus = -0.3
        } else if results.count == totalFound {
            completenessBonus = 0.1 // Got all results
        } else if results.count >= min(10, totalFound) {
            completenessBonus = 0.05 // Got reasonable subset
        } else {
            completenessBonus = -0.1 // Incomplete results
        }
        confidence += completenessBonus
        
        // Query specificity bonus
        let querySpecificityBonus = calculateQuerySpecificity(query) * 0.1
        confidence += querySpecificityBonus
        
        // Relevance scoring based on result quality
        if !results.isEmpty {
            let avgRelevance = results.map { $0.relevanceScore }.reduce(0, +) / Double(results.count)
            confidence += (avgRelevance - 0.5) * 0.2 // Scale around 0.5 baseline
        }
        
        return clampConfidence(confidence)
    }
    
    // MARK: - Combo Lookup Confidence Scoring
    
    /// Calculates confidence score for combo lookup results
    public static func scoreComboLookup(
        queriedCards: [String],
        combosFound: [ComboResult],
        apiCallSuccess: Bool = true,
        dataCompleteness: Double = 1.0
    ) -> Double {
        var confidence = apiCallSuccess ? dataSourceConfidence["commander_spellbook_api"] ?? 0.85 : 0.3
        
        // Card matching quality
        let cardMatchBonus: Double
        if combosFound.isEmpty {
            cardMatchBonus = queriedCards.count <= 2 ? -0.2 : -0.1 // Fewer cards, higher expectation
        } else {
            // Calculate how well combos match the queried cards
            let avgCardOverlap = combosFound.map { combo in
                let overlap = Set(combo.cards).intersection(Set(queriedCards)).count
                return Double(overlap) / Double(max(combo.cards.count, queriedCards.count))
            }.reduce(0, +) / Double(combosFound.count)
            
            cardMatchBonus = avgCardOverlap * 0.15
        }
        confidence += cardMatchBonus
        
        // Combo quality scoring
        if !combosFound.isEmpty {
            let avgPopularity = combosFound.map { $0.popularityScore }.reduce(0, +) / Double(combosFound.count)
            confidence += (avgPopularity - 0.5) * 0.1
            
            // Diversity bonus for multiple combo types
            let uniqueTypes = Set(combosFound.map { $0.type }).count
            confidence += Double(uniqueTypes - 1) * 0.05
        }
        
        // Data completeness factor
        confidence *= dataCompleteness
        
        return clampConfidence(confidence)
    }
    
    // MARK: - Game Action Confidence Scoring
    
    /// Calculates confidence score for game action responses
    public static func scoreGameAction(
        actionType: String,
        gameStateValidity: Bool,
        simulationBacked: Bool = false,
        cardInteractionComplexity: ComplexityLevel = .medium
    ) -> Double {
        var confidence = simulationBacked ? 
            dataSourceConfidence["simulation_engine"] ?? 0.75 : 
            dataSourceConfidence["heuristic_analysis"] ?? 0.60
        
        // Game state validity is crucial
        if !gameStateValidity {
            confidence *= 0.5
        }
        
        // Action type confidence modifiers
        let actionModifier: Double
        switch actionType.lowercased() {
        case "draw_card", "mulligan", "shuffle":
            actionModifier = 0.1 // Simple, high confidence actions
        case "play_card", "cast_spell":
            actionModifier = 0.05
        case "combat", "priority":
            actionModifier = 0.0 // Complex interactions
        case "stack_resolution", "triggered_ability":
            actionModifier = -0.05 // Very complex
        default:
            actionModifier = 0.0
        }
        confidence += actionModifier
        
        // Complexity penalty
        let complexityPenalty: Double
        switch cardInteractionComplexity {
        case .simple:
            complexityPenalty = 0.05
        case .medium:
            complexityPenalty = 0.0
        case .complex:
            complexityPenalty = -0.1
        case .expert:
            complexityPenalty = -0.2
        }
        confidence += complexityPenalty
        
        return clampConfidence(confidence)
    }
    
    // MARK: - EDHREC Analysis Confidence Scoring
    
    /// Calculates confidence score for EDHREC analysis
    public static func scoreEDHRecAnalysis(
        commanderFound: Bool,
        deckCount: Int,
        categoriesAvailable: Int,
        apiResponseComplete: Bool = true
    ) -> Double {
        var confidence = commanderFound && apiResponseComplete ? 
            dataSourceConfidence["edhrec_api"] ?? 0.90 : 0.4
        
        // Deck count reliability factor
        let deckCountFactor: Double
        if deckCount >= 1000 {
            deckCountFactor = 0.1 // Very reliable data
        } else if deckCount >= 100 {
            deckCountFactor = 0.05 // Good data
        } else if deckCount >= 10 {
            deckCountFactor = 0.0 // Minimal data
        } else {
            deckCountFactor = -0.2 // Unreliable data
        }
        confidence += deckCountFactor
        
        // Category completeness bonus
        let categoryBonus = min(0.1, Double(categoriesAvailable) * 0.02)
        confidence += categoryBonus
        
        return clampConfidence(confidence)
    }
    
    // MARK: - Rule Validation Confidence Scoring
    
    /// Calculates confidence score for MTG rule validation
    public static func scoreRuleValidation(
        ruleSource: String,
        rulesFound: Int,
        querySpecificity: Double,
        crossReferencesFound: Int = 0
    ) -> Double {
        var confidence = dataSourceConfidence[ruleSource] ?? 0.6
        
        // Rules found factor
        let rulesFactor: Double
        if rulesFound == 0 {
            rulesFactor = -0.3 // No rules found is bad
        } else if rulesFound == 1 {
            rulesFactor = 0.1 // Single precise rule is good
        } else if rulesFound <= 5 {
            rulesFactor = 0.05 // Multiple relevant rules
        } else {
            rulesFactor = -0.05 // Too many rules might indicate broad search
        }
        confidence += rulesFactor
        
        // Query specificity bonus
        confidence += querySpecificity * 0.15
        
        // Cross-reference validation bonus
        confidence += min(0.1, Double(crossReferencesFound) * 0.03)
        
        return clampConfidence(confidence)
    }
    
    // MARK: - Simulation Confidence Scoring
    
    /// Calculates confidence score for simulation results
    public static func scoreSimulation(
        sampleSize: Int,
        simulationEngine: String = "swift_landlord",
        inputValidation: Bool = true,
        convergenceAchieved: Bool = true
    ) -> Double {
        var confidence = dataSourceConfidence["simulation_engine"] ?? 0.75
        
        // Sample size factor
        let sampleFactor: Double
        if sampleSize >= 10000 {
            sampleFactor = 0.15
        } else if sampleSize >= 1000 {
            sampleFactor = 0.1
        } else if sampleSize >= 100 {
            sampleFactor = 0.05
        } else {
            sampleFactor = -0.1
        }
        confidence += sampleFactor
        
        // Input validation is crucial for simulations
        if !inputValidation {
            confidence *= 0.6
        }
        
        // Convergence indicates reliable results
        if !convergenceAchieved {
            confidence *= 0.8
        }
        
        return clampConfidence(confidence)
    }
    
    // MARK: - Composite Confidence Scoring
    
    /// Calculates overall confidence for responses with multiple data sources
    public static func scoreComposite(
        componentScores: [String: Double],
        weights: [String: Double]? = nil
    ) -> Double {
        guard !componentScores.isEmpty else { return 0.0 }
        
        let defaultWeights = weights ?? componentScores.mapValues { _ in 1.0 }
        
        var weightedSum = 0.0
        var totalWeight = 0.0
        
        for (component, score) in componentScores {
            let weight = defaultWeights[component] ?? 1.0
            weightedSum += score * weight
            totalWeight += weight
        }
        
        let weightedAverage = totalWeight > 0 ? weightedSum / totalWeight : 0.0
        
        // Penalty for relying on low-confidence components
        let minScore = componentScores.values.min() ?? 0.0
        let penalty = minScore < 0.5 ? (0.5 - minScore) * 0.1 : 0.0
        
        return clampConfidence(weightedAverage - penalty)
    }
    
    // MARK: - Decision Making Confidence
    
    /// Calculates confidence for decision-making scenarios
    public static func scoreDecision(
        optionsAnalyzed: Int,
        dataQuality: Double,
        riskAssessmentComplete: Bool = true,
        alternativesConsidered: Int = 0
    ) -> Double {
        var confidence = dataQuality * 0.7 // Base on data quality
        
        // Options analysis factor
        let optionsFactor: Double
        if optionsAnalyzed >= 3 {
            optionsFactor = 0.15
        } else if optionsAnalyzed == 2 {
            optionsFactor = 0.1
        } else if optionsAnalyzed == 1 {
            optionsFactor = 0.0
        } else {
            optionsFactor = -0.2
        }
        confidence += optionsFactor
        
        // Risk assessment bonus
        if riskAssessmentComplete {
            confidence += 0.1
        }
        
        // Alternatives consideration bonus
        confidence += min(0.1, Double(alternativesConsidered) * 0.03)
        
        return clampConfidence(confidence)
    }
    
    // MARK: - Helper Methods
    
    /// Clamps confidence score to valid range [0.0, 1.0]
    private static func clampConfidence(_ confidence: Double) -> Double {
        return max(minConfidence, min(maxConfidence, confidence))
    }
    
    /// Calculates query specificity score based on search terms
    private static func calculateQuerySpecificity(_ query: String) -> Double {
        let words = query.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        let specificTerms = ["mana:", "type:", "color:", "set:", "rarity:", "power:", "toughness:"]
        let specificityCount = specificTerms.reduce(0) { count, term in
            count + (query.lowercased().contains(term) ? 1 : 0)
        }
        
        // Base specificity on word count and specific search operators
        let wordSpecificity = min(1.0, Double(words.count) / 5.0)
        let operatorSpecificity = min(1.0, Double(specificityCount) / 3.0)
        
        return (wordSpecificity + operatorSpecificity) / 2.0
    }
    
    /// Complexity levels for various operations
    public enum ComplexityLevel {
        case simple, medium, complex, expert
    }
}

// MARK: - Confidence Factor Analysis

/// Analyzes and extracts confidence factors for detailed reporting
public struct ConfidenceFactorAnalyzer {
    
    /// Generates detailed confidence factor breakdown
    public static func analyzeFactors(
        dataSource: String,
        resultQuality: Double,
        completeness: Double,
        complexity: ConfidenceScoring.ComplexityLevel = .medium
    ) -> [String] {
        var factors: [String] = []
        
        // Data source reliability
        if let sourceReliability = ConfidenceScoring.dataSourceConfidence[dataSource] {
            if sourceReliability >= 0.9 {
                factors.append("High-reliability data source (\(String(format: "%.0f", sourceReliability * 100))%)")
            } else if sourceReliability >= 0.7 {
                factors.append("Reliable data source (\(String(format: "%.0f", sourceReliability * 100))%)")
            } else {
                factors.append("Moderate-reliability data source (\(String(format: "%.0f", sourceReliability * 100))%)")
            }
        }
        
        // Result quality assessment
        if resultQuality >= 0.8 {
            factors.append("High-quality result matching")
        } else if resultQuality >= 0.6 {
            factors.append("Good result matching")
        } else if resultQuality >= 0.4 {
            factors.append("Moderate result matching")
        } else {
            factors.append("Limited result matching")
        }
        
        // Completeness factor
        if completeness >= 0.9 {
            factors.append("Complete data coverage")
        } else if completeness >= 0.7 {
            factors.append("Good data coverage")
        } else if completeness >= 0.5 {
            factors.append("Partial data coverage")
        } else {
            factors.append("Limited data coverage")
        }
        
        // Complexity consideration
        switch complexity {
        case .simple:
            factors.append("Simple operation with high predictability")
        case .medium:
            factors.append("Standard complexity operation")
        case .complex:
            factors.append("Complex operation requiring careful analysis")
        case .expert:
            factors.append("Expert-level complexity with potential edge cases")
        }
        
        return factors
    }
    
    /// Identifies risk factors that might lower confidence
    public static func identifyRiskFactors(
        hasNetworkDependency: Bool = false,
        requiresRealTimeData: Bool = false,
        involveComplexRules: Bool = false,
        hasEdgeCases: Bool = false,
        dependsOnUserInput: Bool = false
    ) -> [String] {
        var risks: [String] = []
        
        if hasNetworkDependency {
            risks.append("Network dependency may affect data freshness")
        }
        
        if requiresRealTimeData {
            risks.append("Real-time data requirements may introduce latency")
        }
        
        if involveComplexRules {
            risks.append("Complex rule interactions may have edge cases")
        }
        
        if hasEdgeCases {
            risks.append("Known edge cases exist for this scenario")
        }
        
        if dependsOnUserInput {
            risks.append("Result quality depends on input accuracy")
        }
        
        return risks
    }
    
    /// Suggests confidence improvements
    public static func suggestImprovements(currentConfidence: Double) -> [String] {
        var suggestions: [String] = []
        
        if currentConfidence < 0.5 {
            suggestions.append("Consider cross-referencing with additional data sources")
            suggestions.append("Validate results with manual verification")
            suggestions.append("Use more specific search criteria")
        } else if currentConfidence < 0.7 {
            suggestions.append("Additional validation recommended for critical decisions")
            suggestions.append("Consider sampling more data points")
        } else if currentConfidence < 0.9 {
            suggestions.append("Results are reliable for most use cases")
            suggestions.append("Consider expert review for tournament play")
        } else {
            suggestions.append("High confidence results suitable for all contexts")
        }
        
        return suggestions
    }
}