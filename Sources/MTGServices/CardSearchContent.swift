/// Card search specific content
public struct CardSearchContent: Codable {
    public let query: String
    public let results: [EnhancedCardResult]
    public let totalFound: Int
    public let searchTips: [String]
    public let alternativeQueries: [String]

    public init(
        query: String,
        results: [EnhancedCardResult],
        totalFound: Int,
        searchTips: [String] = [],
        alternativeQueries: [String] = []
    ) {
        self.query = query
        self.results = results
        self.totalFound = totalFound
        self.searchTips = searchTips
        self.alternativeQueries = alternativeQueries
    }
}
