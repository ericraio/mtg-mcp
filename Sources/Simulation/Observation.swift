public struct Observation {
    var mana: Int = 0
    var cmc: Int = 0
    var play: Int = 0
    var inOpeningHand: Int = 0
    var totalRuns: Int = 0
    
    // Commander-specific observations
    var isCommander: Bool = false
    
    // Companion-specific observations
    var isCompanion: Bool = false
    
    public init() {
        // Default initializer
    }
    
    // The unconditional probability to pay the mana cost by the turn.
    public func probabilityMana() -> Double {
        return Double(mana) / Double(totalRuns)
    }
    
    // For commander cards, this is the probability to cast your commander by the specified turn
    public func probabilityCommanderCast() -> Double {
        guard isCommander else { return 0.0 }
        return probabilityMana()
    }
    
    // For companion cards, this is the probability to cast your companion by the specified turn
    public func probabilityCompanionCast() -> Double {
        guard isCompanion else { return 0.0 }
        return probabilityMana()
    }
    
    // The probability to pay the mana cost by turn N, conditional on drawing at least N mana sources.
    // Cards with P(mana|turn) >= 90% are highlighted in blue.
    // This is the same number Frank Karsten calculates in order to determine
    // if a deck can consistently cast a card on curve.
    public func probabilityManaGivenCMC() -> Double {
        return Double(mana) / Double(cmc)
    }
    
    // The unconditional probability to pay the mana cost and have at least one copy of the card in
    // hand by the turn.
    public func probabilityPlay() -> Double {
        return Double(play) / Double(totalRuns)
    }
}
