import Foundation

/// Represents a card with its quantity in a deck
public struct Spell: Codable, Sendable {
    public let card: Card
    public let count: Int
    
    public init(card: Card, count: Int) {
        self.card = card
        self.count = count
    }
}

/// Represents the game state for MTG MCP server
public actor GameState {
    /// Main deck cards (shuffled)
    public private(set) var deck: [Card] = []
    
    /// Sideboard cards
    public private(set) var sideboard: [Card] = []
    
    /// Cards currently in hand
    public private(set) var hand: [Card] = []
    
    /// Cards that have been played/discarded
    public private(set) var graveyard: [Card] = []
    
    /// Original deck data for resets
    private var originalDeckData: DeckData?
    
    /// Commander card (if any)
    public private(set) var commander: Card?
    
    /// Companion card (if any)
    public private(set) var companion: Card?
    
    public init() {}
    
    /// Loads a deck from a parsed deck list
    public func loadDeck(_ deckData: DeckData) {
        self.originalDeckData = deckData
        self.deck = deckData.mainDeck
        self.sideboard = deckData.sideboard
        self.commander = deckData.commander
        self.companion = deckData.companion
        self.hand = []
        self.graveyard = []
        
        // Shuffle the deck
        self.deck.shuffle()
    }
    
    /// Draws cards from deck to hand
    public func drawCards(count: Int) -> [Card] {
        let actualCount = min(count, deck.count)
        let drawnCards = Array(deck.prefix(actualCount))
        deck.removeFirst(actualCount)
        hand.append(contentsOf: drawnCards)
        return drawnCards
    }
    
    /// Plays a card from hand
    public func playCard(named cardName: String) -> Card? {
        guard let index = hand.firstIndex(where: { $0.name.lowercased() == cardName.lowercased() }) else {
            return nil
        }
        let playedCard = hand.remove(at: index)
        graveyard.append(playedCard)
        return playedCard
    }
    
    /// Performs a mulligan
    public func mulligan(newHandSize: Int? = nil) -> [Card] {
        let drawSize = newHandSize ?? hand.count
        
        // Return hand to deck
        deck.append(contentsOf: hand)
        hand = []
        
        // Shuffle
        deck.shuffle()
        
        // Draw new hand
        return drawCards(count: min(drawSize, deck.count))
    }
    
    /// Swaps a card between deck/hand and sideboard
    public func sideboardSwap(removeCard: String, addCard: String) -> (removed: Card?, added: Card?) {
        // Find card in sideboard
        guard let sideboardIndex = sideboard.firstIndex(where: { $0.name.lowercased() == addCard.lowercased() }) else {
            return (nil, nil)
        }
        
        let sideboardCard = sideboard.remove(at: sideboardIndex)
        
        // Find card in deck or hand
        var removedCard: Card?
        
        if let deckIndex = deck.firstIndex(where: { $0.name.lowercased() == removeCard.lowercased() }) {
            removedCard = deck.remove(at: deckIndex)
            deck.append(sideboardCard)
        } else if let handIndex = hand.firstIndex(where: { $0.name.lowercased() == removeCard.lowercased() }) {
            removedCard = hand.remove(at: handIndex)
            hand.append(sideboardCard)
        }
        
        if let removed = removedCard {
            sideboard.append(removed)
            return (removed, sideboardCard)
        }
        
        // If card not found, put sideboard card back
        sideboard.append(sideboardCard)
        return (nil, nil)
    }
    
    /// Resets the game state
    public func resetGame() {
        // Reload from original deck data if available
        if let originalData = originalDeckData {
            loadDeck(originalData)
        } else {
            // Fallback: combine all cards back into deck
            var allCards = deck
            allCards.append(contentsOf: hand)
            allCards.append(contentsOf: graveyard)
            
            deck = allCards
            hand = []
            graveyard = []
            deck.shuffle()
        }
    }
    
    /// Gets current deck statistics
    public func getDeckStats() -> DeckStats {
        return DeckStats(
            cardsInDeck: deck.count,
            cardsInHand: hand.count,
            sideboardCards: sideboard.count,
            commander: commander,
            companion: companion
        )
    }
    
    /// Gets hand contents grouped by card name
    public func getHandContents() -> [String: Int] {
        var cardCounts: [String: Int] = [:]
        for card in hand {
            cardCounts[card.name, default: 0] += 1
        }
        return cardCounts
    }
    
    /// Gets deck contents grouped by card name (top cards)
    public func getDeckContents(limit: Int = 10) -> [String: Int] {
        var cardCounts: [String: Int] = [:]
        for card in deck {
            cardCounts[card.name, default: 0] += 1
        }
        
        // Return top cards by count
        let sortedCards = cardCounts.sorted { $0.value > $1.value }
        return Dictionary(uniqueKeysWithValues: Array(sortedCards.prefix(limit)))
    }
    
    /// Gets card type breakdown for the deck
    public func getCardTypeBreakdown() -> [String: Int] {
        var typeCounts: [String: Int] = [:]
        
        for card in deck {
            // Determine primary card type based on CardKind
            let cardType: String
            
            // For MDFCs, classify based on front face
            if card.isMDFC {
                // MDFC with land back face should count toward land total if it has utility
                if card.kind.hasLandBackface && !card.kind.isLand {
                    // This is a spell//land MDFC - count as both
                    if card.kind.isInstant {
                        cardType = "Instant"
                    } else if card.kind.isSorcery {
                        cardType = "Sorcery"
                    } else if card.kind.isCreature {
                        cardType = "Creature"
                    } else if card.kind.isArtifact {
                        cardType = "Artifact"
                    } else if card.kind.isEnchantment {
                        cardType = "Enchantment"
                    } else if card.kind.isPlaneswalker {
                        cardType = "Planeswalker"
                    } else {
                        cardType = "MDFC Spell"
                    }
                    
                    // Also count the land potential
                    typeCounts["MDFC Land", default: 0] += 1
                } else if card.kind.isLand {
                    cardType = "Land"
                } else {
                    cardType = "MDFC"
                }
            } else {
                // Regular card classification
                if card.kind.isLand {
                    cardType = "Land"
                } else if card.kind.isCreature {
                    cardType = "Creature"
                } else if card.kind.isInstant {
                    cardType = "Instant"
                } else if card.kind.isSorcery {
                    cardType = "Sorcery"
                } else if card.kind.isArtifact {
                    cardType = "Artifact"
                } else if card.kind.isEnchantment {
                    cardType = "Enchantment"
                } else if card.kind.isPlaneswalker {
                    cardType = "Planeswalker"
                } else {
                    cardType = "Other"
                }
            }
            
            typeCounts[cardType, default: 0] += 1
        }
        
        return typeCounts
    }
}

/// Represents parsed deck data
public struct DeckData: Sendable {
    public var mainDeck: [Card] = []
    public var sideboard: [Card] = []
    public var commander: Card?
    public var companion: Card?
    
    public init() {}
}

/// Represents deck statistics
public struct DeckStats: Sendable {
    public let cardsInDeck: Int
    public let cardsInHand: Int
    public let sideboardCards: Int
    public let commander: Card?
    public let companion: Card?
    
    public init(cardsInDeck: Int, cardsInHand: Int, sideboardCards: Int, commander: Card?, companion: Card?) {
        self.cardsInDeck = cardsInDeck
        self.cardsInHand = cardsInHand
        self.sideboardCards = sideboardCards
        self.commander = commander
        self.companion = companion
    }
}