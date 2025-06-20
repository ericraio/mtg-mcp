import Testing
import Card
@testable import Deck

struct DeckTests {

    @Test func testInitWithCardsAndMaxTurn() {
        let land = Card.basicLand(name: "Land")
        let creature = Card.creature(name: "Creat", manaCost: "{2}")
        creature.setTurn(3)
        let sorcery = Card.sorcery(name: "Sor", manaCost: "{1}")
        sorcery.setTurn(2)

        let deck = Deck(cards: [land, creature, sorcery])

        #expect(deck.maxTurn() == 3)
    }

    @Test func testCardFromName() {
        let cardA = Card.creature(name: "A", manaCost: "{1}")
        let cardB = Card.creature(name: "B", manaCost: "{2}")

        let deck = Deck(cards: [cardA, cardB])

        #expect(deck.cardFromName(name: "A") === cardA)
        #expect(deck.cardFromName(name: "C") == nil)
    }

    @Test func testBuildListGroupingAndSpellCounts() {
        let rock1 = Card.manaRock(name: "Rock", manaCost: "{1}")
        let rock2 = Card.manaRock(name: "Rock", manaCost: "{1}")
        rock2.setTurn(1)
        let land1 = Card.basicLand(name: "Land")
        let land2 = Card.basicLand(name: "Land")
        land1.setTurn(0)
        land2.setTurn(0)

        let deck = Deck(cards: [rock1, land1, rock2, land2])

        let list = deck.list
        #expect(list.count == 2)

        let landEntry = list.first { $0.card.name == "Land" }
        let rockEntry = list.first { $0.card.name == "Rock" }

        #expect(landEntry?.count == 2)
        #expect(rockEntry?.count == 2)
    }

    @Test func testInvalidDefaultBuilderState() {
        let deck = Deck(cards: [])
        #expect(deck.invalid() == false)
        #expect(deck.invalidMessage().isEmpty)
    }
}
