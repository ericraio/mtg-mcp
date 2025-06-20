import Foundation
import Card

/// The standard starting hand size in a card game
let kStartingHandSize = 7

public class Mulligan: MulliganStrategy {
    private let strategy: MulliganStrategy

    public init(strategy: Strategy) {
        switch strategy {
        case .never: 
            self.strategy = Never()
        case .london:
            self.strategy = London()
        }
    }

    public func setMulliganDownTo(count: Int) {
        self.strategy.setMulliganDownTo(count: count)
    }

    public func setMulliganOnLands(counts: [Int]) {
        self.strategy.setMulliganOnLands(counts: counts)
    }

    public func setAcceptableHandList(list: [[UInt64]]) {
        self.strategy.setAcceptableHandList(list: list)
    }

    public func getAcceptableHandList() -> [[UInt64]] {
        return self.strategy.getAcceptableHandList()
    }

    public func startingHandSize() -> Int {
        return self.strategy.startingHandSize()
    }

    public func simulateHand(deck: [Card], draws: Int) -> (opening: [Card], drawn: [Card]) {
        return self.strategy.simulateHand(deck: deck, draws: draws)
    }
}
