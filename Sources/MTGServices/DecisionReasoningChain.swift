/// Decision reasoning chain showing thought process
public struct DecisionReasoningChain: Codable {
    public let steps: [String]
    public let confidenceFactors: [String]
    public let riskFactors: [String]
    public let alternativesConsidered: [String]

    public init(
        steps: [String],
        confidenceFactors: [String] = [],
        riskFactors: [String] = [],
        alternativesConsidered: [String] = []
    ) {
        self.steps = steps
        self.confidenceFactors = confidenceFactors
        self.riskFactors = riskFactors
        self.alternativesConsidered = alternativesConsidered
    }
}
