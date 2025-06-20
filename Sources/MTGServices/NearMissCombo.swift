/// Near-miss combo (missing pieces)
public struct NearMissCombo: Codable {
    public let ownedCards: [String]
    public let missingCards: [String]
    public let wouldResult: String
    public let additionPriority: Double

    public init(
        ownedCards: [String],
        missingCards: [String],
        wouldResult: String,
        additionPriority: Double
    ) {
        self.ownedCards = ownedCards
        self.missingCards = missingCards
        self.wouldResult = wouldResult
        self.additionPriority = additionPriority
    }
}
