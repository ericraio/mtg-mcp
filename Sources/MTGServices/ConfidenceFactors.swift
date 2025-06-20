/// Confidence factors for scoring
public struct ConfidenceFactors: Codable {
    public let exactNameMatch: Bool
    public let partialNameMatch: Bool
    public let typeLineMatch: Bool
    public let oracleTextMatch: Bool
    public let dataSourceReliability: Double
    public let communityAdoption: Double?

    public init(
        exactNameMatch: Bool = false,
        partialNameMatch: Bool = false,
        typeLineMatch: Bool = false,
        oracleTextMatch: Bool = false,
        dataSourceReliability: Double = 1.0,
        communityAdoption: Double? = nil
    ) {
        self.exactNameMatch = exactNameMatch
        self.partialNameMatch = partialNameMatch
        self.typeLineMatch = typeLineMatch
        self.oracleTextMatch = oracleTextMatch
        self.dataSourceReliability = dataSourceReliability
        self.communityAdoption = communityAdoption
    }
}
