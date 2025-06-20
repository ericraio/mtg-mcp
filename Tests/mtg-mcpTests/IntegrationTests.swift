import XCTest
@testable import mtg_mcp
@testable import MTGModels
@testable import MTGServices

final class IntegrationTests: XCTestCase {
    
    func testFullGameFlow() async {
        let gameState = GameState()
        
        // Load a deck
        let deckData = TestDataLoader.createBasicDeckData()
        await gameState.loadDeck(deckData)
        
        // Check initial stats
        var stats = await gameState.getDeckStats()
        XCTAssertTrue(stats.cardsInDeck > 0, "Deck should have cards")
        XCTAssertEqual(stats.cardsInHand, 0)
        XCTAssertEqual(stats.sideboardCards, 2)
        
        let initialDeckSize = stats.cardsInDeck
        
        // Draw opening hand
        let openingHand = await gameState.drawCards(count: 7)
        XCTAssertEqual(openingHand.count, min(7, initialDeckSize))
        
        stats = await gameState.getDeckStats()
        XCTAssertEqual(stats.cardsInDeck + stats.cardsInHand, initialDeckSize)
        
        // Play a card if we have one
        if stats.cardsInHand > 0 {
            let handContents = await gameState.getHandContents()
            if let cardName = handContents.keys.first {
                let playedCard = await gameState.playCard(named: cardName)
                XCTAssertNotNil(playedCard)
                
                stats = await gameState.getDeckStats()
                XCTAssertEqual(stats.cardsInHand, openingHand.count - 1)
            }
        }
        
        // Reset game
        await gameState.resetGame()
        
        stats = await gameState.getDeckStats()
        XCTAssertEqual(stats.cardsInDeck, initialDeckSize)
        XCTAssertEqual(stats.cardsInHand, 0)
    }
    
    func testDeckParsingIntegration() {
        // Test basic deck parsing without file loading
        let deckText = """
        Deck
        4 Lightning Bolt
        4 Counterspell
        20 Island
        
        Sideboard
        2 Negate
        1 Spell Pierce
        """
        
        let deckData = DeckParser.parseDeckList(deckText)
        
        // Verify deck parsing
        XCTAssertEqual(deckData.mainDeck.count, 28) // 4 + 4 + 20
        XCTAssertEqual(deckData.sideboard.count, 3) // 2 + 1
        
        // Check for specific cards
        let lightningBolts = deckData.mainDeck.filter { $0.name == "Lightning Bolt" }
        XCTAssertEqual(lightningBolts.count, 4)
        
        let negates = deckData.sideboard.filter { $0.name == "Negate" }
        XCTAssertEqual(negates.count, 2)
    }
    
    func testCommanderDeckParsing() {
        // Test commander deck parsing without file loading
        let commanderText = """
        Commander
        1 Atraxa, Praetors' Voice
        
        Deck
        1 Sol Ring
        1 Command Tower
        98 Forest
        """
        
        let deckData = DeckParser.parseDeckList(commanderText)
        
        // Verify commander deck structure
        XCTAssertNotNil(deckData.commander)
        XCTAssertEqual(deckData.commander?.name, "Atraxa, Praetors' Voice")
        XCTAssertEqual(deckData.mainDeck.count, 100) // Commander deck is 100 cards including commander
    }
    
    func testMulliganFlow() async {
        let gameState = GameState()
        let deckData = TestDataLoader.createBasicDeckData()
        await gameState.loadDeck(deckData)
        
        // Draw opening hand
        await gameState.drawCards(count: 7)
        
        // Mulligan to 6
        let newHand = await gameState.mulligan(newHandSize: 6)
        XCTAssertEqual(newHand.count, 6)
        
        let stats = await gameState.getDeckStats()
        XCTAssertEqual(stats.cardsInHand, 6)
        XCTAssertEqual(stats.cardsInDeck, 5) // 11 - 6 = 5
        
        // Mulligan to 5
        let secondMulligan = await gameState.mulligan(newHandSize: 5)
        XCTAssertEqual(secondMulligan.count, 5)
        
        let finalStats = await gameState.getDeckStats()
        XCTAssertEqual(finalStats.cardsInHand, 5)
        XCTAssertEqual(finalStats.cardsInDeck, 6) // 11 - 5 = 6
    }
    
    func testSideboardingScenarios() async {
        let gameState = GameState()
        var deckData = DeckData()
        
        // Create deck with multiple copies of cards
        deckData.mainDeck = [
            Card(name: "Lightning Bolt"),
            Card(name: "Lightning Bolt"),
            Card(name: "Lightning Bolt"),
            Card(name: "Lightning Bolt"),
            Card(name: "Counterspell"),
            Card(name: "Island")
        ]
        deckData.sideboard = [
            Card(name: "Pyroblast"),
            Card(name: "Red Elemental Blast"),
            Card(name: "Negate")
        ]
        
        await gameState.loadDeck(deckData)
        await gameState.drawCards(count: 2) // Draw some cards to hand
        
        // Swap card from deck
        let deckSwap = await gameState.sideboardSwap(removeCard: "Counterspell", addCard: "Pyroblast")
        XCTAssertNotNil(deckSwap.removed)
        XCTAssertEqual(deckSwap.removed?.name, "Counterspell")
        
        // Swap card from hand
        let handSwap = await gameState.sideboardSwap(removeCard: "Lightning Bolt", addCard: "Red Elemental Blast")
        XCTAssertNotNil(handSwap.removed)
        XCTAssertEqual(handSwap.removed?.name, "Lightning Bolt")
        
        // Verify sideboard contents changed
        let stats = await gameState.getDeckStats()
        XCTAssertEqual(stats.sideboardCards, 3) // Should still have 3 cards (swapped 2 out, 2 in, plus original Negate)
    }
}