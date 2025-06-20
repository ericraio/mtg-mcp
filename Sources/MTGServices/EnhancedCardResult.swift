/// Enhanced card result with confidence and relevance
public struct EnhancedCardResult: Codable {
    public let name: String
    public let manaCost: String?
    public let typeLine: String
    public let oracleText: String?
    public let relevanceScore: Double
    public let matchingCriteria: [String]
    public let confidenceFactors: ConfidenceFactors
    public let categories: [String]
    public let formatLegality: [String: String]?
    public let priceInfo: PriceInfo?

    public init(
        name: String,
        manaCost: String? = nil,
        typeLine: String,
        oracleText: String? = nil,
        relevanceScore: Double,
        matchingCriteria: [String],
        confidenceFactors: ConfidenceFactors,
        categories: [String],
        formatLegality: [String: String]? = nil,
        priceInfo: PriceInfo? = nil
    ) {
        self.name = name
        self.manaCost = manaCost
        self.typeLine = typeLine
        self.oracleText = oracleText
        self.relevanceScore = relevanceScore
        self.matchingCriteria = matchingCriteria
        self.confidenceFactors = confidenceFactors
        self.categories = categories
        self.formatLegality = formatLegality
        self.priceInfo = priceInfo
    }
}
