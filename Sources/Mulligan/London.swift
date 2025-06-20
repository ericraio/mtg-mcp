import Foundation
import Card

/// London mulligan strategy implementation
public class London: MulliganStrategy {
    private var _startingHandSize: Int
    private var mulliganDownTo: Int
    private var mulliganOnLands: [Int]
    private var acceptableHandList: [[UInt64]]
    
    public init() {
        self._startingHandSize = kStartingHandSize
        self.mulliganDownTo = kStartingHandSize
        self.mulliganOnLands = []
        self.acceptableHandList = []
    }
    
    public func setMulliganDownTo(count: Int) {
        self.mulliganDownTo = count
    }
    
    public func setMulliganOnLands(counts: [Int]) {
        self.mulliganOnLands = counts
    }
    
    public func setAcceptableHandList(list: [[UInt64]]) {
        self.acceptableHandList = list
    }
    
    public func getAcceptableHandList() -> [[UInt64]] {
        return self.acceptableHandList
    }
    
    public func startingHandSize() -> Int {
        return kStartingHandSize
    }
    
    /// Set strategy to never mulligan
    public func never() {
        self._startingHandSize = self.startingHandSize()
        self.mulliganDownTo = self.startingHandSize()
    }
    
    /// Set strategy to always mulligan down to specified count
    public func always(downTo: Int) {
        self._startingHandSize = kStartingHandSize
        self.mulliganDownTo = downTo
        self.mulliganOnLands = Array(0..<kStartingHandSize)
    }
    
    public func simulateHand(deck: [Card], draws: Int) -> (opening: [Card], drawn: [Card]) {
        let deckSize = deck.count
        
        // Cap hand sizes by deck size
        let _startingHandSize = min(self._startingHandSize, deckSize)
        let mulliganDownTo = min(self.mulliganDownTo, deckSize)
        let maxMulliganRounds = _startingHandSize - mulliganDownTo + 1
        let cardsToDraw = min(_startingHandSize + draws + maxMulliganRounds, deckSize)
        
        // Create a mutable copy of the deck
        var mutableDeck = deck
        
        // Try different mulligan rounds
        for round in 0..<maxMulliganRounds {
            var mustKeepCardIndices = [Int]()
            
            // Shuffle the deck
            mutableDeck.shuffle()
            
            // Get the starting hand
            let startingHand = Array(mutableDeck[0..<_startingHandSize])
            let isLastRound = round == maxMulliganRounds - 1
            
            // Count lands in hand
            let landCount = startingHand.filter { $0.isLand }.count
            let sufficientLandCount = !mulliganOnLands.contains(landCount)
            
            // If not last round and not enough lands, try another mulligan
            if !isLastRound && !sufficientLandCount {
                continue
            }
            
            // Check for acceptable hands
            var foundAcceptableHand = false
            
            for acceptableHand in acceptableHandList {
                var seenCardHashes = Set<UInt64>()
                
                for (i, card) in startingHand.enumerated() {
                    if seenCardHashes.contains(card.nameHash) {
                        continue
                    }
                    
                    if acceptableHand.contains(card.nameHash) {
                        mustKeepCardIndices.append(i)
                    }
                    
                    seenCardHashes.insert(card.nameHash)
                }
                
                foundAcceptableHand = mustKeepCardIndices.count == acceptableHand.count
                if foundAcceptableHand {
                    break
                }
            }
            
            // Determine if we should keep this hand
            let disregardFoundAcceptableHand = acceptableHandList.isEmpty
            let keep = isLastRound || (sufficientLandCount && (disregardFoundAcceptableHand || foundAcceptableHand))
            
            if keep {
                let openingHandSize = _startingHandSize - round
                
                // Save lands if needed
                var landsSaved = 0
                for (i, card) in startingHand.enumerated() {
                    if !card.isLand {
                        continue
                    }
                    
                    let needMoreLands = mulliganOnLands.contains(landsSaved) && landsSaved < openingHandSize
                    if needMoreLands {
                        mustKeepCardIndices.append(i)
                        landsSaved += 1
                        continue
                    }
                    
                    break
                }
                
                // Sort and deduplicate indices
                mustKeepCardIndices = Array(Set(mustKeepCardIndices)).sorted()
                
                // Rearrange cards to keep at the front
                for (i, mustKeepI) in mustKeepCardIndices.enumerated() {
                    let tmp = mutableDeck[i]
                    mutableDeck[i] = mutableDeck[mustKeepI]
                    mutableDeck[mustKeepI] = tmp
                }
                
                // Handle discarded cards
                var index = 0
                for discardCount in openingHandSize..<_startingHandSize {
                    let otherIndex = cardsToDraw - 1 - discardCount
                    let tmp = mutableDeck[index]
                    mutableDeck[index] = mutableDeck[otherIndex]
                    mutableDeck[otherIndex] = tmp
                    index += 1
                }
                
                // Return the final hand configuration
                let openingHand = Array(mutableDeck[0..<openingHandSize])
                let drawnCards = Array(mutableDeck[_startingHandSize..<cardsToDraw])
                
                return (openingHand, drawnCards)
            }
        }
        
        // If no hand was kept, return empty arrays
        return ([], [])
    }
}
