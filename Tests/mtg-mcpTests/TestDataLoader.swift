import Foundation
@testable import mtg_mcp
@testable import MTGModels
@testable import MTGServices

class TestDataLoader {
    
    static func loadSampleDeck(named filename: String) -> String? {
        let bundle = Bundle(for: TestDataLoader.self)
        guard let url = bundle.url(forResource: filename, withExtension: "txt", subdirectory: "TestData") else {
            // Try without subdirectory
            guard let url = bundle.url(forResource: filename, withExtension: "txt") else {
                return nil
            }
            return try? String(contentsOf: url)
        }
        
        return try? String(contentsOf: url)
    }
    
    static func createSampleCard() -> Card {
        return Card(
            name: "Lightning Bolt",
            manaCostString: "{R}",
            rarity: .common,
            typeLine: "Instant",
            oracleText: "Lightning Bolt deals 3 damage to any target.",
            power: nil,
            toughness: nil,
            loyalty: nil
        )
    }
    
    static func createSampleCreature() -> Card {
        return Card(
            name: "Grizzly Bears",
            manaCostString: "{1}{G}",
            rarity: .common,
            typeLine: "Creature — Bear",
            oracleText: "",
            power: "2",
            toughness: "2",
            loyalty: nil
        )
    }
    
    static func createSamplePlaneswalker() -> Card {
        return Card(
            name: "Jace, the Mind Sculptor",
            manaCostString: "{2}{U}{U}",
            rarity: .mythic,
            typeLine: "Legendary Planeswalker — Jace",
            oracleText: "+2: Look at the top card of target player's library...",
            power: nil,
            toughness: nil,
            loyalty: "3"
        )
    }
    
    static func createBasicDeckData() -> DeckData {
        var deckData = DeckData()
        deckData.mainDeck = [
            Card(name: "Lightning Bolt"),
            Card(name: "Lightning Bolt"),
            Card(name: "Lightning Bolt"),
            Card(name: "Lightning Bolt"),
            Card(name: "Counterspell"),
            Card(name: "Counterspell"),
            Card(name: "Island"),
            Card(name: "Island"),
            Card(name: "Island"),
            Card(name: "Mountain"),
            Card(name: "Mountain")
        ]
        deckData.sideboard = [
            Card(name: "Negate"),
            Card(name: "Pyroblast")
        ]
        return deckData
    }
    
    static func createCommanderDeckData() -> DeckData {
        var deckData = DeckData()
        deckData.commander = Card(name: "Atraxa, Praetors' Voice")
        deckData.mainDeck = Array(repeating: Card(name: "Forest"), count: 99)
        return deckData
    }
}