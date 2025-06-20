import Foundation
import Card

public class Deck {
    public let code: String

    public let cards: [Card]

    public let list: [Spell]
    
    /// The commander card for Commander format decks
    public var commander: Card?
    
    /// The companion card for decks with companions
    public var companion: Card?

    private let deckBuilder: DeckBuilder

    public init(cards: [Card]) {
        self.code = ""
        self.cards = cards
        self.list = buildList(cards: cards)
        self.deckBuilder = DeckBuilder()
        self.commander = nil
        self.companion = nil
    }
    
    private init(code: String, cards: [Card], list: [Spell], deckBuilder: DeckBuilder, commander: Card? = nil, companion: Card? = nil) {
        self.code = code
        self.cards = cards
        self.list = list
        self.deckBuilder = deckBuilder
        self.commander = commander
        self.companion = companion
    }
    
    public init (code: String) {
        self.code = code
        self.deckBuilder = DeckBuilder()
        let deckData = self.deckBuilder.loadCardsFromList(code: code)
        self.cards = deckData.cards
        self.commander = deckData.commander
        self.companion = deckData.companion
        self.list = buildList(cards: cards)
    }
    
    public func maxTurn() -> Int {
        var turn = 0
        for card in cards {
            if card.turn > turn {
                turn = card.turn
            }
        }
        return turn
    }
    
    
    func invalid() -> Bool {
        return deckBuilder.invalid
    }
    
    func invalidMessage() -> String {
        return deckBuilder.invalidMessage
    }
    
    func cardFromName(name: String) -> Card? {
        return cards.first { $0.name == name }
    }
}

func buildList(cards: [Card]) -> [Spell] {
    var landCount = 0
    var nonLandCount = 0
    for card in cards {
        if card.isLand {
            landCount += 1
        } else {
            nonLandCount += 1
        }
    }
    var output: [String: [Card]] = [:]

    // Group cards by name
    for card in cards {
        let name = card.name
        if output[name] == nil {
            output[name] = []
        }
        output[name]?.append(card)
    }

    var list: [Spell] = []

    // Create spell entries - TEMPORARILY INCLUDE ALL CARDS
    for (_, cardsWithSameName) in output {
        if let firstCard = cardsWithSameName.first {
            // For debugging, include all cards, even lands
            list.append(Spell(
                card: firstCard,
                count: cardsWithSameName.count
            ))
            print("Added \(firstCard.name) to spell list (isLand: \(firstCard.isLand))")
        }
    }

    // Sort by turn, and alphabetically for ties
    list.sort {
        if $0.card.turn != $1.card.turn {
            return $0.card.turn < $1.card.turn
        } else {
            return $0.card.name < $1.card.name
        }
    }
    print("Final list contains \(list.count) spells")

    return list
}
