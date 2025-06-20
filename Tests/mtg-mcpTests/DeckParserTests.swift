import XCTest
@testable import mtg_mcp
@testable import MTGModels
@testable import MTGServices

final class DeckParserTests: XCTestCase {
    
    func testBasicDeckParsing() {
        let deckText = """
        Deck
        4 Lightning Bolt
        2 Counterspell
        20 Island
        
        Sideboard
        2 Negate
        1 Spell Pierce
        """
        
        let deckData = DeckParser.parseDeckList(deckText)
        
        XCTAssertEqual(deckData.mainDeck.count, 26) // 4 + 2 + 20
        XCTAssertEqual(deckData.sideboard.count, 3) // 2 + 1
        
        // Check specific cards
        let lightningBolts = deckData.mainDeck.filter { $0.name == "Lightning Bolt" }
        XCTAssertEqual(lightningBolts.count, 4)
        
        let negates = deckData.sideboard.filter { $0.name == "Negate" }
        XCTAssertEqual(negates.count, 2)
    }
    
    func testDeckParsingWithoutHeaders() {
        let deckText = """
        4 Lightning Bolt
        2 Counterspell
        """
        
        let deckData = DeckParser.parseDeckList(deckText)
        
        // Should default to main deck
        XCTAssertEqual(deckData.mainDeck.count, 6) // 4 + 2
        XCTAssertEqual(deckData.sideboard.count, 0)
    }
    
    func testDeckParsingWithXQuantity() {
        let deckText = """
        Deck
        4x Lightning Bolt
        2x Counterspell
        """
        
        let deckData = DeckParser.parseDeckList(deckText)
        
        XCTAssertEqual(deckData.mainDeck.count, 6) // 4 + 2
        
        let lightningBolts = deckData.mainDeck.filter { $0.name == "Lightning Bolt" }
        XCTAssertEqual(lightningBolts.count, 4)
    }
    
    func testDeckParsingWithSetInfo() {
        let deckText = """
        Deck
        4 Lightning Bolt (LEA) 161
        2 Counterspell (LEA) 55
        """
        
        let deckData = DeckParser.parseDeckList(deckText)
        
        XCTAssertEqual(deckData.mainDeck.count, 6)
        
        let lightningBolts = deckData.mainDeck.filter { $0.name == "Lightning Bolt" }
        XCTAssertEqual(lightningBolts.count, 4)
    }
    
    func testCommanderDeckParsing() {
        let deckText = """
        Commander
        1 Sol Ring
        
        Deck
        4 Lightning Bolt
        2 Island
        """
        
        let deckData = DeckParser.parseDeckList(deckText)
        
        XCTAssertNotNil(deckData.commander)
        XCTAssertEqual(deckData.commander?.name, "Sol Ring")
        XCTAssertEqual(deckData.mainDeck.count, 6) // 4 Lightning Bolt + 2 Island (commander is separate)
    }
    
    func testEmptyDeckParsing() {
        let deckText = ""
        let deckData = DeckParser.parseDeckList(deckText)
        
        XCTAssertEqual(deckData.mainDeck.count, 0)
        XCTAssertEqual(deckData.sideboard.count, 0)
        XCTAssertNil(deckData.commander)
        XCTAssertNil(deckData.companion)
    }
    
    func testInvalidLinesParsing() {
        let deckText = """
        Deck
        4 Lightning Bolt
        This is not a valid line
        Invalid format
        2 Counterspell
        """
        
        let deckData = DeckParser.parseDeckList(deckText)
        
        // Should skip invalid lines and parse valid ones
        XCTAssertEqual(deckData.mainDeck.count, 6) // 4 + 2
    }
}