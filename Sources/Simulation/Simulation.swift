import Foundation
import Card
import Hand
import Deck

// Define error types
public enum SimulationError: Error {
    case invalidRunCount
}

public class Simulation {
    /// Progress update handler type
    public typealias ProgressHandler = (Double, String) -> Void
    
    public var hands: [Hand]
    public var accumulatedOpeningHandSize: Int
    public var accumulatedOpeningHandLandCount: Int
    public var onThePlay: Bool
    public let deck: Deck
    
    // Commander and companion cards
    public var commander: Card?
    public var companion: Card?
    
    public init(config: SimulationConfig, progressHandler: ProgressHandler? = nil) throws {
        if config.runCount < 1 {
            throw SimulationError.invalidRunCount
        }
        
        self.deck = config.deck
        self.commander = config.deck.commander
        self.companion = config.deck.companion
        
        var hands: [Hand] = [Hand]()
        let mulligan = config.mulligan
        let deck: [Card] = config.deck.cards
        let draws: Int = config.drawCount
        
        // Handle different types of decks (regular, commander, companion)
        let totalRuns: Int = config.runCount
        print("🔄 Simulation starting with \(totalRuns) runs")
        
        for i in 0..<totalRuns {
            // Just print progress for debugging, but don't try to report it
            if i % max(1, min(totalRuns / 20, 1000)) == 0 {
                let progress = Double(i) / Double(totalRuns)
                print("🔄 Simulation progress: \(Int(progress * 100))% - Run \(i) of \(totalRuns)")
            }
            
            var hand: Hand?
            
            if let commander = self.commander {
                // Commander deck
                hand = Hand.fromCommanderMulligan(mulliganStrategy: mulligan, deck: deck, commander: commander, draws: draws)
            } else if let companion = self.companion {
                // Deck with companion
                hand = Hand.fromCompanionMulligan(mulliganStrategy: mulligan, deck: deck, companion: companion, draws: draws)
            } else {
                // Regular deck
                hand = Hand.fromMulligan(mulliganStrategy: mulligan, deck: deck, draws: draws)
            }
            
            if let h: Hand = hand {
                hands.append(h)
            }
        }
        
        var accumulatedOpeningHandSize: Int = 0
        var accumulatedOpeningHandLandCount: Int = 0
        for h: Hand in hands {
            accumulatedOpeningHandSize += h.opening().count
            accumulatedOpeningHandLandCount += h.countInOpeningWithDraws(draws: 0) { card in 
                card.kind.isLand
            }
        }
        
        self.hands = hands
        self.accumulatedOpeningHandSize = accumulatedOpeningHandSize
        self.accumulatedOpeningHandLandCount = accumulatedOpeningHandLandCount
        self.onThePlay = config.onThePlay
    }
    
    
    public func observationForCard(card: Card) -> Observation {
        return observationForCardByTurn(card: card, turn: card.turn)
    }
    
    /// Get observation for commander card
    public func observationForCommander() -> Observation? {
        guard let commander = commander else {
            return nil
        }
        
        // For commander, we typically want to know if we can cast it by a specific turn
        // Commander's turn cost is usually higher than regular cards
        var observation = observationForCardByTurn(card: commander, turn: commander.turn)
        observation.isCommander = true
        return observation
    }
    
    /// Get observation for companion card
    public func observationForCompanion() -> Observation? {
        guard let companion = companion else {
            return nil
        }
        
        // For companion, we want to know if we can cast it from outside the game
        // Companions typically have a 3 mana tax to bring into hand
        let companionTurn = companion.turn + 1 // Add 1 turn for the companion tax
        var observation = observationForCardByTurn(card: companion, turn: companionTurn)
        observation.isCompanion = true
        return observation
    }
    
    public func observationForCardByTurn(card: Card, turn: Int) -> Observation {
        var observation = Observation()
        observation.totalRuns = hands.count
        
        // Set commander and companion flags based on card kind
        observation.isCommander = card.kind.isCommander
        observation.isCompanion = card.kind.isCompanion
        
        let scratch = Scratch(maxLandCount: 30, maxPipCount: 10)
        
        let playOrder: PlayOrder = onThePlay ? .first : .second
        
        for h in hands {
            let goal = SimCard.new()
            goal.hash = card.nameHash
            if let manaCost = card.manaCost {
                goal.manaCost = manaCost
            }
            
            let result = h.autoTapWithScratch(
                goal: goal, turn: turn, playOrder: playOrder, scratch: scratch)
            
            if result.inOpeningHand {
                observation.inOpeningHand += 1
            }
            
            if !result.cmc {
                continue
            }
            
            // Did we make it this far? Count a CMC lands on curve event
            observation.cmc += 1
            
            // Can we pay? Count a mana on curve event
            if result.paid {
                observation.mana += 1
                // Was the card in question in our initial hand? Did we draw it on curve?
                if result.inOpeningHand || result.inDrawHand {
                    observation.play += 1
                }
            }
        }
        
        // assert!(observations.mana <= observations.cmc);
        return observation
    }
}
