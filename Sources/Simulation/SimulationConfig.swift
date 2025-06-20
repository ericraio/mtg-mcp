import Foundation
import Mulligan
import Deck

/// Configuration for running a simulation
public class SimulationConfig {
    /// Number of simulation runs to perform
    public var runCount: Int
    
    /// Number of cards to draw in each simulation
    public var drawCount: Int
    
    /// Deck to use for the simulation
    public var deck: Deck
    
    /// Mulligan strategy to apply
    public var mulligan: MulliganStrategy
    
    /// Whether the simulation is for the player going first
    public var onThePlay: Bool
    
    /// Initialize a new simulation configuration with default values
    public init() {
        self.runCount = 0
        self.drawCount = 0
        self.deck = Deck(cards: [])
        self.mulligan = Never()
        self.onThePlay = false
    }
}
