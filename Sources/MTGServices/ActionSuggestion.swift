/// Actionable suggestions for next steps
public struct ActionSuggestion: Codable {
    public let action: String
    public let description: String
    public let confidence: Double
    public let reasoning: String
    public let priority: Priority
    public let category: String
    public let relatedCards: [String]?

    public enum Priority: String, Codable {
        case low, medium, high, critical
    }

    public init(
        action: String,
        description: String,
        confidence: Double,
        reasoning: String,
        priority: Priority = .medium,
        category: String,
        relatedCards: [String]? = nil
    ) {
        self.action = action
        self.description = description
        self.confidence = confidence
        self.reasoning = reasoning
        self.priority = priority
        self.category = category
        self.relatedCards = relatedCards
    }
}
