import XCTest
@testable import mtg_mcp
@testable import MTGModels
@testable import MTGServices

final class GameStateTests: XCTestCase {
    var gameState: GameState!
    
    override func setUp() async throws {
        gameState = GameState()
    }
    
    func testLoadDeck() async {
        var deckData = DeckData()
        deckData.mainDeck = [
            Card(name: "Lightning Bolt"),
            Card(name: "Lightning Bolt"),
            Card(name: "Island"),
            Card(name: "Mountain")
        ]
        deckData.sideboard = [
            Card(name: "Negate"),
            Card(name: "Shock")
        ]
        
        await gameState.loadDeck(deckData)
        
        let stats = await gameState.getDeckStats()
        XCTAssertEqual(stats.cardsInDeck, 4)
        XCTAssertEqual(stats.sideboardCards, 2)
        XCTAssertEqual(stats.cardsInHand, 0)
    }
    
    func testDrawCards() async {
        var deckData = DeckData()
        deckData.mainDeck = [
            Card(name: "Lightning Bolt"),
            Card(name: "Island"),
            Card(name: "Mountain")
        ]
        
        await gameState.loadDeck(deckData)
        let drawnCards = await gameState.drawCards(count: 2)
        
        XCTAssertEqual(drawnCards.count, 2)
        
        let stats = await gameState.getDeckStats()
        XCTAssertEqual(stats.cardsInDeck, 1)
        XCTAssertEqual(stats.cardsInHand, 2)
    }
    
    func testDrawMoreCardsThanAvailable() async {
        var deckData = DeckData()
        deckData.mainDeck = [Card(name: "Lightning Bolt")]
        
        await gameState.loadDeck(deckData)
        let drawnCards = await gameState.drawCards(count: 5)
        
        XCTAssertEqual(drawnCards.count, 1) // Only 1 card available
        
        let stats = await gameState.getDeckStats()
        XCTAssertEqual(stats.cardsInDeck, 0)
        XCTAssertEqual(stats.cardsInHand, 1)
    }
    
    func testPlayCard() async {
        var deckData = DeckData()
        deckData.mainDeck = [
            Card(name: "Lightning Bolt"),
            Card(name: "Island")
        ]
        
        await gameState.loadDeck(deckData)
        await gameState.drawCards(count: 2)
        
        let playedCard = await gameState.playCard(named: "Lightning Bolt")
        XCTAssertNotNil(playedCard)
        XCTAssertEqual(playedCard?.name, "Lightning Bolt")
        
        let stats = await gameState.getDeckStats()
        XCTAssertEqual(stats.cardsInHand, 1)
    }
    
    func testPlayNonexistentCard() async {
        var deckData = DeckData()
        deckData.mainDeck = [Card(name: "Lightning Bolt")]
        
        await gameState.loadDeck(deckData)
        await gameState.drawCards(count: 1)
        
        let playedCard = await gameState.playCard(named: "Counterspell")
        XCTAssertNil(playedCard)
        
        let stats = await gameState.getDeckStats()
        XCTAssertEqual(stats.cardsInHand, 1) // Hand unchanged
    }
    
    func testMulligan() async {
        var deckData = DeckData()
        deckData.mainDeck = [
            Card(name: "Card1"),
            Card(name: "Card2"),
            Card(name: "Card3"),
            Card(name: "Card4"),
            Card(name: "Card5")
        ]
        
        await gameState.loadDeck(deckData)
        await gameState.drawCards(count: 3)
        
        let newHand = await gameState.mulligan(newHandSize: 2)
        XCTAssertEqual(newHand.count, 2)
        
        let stats = await gameState.getDeckStats()
        XCTAssertEqual(stats.cardsInHand, 2)
        XCTAssertEqual(stats.cardsInDeck, 3)
    }
    
    func testSideboardSwap() async {
        var deckData = DeckData()
        deckData.mainDeck = [
            Card(name: "Lightning Bolt"),
            Card(name: "Island")
        ]
        deckData.sideboard = [
            Card(name: "Negate"),
            Card(name: "Shock")
        ]
        
        await gameState.loadDeck(deckData)
        await gameState.drawCards(count: 1) // Draw Lightning Bolt
        
        let result = await gameState.sideboardSwap(removeCard: "Lightning Bolt", addCard: "Negate")
        
        XCTAssertNotNil(result.removed)
        XCTAssertNotNil(result.added)
        XCTAssertEqual(result.removed?.name, "Lightning Bolt")
        XCTAssertEqual(result.added?.name, "Negate")
        
        let stats = await gameState.getDeckStats()
        XCTAssertEqual(stats.sideboardCards, 2) // Lightning Bolt moved to sideboard, Shock remains
    }
    
    func testResetGame() async {
        var deckData = DeckData()
        deckData.mainDeck = [
            Card(name: "Card1"),
            Card(name: "Card2"),
            Card(name: "Card3")
        ]
        
        await gameState.loadDeck(deckData)
        await gameState.drawCards(count: 2)
        
        await gameState.resetGame()
        
        let stats = await gameState.getDeckStats()
        XCTAssertEqual(stats.cardsInDeck, 3)
        XCTAssertEqual(stats.cardsInHand, 0)
    }
    
    func testGetHandContents() async {
        var deckData = DeckData()
        deckData.mainDeck = [
            Card(name: "Lightning Bolt"),
            Card(name: "Lightning Bolt"),
            Card(name: "Island")
        ]
        
        await gameState.loadDeck(deckData)
        await gameState.drawCards(count: 3)
        
        let handContents = await gameState.getHandContents()
        XCTAssertEqual(handContents["Lightning Bolt"], 2)
        XCTAssertEqual(handContents["Island"], 1)
    }
}