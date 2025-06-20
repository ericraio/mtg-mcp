import Foundation
import Bipartite
import Card
import Mulligan

/// Represents a player's hand of cards during a game
public class Hand {
    // MARK: - Properties
    
    /// Simulated cards in hand (opening hand + draws)
    var cards: [SimCard]
    
    /// Starting hand size before mulligans
    var startingHandSize: Int
    
    /// Opening hand size after mulligans
    var openingHandSize: Int
    
    /// Number of cards mulliganed (startingHandSize - openingHandSize)
    var mulliganCount: Int

    /// Commander starts in command zone and is a free card in opening hand
    var commander: SimCard?
    
    // MARK: - Initialization
    
    /// Creates an empty hand
    init() {
        self.cards = []
        self.startingHandSize = 0
        self.openingHandSize = 0
        self.mulliganCount = 0
    }
    
    /// Creates a hand using the specified mulligan strategy
    /// - Parameters:
    ///   - mulliganStrategy: Strategy to determine opening hand
    ///   - deck: Cards to draw from
    ///   - draws: Number of additional cards to draw
    /// - Returns: A new hand or nil if the strategy is invalid
    public static func fromMulligan(mulliganStrategy: MulliganStrategy, deck: [Card], draws: Int) -> Hand? {
        let (openingCards, drawnCards) = mulliganStrategy.simulateHand(deck: deck, draws: draws)
        
        let hand = Hand()
        hand.setOpeningAndDraws(opening: openingCards, draws: drawnCards)
        return hand
    }
    
    /// Creates a hand for a Commander game
    /// - Parameters:
    ///   - mulliganStrategy: Strategy to determine opening hand
    ///   - deck: Cards to draw from
    ///   - commander: The commander card
    ///   - draws: Number of additional cards to draw
    /// - Returns: A new hand or nil if the strategy is invalid
    public static func fromCommanderMulligan(mulliganStrategy: MulliganStrategy, deck: [Card], commander: Card, draws: Int) -> Hand? {
        let (openingCards, drawnCards) = mulliganStrategy.simulateHand(deck: deck, draws: draws)
        
        let hand = Hand()
        hand.setOpeningAndDraws(opening: openingCards, draws: drawnCards)
        
        // Commander starts in the command zone, treated as a free card in opening hand
        let commanderSim = SimCard.new()
        commanderSim.kind = commander.kind
        commanderSim.hash = commander.nameHash
        commanderSim.isCommander = true
        if let manaCost = commander.manaCost {
            commanderSim.manaCost = manaCost
        }
        hand.cards.insert(commanderSim, at: 0)
        hand.openingHandSize += 1
        hand.mulliganCount = hand.startingHandSize - hand.openingHandSize
        hand.commander = commanderSim
        
        return hand
    }
    
    /// Creates a hand for a game with a companion
    /// - Parameters:
    ///   - mulliganStrategy: Strategy to determine opening hand
    ///   - deck: Cards to draw from
    ///   - companion: The companion card
    ///   - draws: Number of additional cards to draw
    /// - Returns: A new hand or nil if the strategy is invalid
    public static func fromCompanionMulligan(mulliganStrategy: MulliganStrategy, deck: [Card], companion: Card, draws: Int) -> Hand? {
        let (openingCards, drawnCards) = mulliganStrategy.simulateHand(deck: deck, draws: draws)
        
        let hand = Hand()
        hand.setOpeningAndDraws(opening: openingCards, draws: drawnCards)
        
        // Companion starts outside the game, not in the opening hand
        // We don't need to add it to the hand, but we'll mark it as a companion
        // in the simulation
        
        return hand
    }
    
    // MARK: - Card Management
    
    /// Sets the hand with opening hand from `opening`, and card draw from `draws`
    /// - Parameters:
    ///   - opening: Cards in the opening hand after mulligan
    ///   - draws: Cards drawn during the game
    public func setOpeningAndDraws(opening: [Card], draws: [Card]) {
        var simCards: [SimCard] = []
        
        // Process opening hand cards
        for c in opening {
            let simCard = SimCard.new()
            simCard.kind = c.kind
            if let manaCost = c.manaCost {
                simCard.manaCost = manaCost
            }
            simCard.hash = c.nameHash
            simCards.append(simCard)
        }
        
        // Process drawn cards
        for c in draws {
            let simCard = SimCard.new()
            simCard.kind = c.kind
            simCard.hash = c.nameHash
            if let manaCost = c.manaCost {
                simCard.manaCost = manaCost
            }

            simCards.append(simCard)
        }
        
        // TODO: hard coded starting hand size is bad and potentially incorrect
        // since the mulligan process defines the starting hand size
        let startingHandSize = 7
        let openingHandSize = opening.count
        
        self.cards = simCards
        self.startingHandSize = startingHandSize
        self.openingHandSize = openingHandSize
        self.mulliganCount = startingHandSize - openingHandSize
    }
    
    /// Returns a slice consisting of cards in the opening hand, after the mulligan process
    public func opening() -> [SimCard] {
        return slice(from: 0, to: openingHandSize)
    }
    
    /// Returns a slice consisting of cards drawn after the opening hand
    /// - Parameter drawCount: Number of draws to include
    public func draws(drawCount: Int) -> [SimCard] {
        return slice(from: openingHandSize, to: openingHandSize + drawCount)
    }
    
    /// Returns a slice consisting of cards from opening hand plus draws
    /// - Parameter draws: Number of draws to include
    public func openingWithDraws(draws: Int) -> [SimCard] {
        return slice(from: 0, to: openingHandSize + draws)
    }
    
    /// Returns the number of cards in the opening hand and draws that satisfy the predicate
    /// - Parameters:
    ///   - draws: Number of draws to include
    ///   - predicate: Function that determines if a card should be counted
    /// - Returns: Count of cards that satisfy the predicate
    public func countInOpeningWithDraws(draws: Int, predicate: (SimCard) -> Bool) -> Int {
        return openingWithDraws(draws: draws).filter(predicate).count
    }
    
    /// Returns a slice of the cards array from the specified range
    /// - Parameters:
    ///   - from: Starting index
    ///   - to: Ending index (exclusive)
    private func slice(from: Int, to: Int) -> [SimCard] {
        let adjustedTo = min(to, cards.count)
        let adjustedFrom = min(from, adjustedTo)
        return Array(cards[adjustedFrom..<adjustedTo])
    }
    
    // MARK: - Playable Mana Rocks
    
    /// Determines which mana rocks could be played by a specified turn
    /// - Parameters:
    ///   - availableCards: Cards available to consider (opening hand + draws)
    ///   - turn: Game turn
    /// - Returns: Array of mana rocks that could be played by the specified turn
    private func playableManaRocksByTurn(availableCards: [SimCard], turn: Int) -> [SimCard] {
        guard turn > 0 else { return [] }
        
        // Find all lands in the available cards
        let lands = availableCards.filter { $0.kind.isLand }
        
        // Find all mana rocks in the available cards
        let manaRocks = availableCards.filter { $0.kind.isManaRock }
        
        // Sort mana rocks by CMC for optimal play sequencing
        let sortedManaRocks = manaRocks.sorted { (rock1, rock2) -> Bool in
            return rock1.manaCost.cmc() < rock2.manaCost.cmc()
        }
        
        var playableManaRocks: [SimCard] = []
        var currentManaAvailable = min(turn, lands.count) // Start with lands we can play
        
        // Simulate playing mana rocks in sequence
        for rock in sortedManaRocks {
            let rockCMC = rock.manaCost.cmc()
            
            // If we have enough mana to play this rock
            if rockCMC <= currentManaAvailable {
                playableManaRocks.append(rock)
                // Rock now provides additional mana for subsequent turns
                currentManaAvailable += 1
            }
        }
        
        return playableManaRocks
    }

    // MARK: - Playable Mana Dorks
    
    /// Determines which mana dorks could be played by a specified turn
    /// - Parameters:
    ///   - availableCards: Cards available to consider (opening hand + draws)
    ///   - turn: Game turn
    /// - Returns: Array of mana dorks that could be played by the specified turn
    private func playableManaDorksByTurn(availableCards: [SimCard], turn: Int) -> [SimCard] {
        guard turn > 0 else { return [] }
        
        // Find all lands in the available cards
        let lands = availableCards.filter { $0.kind.isLand }
        
        // Find all mana dorks in the available cards
        let manaDorks = availableCards.filter { $0.kind.isManaDork }
        
        // Sort mana dorks by CMC for optimal play sequencing
        let sortedManaDorks = manaDorks.sorted { (dork1, dork2) -> Bool in
            return dork1.manaCost.cmc() < dork2.manaCost.cmc()
        }
        
        var playableManaDorks: [SimCard] = []
        var currentManaAvailable = min(turn, lands.count) // Start with lands we can play
        
        // Simulate playing mana dorks in sequence
        for dork in sortedManaDorks{
            let dorkCMC = dork.manaCost.cmc()
            
            // If we have enough mana to play this dork
            if dorkCMC <= currentManaAvailable {
                playableManaDorks.append(dork)
                // Dork now provides additional mana for subsequent turns
                currentManaAvailable += 1
            }
        }
        
        return playableManaDorks
    }
    
    // MARK: - Auto-tapping Methods
    
    /// Returns the result of attempting to tap the `goal` card
    /// with the mana sources (lands and playable mana rocks) by the turn equal to the CMC of the goal card
    /// when playing first
    /// - Parameter goal: Card to play
    /// - Returns: AutoTapResult indicating if the card can be played
    public func playCMCAutoTap(goal: Card) -> AutoTapResult {
        let turn = max(1, goal.turn)
        return autoTapByTurn(goal: goal, turn: turn, playOrder: .first)
    }
    
    /// Returns the result of attempting to tap the `goal` card
    /// with the mana sources (lands and playable mana rocks) by the turn equal to the CMC of the goal card
    /// when playing second
    /// - Parameter goal: Card to play
    /// - Returns: AutoTapResult indicating if the card can be played
    public func drawCMCAutoTap(goal: Card) -> AutoTapResult {
        let turn = max(1, goal.turn)
        return autoTapByTurn(goal: goal, turn: turn, playOrder: .second)
    }
    
    /// Returns the result of attempting to tap the `goal` card
    /// with the mana sources (lands and playable mana rocks) by the `turn` given the `playOrder`
    /// - Parameters:
    ///   - goal: Card to play
    ///   - turn: Game turn
    ///   - playOrder: First or second player
    /// - Returns: AutoTapResult indicating if the card can be played
    public func autoTapByTurn(goal: Card, turn: Int, playOrder: PlayOrder) -> AutoTapResult {
        let scratch = Scratch(maxLandCount: 30, maxPipCount: 8)
        let goalSim = SimCard.new()
        goalSim.kind = goal.kind
        goalSim.hash = goal.nameHash
        if let manaCost = goal.manaCost {
            goalSim.manaCost = manaCost
        }
        
        // Set commander and companion flags
        goalSim.isCommander = goal.kind.isCommander
        goalSim.isCompanion = goal.kind.isCompanion
        
        return autoTapWithScratch(goal: goalSim, turn: turn, playOrder: playOrder, scratch: scratch)
    }
    
    /// The actual autoTap implementation that exposes the scratch space data structure for performance
    /// The implementation constructs a bipartite graph between the available mana sources (lands and playable
    /// mana rocks) and the mana pips of the goal card mana cost, and then attempts to find the size of the
    /// maximum matching set.
    /// - Parameters:
    ///   - goal: Card to play
    ///   - turn: Game turn
    ///   - playOrder: First or second player
    ///   - scratch: Scratch space for algorithm
    /// - Returns: AutoTapResult indicating if the card can be played
    public func autoTapWithScratch(goal: SimCard, turn: Int, playOrder: PlayOrder, scratch: Scratch) -> AutoTapResult {
        // Special handling for commander and companion cards
        let isCommander = goal.isCommander
        let isCompanion = goal.isCompanion

        if isCommander {
            var autoTapResult = AutoTapResult()
            autoTapResult.isCommander = true
            autoTapResult.isCompanion = isCompanion
            autoTapResult.inOpeningHand = true
            autoTapResult.inDrawHand = false
            autoTapResult.paid = true
            autoTapResult.cmc = true
            return autoTapResult
        }
        // Determine draw count based on play order
        let drawCount: Int
        switch playOrder {
        case .first:
            drawCount = turn - 1
        case .second:
            drawCount = turn
        }
        
        let openingHand = opening()
        let draws = self.draws(drawCount: drawCount)
        let availableCards = openingHand + draws
        
        // Clear the scratch space
        scratch.clearLands()
        
        // Check if the goal card is in hand
        var inOpeningHand = false
        var inDrawHand = false
        
        // For commander and companion cards, they start outside the hand
        // Commander starts in the command zone, companion starts outside the game
        if !isCommander && !isCompanion {
            for c in openingHand {
                if c.hash == goal.hash {
                    inOpeningHand = true
                    break
                }
            }
            
            for c in draws {
                if c.hash == goal.hash {
                    inDrawHand = true
                    break
                }
            }
        }
        
        // Add lands from available cards to scratch
        for c in availableCards {
            if c.kind.isLand {
                scratch.lands.append(c)
            }
        }
        
        // Find mana rocks that could be played by this turn
        let playableManaRocks = playableManaRocksByTurn(availableCards: availableCards, turn: turn - 1) // -1 because we need to play them before using them
        
        // Check if goal card is a mana rock - if so, don't use it to pay for itself
        let filteredManaRocks = playableManaRocks.filter { $0.hash != goal.hash }
        
        // Add playable mana rocks to scratch
        for rock in filteredManaRocks {
            scratch.lands.append(rock)
        }

        // Find mana dorks that could be played by this turn
        let playableManaDorks = playableManaDorksByTurn(availableCards: availableCards, turn: turn - 1) // -1 because we need to play them before using them
        
        // Check if goal card is a mana dork - if so, don't use it to pay for itself
        let filteredManaDorks = playableManaDorks.filter { $0.hash != goal.hash }
        
        // Add playable mana dorks to scratch
        for rock in filteredManaDorks {
            scratch.lands.append(rock)
        }
        
        let pipCount = goal.manaCost.cmc()     // rows (height)
        let landCount = scratch.lands.count    // columns (width)
        var autoTapResult = AutoTapResult()
        
        autoTapResult.inOpeningHand = inOpeningHand
        autoTapResult.inDrawHand = inDrawHand
        autoTapResult.isCommander = isCommander
        autoTapResult.isCompanion = isCompanion
        
        // Exit early if there aren't enough mana sources
        if landCount < pipCount {
            autoTapResult.paid = false
            autoTapResult.cmc = false
            return autoTapResult
        }
        
        // Resize the scratch space data structures
        scratch.resizeEdges(amount: pipCount * landCount, value: 0)
        scratch.resizeSeen(amount: landCount, value: false)
        scratch.resizeMatches(amount: landCount, value: -1)
        
        // Get mana cost details
        let rPips = goal.manaCost.red
        let gPips = goal.manaCost.green
        let bPips = goal.manaCost.black
        let uPips = goal.manaCost.blue
        let wPips = goal.manaCost.white
        let cPips = goal.manaCost.colorless
        
        // Define ranges for each color
        let rRange = (0, Int(rPips))
        let gRange = (rRange.1, rRange.1 + Int(gPips))
        let bRange = (gRange.1, gRange.1 + Int(bPips))
        let uRange = (bRange.1, bRange.1 + Int(uPips))
        let wRange = (uRange.1, uRange.1 + Int(wPips))
        let cRange = (wRange.1, wRange.1 + Int(cPips))
        
        let edgeCount = scratch.edges.count
        
        // Build adjacency matrix for each color
        
        // Red mana
        for m in rRange.0..<rRange.1 {
            for (n, manaSource) in scratch.lands.enumerated() {
                let i = landCount * m + n
                if i < edgeCount {
                    if let manaSource {
                        scratch.edges[i] = manaSource.manaCost.red
                    }
                }
            }
        }
        
        // Green mana
        for m in gRange.0..<gRange.1 {
            for (n, manaSource) in scratch.lands.enumerated() {
                let i = landCount * m + n
                if i < edgeCount {
                    if let manaSource {
                        scratch.edges[i] = manaSource.manaCost.green
                    }
                }
            }
        }
        
        // Black mana
        for m in bRange.0..<bRange.1 {
            for (n, manaSource) in scratch.lands.enumerated() {
                let i = landCount * m + n
                if i < edgeCount {
                    if let manaSource {
                        scratch.edges[i] = manaSource.manaCost.black
                    }
                }
            }
        }
        
        // Blue mana
        for m in uRange.0..<uRange.1 {
            for (n, manaSource) in scratch.lands.enumerated() {
                let i = landCount * m + n
                if i < edgeCount {
                    if let manaSource {
                        scratch.edges[i] = manaSource.manaCost.blue
                    }
                }
            }
        }
        
        // White mana
        for m in wRange.0..<wRange.1 {
            for (n, manaSource) in scratch.lands.enumerated() {
                let i = landCount * m + n
                if i < edgeCount {
                    if let manaSource {
                        scratch.edges[i] = manaSource.manaCost.white
                    }
                }
            }
        }
        
        // Colorless mana
        for m in cRange.0..<cRange.1 {
            for n in 0..<scratch.lands.count {
                let i = landCount * m + n
                if i < edgeCount {
                    scratch.edges[i] = 1
                }
            }
        }
        
        // Run bipartite matching algorithm
        let pipsPaid = Bipartite.maximumBipartiteMatching(
            edges: &scratch.edges,
            pipCount: pipCount,
            landCount: landCount,
            seen: &scratch.seen,
            matches: &scratch.matches
        )
        
        autoTapResult.paid = pipsPaid == pipCount
        autoTapResult.cmc = true
        return autoTapResult
    }
    
    /// Returns the count of lands in the opening hand
    public func landCount() -> Int {
        return opening().filter { $0.kind.isLand }.count
    }
    
    /// Returns the count of mana rocks in the opening hand
    public func manaRockCount() -> Int {
        return opening().filter { $0.kind.isManaRock }.count
    }
    
    /// Returns the count of mana rocks that could be played by turn N
    public func playableManaRockCountByTurn(turn: Int) -> Int {
        return playableManaRocksByTurn(availableCards: opening(), turn: turn).count
    }

    /// Returns the count of mana dorks in the opening hand
    public func manaDorkCount() -> Int {
        return opening().filter { $0.kind.isManaDork }.count
    }
    
    /// Returns the count of mana dorks that could be played by turn N
    public func playableManaDorkCountByTurn(turn: Int) -> Int {
        return playableManaDorksByTurn(availableCards: opening(), turn: turn).count
    }
    
    /// Returns the total available mana sources (lands + playable mana rocks) by turn N
    public func availableManaSourcesByTurn(turn: Int) -> Int {
        let lands = min(turn, landCount())
        let playableManaRocks = playableManaRockCountByTurn(turn: turn - 1) // -1 because we need to play them before using them
        let playableManaDorks = playableManaDorkCountByTurn(turn: turn - 1) // -1 because we need to play them before using them
        return lands + playableManaRocks + playableManaDorks
    }
}
