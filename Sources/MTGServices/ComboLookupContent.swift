/// Combo lookup specific content
public struct ComboLookupContent: Codable {
    public let queriedCards: [String]
    public let combosFound: [ComboResult]
    public let relatedCombos: [ComboResult]
    public let nearMisses: [NearMissCombo]
    public let deckSynergies: [SynergyCluster]

    public init(
        queriedCards: [String],
        combosFound: [ComboResult],
        relatedCombos: [ComboResult] = [],
        nearMisses: [NearMissCombo] = [],
        deckSynergies: [SynergyCluster] = []
    ) {
        self.queriedCards = queriedCards
        self.combosFound = combosFound
        self.relatedCombos = relatedCombos
        self.nearMisses = nearMisses
        self.deckSynergies = deckSynergies
    }
}
