import Foundation
import Card

/// Protocol defining the interface for all mulligan strategies
public protocol MulliganStrategy {
    /// Set the minimum hand size after mulligans
    func setMulliganDownTo(count: Int)
    
    /// Set the land counts that trigger a mulligan
    func setMulliganOnLands(counts: [Int])
    
    /// Set hands that are considered acceptable
    func setAcceptableHandList(list: [[UInt64]])
    
    /// Get the current list of acceptable hands
    func getAcceptableHandList() -> [[UInt64]]
    
    /// Get the starting hand size
    func startingHandSize() -> Int
    
    /// Simulate drawing a hand with this mulligan strategy
    func simulateHand(deck: [Card], draws: Int) -> (opening: [Card], drawn: [Card])
}

