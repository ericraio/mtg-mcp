import Card

/// Structure to hold deck data including cards, commander, and companion
struct DeckData {
    var cards: [Card]
    var commander: Card?
    var companion: Card?
    
    init(cards: [Card] = [], commander: Card? = nil, companion: Card? = nil) {
        self.cards = cards
        self.commander = commander
        self.companion = companion
    }
}

