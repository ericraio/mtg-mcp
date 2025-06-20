import Foundation
import Card

/// Never strategy - always keeps the initial hand
public class Never: MulliganStrategy {
    public init() {}

    public func setMulliganDownTo(count: Int) {
        // No operation - Never strategy doesn't mulligan
    }
    
    public func setMulliganOnLands(counts: [Int]) {
        // No operation - Never strategy doesn't check land counts
    }
    
    public func setAcceptableHandList(list: [[UInt64]]) {
        // No operation - Never strategy accepts all hands
    }
    
    public func getAcceptableHandList() -> [[UInt64]] {
        return []
    }
    
    public func startingHandSize() -> Int {
        return kStartingHandSize
    }
    
    public func simulateHand(deck: [Card], draws: Int) -> (opening: [Card], drawn: [Card]) {
        let deckSize = deck.count
        let startingHandSize = min(self.startingHandSize(), deckSize)
        let cardsToDraw = min(startingHandSize + draws, deckSize)
        
        // Create a mutable copy and shuffle
        var mutableDeck = deck
        mutableDeck.shuffle()
        
        // Return the opening hand and drawn cards
        let openingHand = Array(mutableDeck[0..<startingHandSize])
        let drawnCards = Array(mutableDeck[startingHandSize..<cardsToDraw])
        
        return (openingHand, drawnCards)
    }
}
