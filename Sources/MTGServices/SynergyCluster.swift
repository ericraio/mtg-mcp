/// Synergy cluster analysis
public struct SynergyCluster: Codable {
    public let theme: String
    public let cards: [String]
    public let strength: Double
    public let description: String
    public let enhancementSuggestions: [String]

    public init(
        theme: String,
        cards: [String],
        strength: Double,
        description: String,
        enhancementSuggestions: [String] = []
    ) {
        self.theme = theme
        self.cards = cards
        self.strength = strength
        self.description = description
        self.enhancementSuggestions = enhancementSuggestions
    }
}
