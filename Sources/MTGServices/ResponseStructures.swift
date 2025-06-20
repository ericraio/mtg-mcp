import Foundation

// MARK: - Core LLM-Optimized Response Structures

/// Base structure for all LLM-optimized responses
public struct LLMOptimizedResponse: Codable {
    public let metadata: ResponseMetadata
    public let content: ResponseContent
    public let reasoning: DecisionReasoningChain?
    public let suggestions: [ActionSuggestion]
    public let tags: [String]

    public init(
        metadata: ResponseMetadata,
        content: ResponseContent,
        reasoning: DecisionReasoningChain? = nil,
        suggestions: [ActionSuggestion] = [],
        tags: [String] = []
    ) {
        self.metadata = metadata
        self.content = content
        self.reasoning = reasoning
        self.suggestions = suggestions
        self.tags = tags
    }
}

/// Metadata block providing context and quality metrics
public struct ResponseMetadata: Codable {
    public let toolName: String
    public let timestamp: Date
    public let confidence: Double
    public let dataSource: String
    public let processingTime: TimeInterval
    public let version: String
    public let apiCallsUsed: Int?
    public let searchCompleteness: Double?

    public init(
        toolName: String,
        timestamp: Date = Date(),
        confidence: Double,
        dataSource: String,
        processingTime: TimeInterval,
        version: String = "1.0.0",
        apiCallsUsed: Int? = nil,
        searchCompleteness: Double? = nil
    ) {
        self.toolName = toolName
        self.timestamp = timestamp
        self.confidence = confidence
        self.dataSource = dataSource
        self.processingTime = processingTime
        self.version = version
        self.apiCallsUsed = apiCallsUsed
        self.searchCompleteness = searchCompleteness
    }
}

// MARK: - Content Type Structures

/// Price information structure
public struct PriceInfo: Codable {
    public let usd: Double?
    public let eur: Double?
    public let trend: PriceTrend
    public let lastUpdated: Date?

    public enum PriceTrend: String, Codable {
        case rising, stable, falling, unknown
    }

    public init(
        usd: Double? = nil,
        eur: Double? = nil,
        trend: PriceTrend = .unknown,
        lastUpdated: Date? = nil
    ) {
        self.usd = usd
        self.eur = eur
        self.trend = trend
        self.lastUpdated = lastUpdated
    }
}

/// Game action specific content
public struct GameActionContent: Codable {
    public let action: String
    public let result: String
    public let gameStateUpdate: GameStateSnapshot
    public let playAnalysis: PlayAnalysis?

    public init(
        action: String,
        result: String,
        gameStateUpdate: GameStateSnapshot,
        playAnalysis: PlayAnalysis? = nil
    ) {
        self.action = action
        self.result = result
        self.gameStateUpdate = gameStateUpdate
        self.playAnalysis = playAnalysis
    }
}

/// Game state snapshot
public struct GameStateSnapshot: Codable {
    public let cardsInDeck: Int
    public let cardsInHand: Int
    public let handComposition: [String: Int]
    public let turnNumber: Int?
    public let manaAvailable: Int?
    public let lifeTotalInfo: [String: Int]?

    public init(
        cardsInDeck: Int,
        cardsInHand: Int,
        handComposition: [String: Int],
        turnNumber: Int? = nil,
        manaAvailable: Int? = nil,
        lifeTotalInfo: [String: Int]? = nil
    ) {
        self.cardsInDeck = cardsInDeck
        self.cardsInHand = cardsInHand
        self.handComposition = handComposition
        self.turnNumber = turnNumber
        self.manaAvailable = manaAvailable
        self.lifeTotalInfo = lifeTotalInfo
    }
}

/// Play analysis for decision making
public struct PlayAnalysis: Codable {
    public let recommendedPlay: String
    public let alternativePlays: [String]
    public let riskAssessment: RiskAssessment
    public let expectedOutcome: String

    public init(
        recommendedPlay: String,
        alternativePlays: [String],
        riskAssessment: RiskAssessment,
        expectedOutcome: String
    ) {
        self.recommendedPlay = recommendedPlay
        self.alternativePlays = alternativePlays
        self.riskAssessment = riskAssessment
        self.expectedOutcome = expectedOutcome
    }
}

/// Risk assessment structure
public struct RiskAssessment: Codable {
    public let level: RiskLevel
    public let factors: [String]
    public let mitigation: [String]

    public enum RiskLevel: String, Codable {
        case low, medium, high, critical
    }

    public init(
        level: RiskLevel,
        factors: [String],
        mitigation: [String]
    ) {
        self.level = level
        self.factors = factors
        self.mitigation = mitigation
    }
}

/// EDHREC analysis content
public struct EDHRecAnalysisContent: Codable {
    public let commander: String
    public let totalDecks: Int
    public let recommendations: [EDHRecRecommendation]
    public let deckComparison: DeckComparison
    public let categoryBreakdown: [CategorySummary]

    public init(
        commander: String,
        totalDecks: Int,
        recommendations: [EDHRecRecommendation],
        deckComparison: DeckComparison,
        categoryBreakdown: [CategorySummary]
    ) {
        self.commander = commander
        self.totalDecks = totalDecks
        self.recommendations = recommendations
        self.deckComparison = deckComparison
        self.categoryBreakdown = categoryBreakdown
    }
}

/// EDHREC recommendation with confidence
public struct EDHRecRecommendation: Codable {
    public let cardName: String
    public let inclusionRate: Double
    public let synergyScore: Double
    public let category: String
    public let deckCount: Int
    public let recommendationStrength: RecommendationStrength
    public let reasoning: String
    public let alternatives: [String]

    public enum RecommendationStrength: String, Codable {
        case weak, moderate, strong, essential
    }

    public init(
        cardName: String,
        inclusionRate: Double,
        synergyScore: Double,
        category: String,
        deckCount: Int,
        recommendationStrength: RecommendationStrength,
        reasoning: String,
        alternatives: [String] = []
    ) {
        self.cardName = cardName
        self.inclusionRate = inclusionRate
        self.synergyScore = synergyScore
        self.category = category
        self.deckCount = deckCount
        self.recommendationStrength = recommendationStrength
        self.reasoning = reasoning
        self.alternatives = alternatives
    }
}

/// Deck comparison analysis
public struct DeckComparison: Codable {
    public let archetypeMatch: Double
    public let missingStaples: [String]
    public let unusualIncludes: [String]
    public let optimizationScore: Double
    public let powerLevelEstimate: PowerLevel

    public enum PowerLevel: String, Codable {
        case casual = "1-3"
        case focused = "4-6"
        case optimized = "7-8"
        case competitive = "9-10"
    }

    public init(
        archetypeMatch: Double,
        missingStaples: [String],
        unusualIncludes: [String],
        optimizationScore: Double,
        powerLevelEstimate: PowerLevel
    ) {
        self.archetypeMatch = archetypeMatch
        self.missingStaples = missingStaples
        self.unusualIncludes = unusualIncludes
        self.optimizationScore = optimizationScore
        self.powerLevelEstimate = powerLevelEstimate
    }
}

/// Category summary for EDHREC data
public struct CategorySummary: Codable {
    public let name: String
    public let cardCount: Int
    public let averageInclusionRate: Double?

    public init(
        name: String,
        cardCount: Int,
        averageInclusionRate: Double? = nil
    ) {
        self.name = name
        self.cardCount = cardCount
        self.averageInclusionRate = averageInclusionRate
    }
}

/// Deck analysis content
public struct DeckAnalysisContent: Codable {
    public let totalCards: Int
    public let comboAnalysis: ComboAnalysisResult
    public let manaCurve: ManaCurveAnalysis
    public let colorBalance: ColorBalanceAnalysis
    public let archetypeIdentification: ArchetypeAnalysis

    public init(
        totalCards: Int,
        comboAnalysis: ComboAnalysisResult,
        manaCurve: ManaCurveAnalysis,
        colorBalance: ColorBalanceAnalysis,
        archetypeIdentification: ArchetypeAnalysis
    ) {
        self.totalCards = totalCards
        self.comboAnalysis = comboAnalysis
        self.manaCurve = manaCurve
        self.colorBalance = colorBalance
        self.archetypeIdentification = archetypeIdentification
    }
}

/// Combo analysis results
public struct ComboAnalysisResult: Codable {
    public let completeCombos: [ComboResult]
    public let nearMisses: [NearMissCombo]
    public let comboConsistency: Double
    public let recommendedAdditions: [String]

    public init(
        completeCombos: [ComboResult],
        nearMisses: [NearMissCombo],
        comboConsistency: Double,
        recommendedAdditions: [String]
    ) {
        self.completeCombos = completeCombos
        self.nearMisses = nearMisses
        self.comboConsistency = comboConsistency
        self.recommendedAdditions = recommendedAdditions
    }
}

/// Mana curve analysis
public struct ManaCurveAnalysis: Codable {
    public let distribution: [Int: Int]
    public let averageCMC: Double
    public let landCount: Int
    public let rampSpells: Int
    public let curveQuality: CurveQuality
    public let recommendations: [String]

    public enum CurveQuality: String, Codable {
        case poor, fair, good, excellent
    }

    public init(
        distribution: [Int: Int],
        averageCMC: Double,
        landCount: Int,
        rampSpells: Int,
        curveQuality: CurveQuality,
        recommendations: [String]
    ) {
        self.distribution = distribution
        self.averageCMC = averageCMC
        self.landCount = landCount
        self.rampSpells = rampSpells
        self.curveQuality = curveQuality
        self.recommendations = recommendations
    }
}

/// Color balance analysis
public struct ColorBalanceAnalysis: Codable {
    public let colorRequirements: [String: Double]
    public let manabaseRecommendations: [String]
    public let colorConsistency: Double

    public init(
        colorRequirements: [String: Double],
        manabaseRecommendations: [String],
        colorConsistency: Double
    ) {
        self.colorRequirements = colorRequirements
        self.manabaseRecommendations = manabaseRecommendations
        self.colorConsistency = colorConsistency
    }
}

/// Archetype analysis
public struct ArchetypeAnalysis: Codable {
    public let primaryArchetype: String
    public let confidence: Double
    public let supportingEvidence: [String]
    public let archetypeOptimizations: [String]

    public init(
        primaryArchetype: String,
        confidence: Double,
        supportingEvidence: [String],
        archetypeOptimizations: [String]
    ) {
        self.primaryArchetype = primaryArchetype
        self.confidence = confidence
        self.supportingEvidence = supportingEvidence
        self.archetypeOptimizations = archetypeOptimizations
    }
}

/// Rule validation content
public struct RuleValidationContent: Codable {
    public let scenario: String
    public let validationResult: ValidationResult
    public let rulesCited: [CitedRule]
    public let potentialIssues: [ValidationIssue]
    public let recommendations: [String]

    public enum ValidationResult: String, Codable {
        case valid, invalid, unclear, requiresJudge
    }

    public init(
        scenario: String,
        validationResult: ValidationResult,
        rulesCited: [CitedRule],
        potentialIssues: [ValidationIssue],
        recommendations: [String]
    ) {
        self.scenario = scenario
        self.validationResult = validationResult
        self.rulesCited = rulesCited
        self.potentialIssues = potentialIssues
        self.recommendations = recommendations
    }
}

/// Cited rule reference
public struct CitedRule: Codable {
    public let ruleNumber: String
    public let ruleText: String
    public let relevanceScore: Double
    public let application: String

    public init(
        ruleNumber: String,
        ruleText: String,
        relevanceScore: Double,
        application: String
    ) {
        self.ruleNumber = ruleNumber
        self.ruleText = ruleText
        self.relevanceScore = relevanceScore
        self.application = application
    }
}

/// Validation issue
public struct ValidationIssue: Codable {
    public let type: IssueType
    public let severity: IssueSeverity
    public let description: String
    public let correction: String

    public enum IssueType: String, Codable {
        case commonMisconception, timingError, rulesConflict, edgeCase
    }

    public enum IssueSeverity: String, Codable {
        case info, warning, error, critical
    }

    public init(
        type: IssueType,
        severity: IssueSeverity,
        description: String,
        correction: String
    ) {
        self.type = type
        self.severity = severity
        self.description = description
        self.correction = correction
    }
}

/// Simulation content
public struct SimulationContent: Codable {
    public let simulationType: SimulationType
    public let parameters: SimulationParameters
    public let results: SimulationResults

    public enum SimulationType: String, Codable {
        case openingHands, turnSimulation, comboTesting, mulliganAnalysis
    }

    public init(
        simulationType: SimulationType,
        parameters: SimulationParameters,
        results: SimulationResults
    ) {
        self.simulationType = simulationType
        self.parameters = parameters
        self.results = results
    }
}

/// Simulation parameters
public struct SimulationParameters: Codable {
    public let sampleSize: Int
    public let turnsSimulated: Int?
    public let startingHandSize: Int
    public let mulliganStrategy: String?

    public init(
        sampleSize: Int,
        turnsSimulated: Int? = nil,
        startingHandSize: Int = 7,
        mulliganStrategy: String? = nil
    ) {
        self.sampleSize = sampleSize
        self.turnsSimulated = turnsSimulated
        self.startingHandSize = startingHandSize
        self.mulliganStrategy = mulliganStrategy
    }
}

/// Simulation results
public struct SimulationResults: Codable {
    public let hands: [HandAnalysis]
    public let aggregateMetrics: AggregateMetrics
    public let insights: [String]

    public init(
        hands: [HandAnalysis],
        aggregateMetrics: AggregateMetrics,
        insights: [String]
    ) {
        self.hands = hands
        self.aggregateMetrics = aggregateMetrics
        self.insights = insights
    }
}

/// Hand analysis for simulation
public struct HandAnalysis: Codable {
    public let handNumber: Int
    public let cards: [String]
    public let composition: HandComposition
    public let decision: KeepMulliganDecision
    public let turnPotential: TurnPotential

    public init(
        handNumber: Int,
        cards: [String],
        composition: HandComposition,
        decision: KeepMulliganDecision,
        turnPotential: TurnPotential
    ) {
        self.handNumber = handNumber
        self.cards = cards
        self.composition = composition
        self.decision = decision
        self.turnPotential = turnPotential
    }
}

/// Hand composition breakdown
public struct HandComposition: Codable {
    public let lands: Int
    public let ramp: Int
    public let threats: Int
    public let interaction: Int
    public let cardDraw: Int
    public let other: Int

    public init(
        lands: Int,
        ramp: Int,
        threats: Int,
        interaction: Int,
        cardDraw: Int,
        other: Int
    ) {
        self.lands = lands
        self.ramp = ramp
        self.threats = threats
        self.interaction = interaction
        self.cardDraw = cardDraw
        self.other = other
    }
}

/// Keep/mulligan decision
public struct KeepMulliganDecision: Codable {
    public let recommendation: Decision
    public let confidence: Double
    public let reasoning: String
    public let riskFactors: [String]

    public enum Decision: String, Codable {
        case keep, mulligan, borderline
    }

    public init(
        recommendation: Decision,
        confidence: Double,
        reasoning: String,
        riskFactors: [String]
    ) {
        self.recommendation = recommendation
        self.confidence = confidence
        self.reasoning = reasoning
        self.riskFactors = riskFactors
    }
}

/// Turn potential analysis
public struct TurnPotential: Codable {
    public let earlyPlays: [String]
    public let comboPotential: Double
    public let expectedTurn: Int?
    public let keyPieces: [String]

    public init(
        earlyPlays: [String],
        comboPotential: Double,
        expectedTurn: Int? = nil,
        keyPieces: [String]
    ) {
        self.earlyPlays = earlyPlays
        self.comboPotential = comboPotential
        self.expectedTurn = expectedTurn
        self.keyPieces = keyPieces
    }
}

/// Aggregate metrics for simulation
public struct AggregateMetrics: Codable {
    public let averageLandCount: Double
    public let keepRate: Double
    public let comboHandsPercentage: Double
    public let deckConsistency: ConsistencyRating

    public enum ConsistencyRating: String, Codable {
        case poor, fair, good, excellent
    }

    public init(
        averageLandCount: Double,
        keepRate: Double,
        comboHandsPercentage: Double,
        deckConsistency: ConsistencyRating
    ) {
        self.averageLandCount = averageLandCount
        self.keepRate = keepRate
        self.comboHandsPercentage = comboHandsPercentage
        self.deckConsistency = deckConsistency
    }
}

