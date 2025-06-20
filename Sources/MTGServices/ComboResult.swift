/// Individual combo result
public struct ComboResult: Codable {
    public let id: String
    public let cards: [String]
    public let result: String
    public let type: ComboType
    public let popularityScore: Double
    public let setupComplexity: Complexity
    public let manaRequirements: [String]
    public let prerequisites: [String]
    public let steps: [String]
    public let counters: [String]
    public let competitiveTier: CompetitiveTier

    public enum ComboType: String, Codable {
        case infinite, finite, synergy, engine
    }

    public enum Complexity: String, Codable {
        case simple, medium, complex, expert
    }

    public enum CompetitiveTier: String, Codable {
        case casual, focused, optimized, competitive, cedh
    }

    public init(
        id: String,
        cards: [String],
        result: String,
        type: ComboType,
        popularityScore: Double,
        setupComplexity: Complexity,
        manaRequirements: [String],
        prerequisites: [String],
        steps: [String],
        counters: [String],
        competitiveTier: CompetitiveTier
    ) {
        self.id = id
        self.cards = cards
        self.result = result
        self.type = type
        self.popularityScore = popularityScore
        self.setupComplexity = setupComplexity
        self.manaRequirements = manaRequirements
        self.prerequisites = prerequisites
        self.steps = steps
        self.counters = counters
        self.competitiveTier = competitiveTier
    }
}
