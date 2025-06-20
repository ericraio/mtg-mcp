import Testing
import Card
import Foundation
import Database
@testable import Deck

struct DeckBuilderTests {
    
    // MARK: - Setup Helper
    
    @available(macOS 10.15, *)
    private static func loadCardDatabase() async {
        do {
            // Load the card database if it's not already loaded
            if CardData.shared.cards.isEmpty {
                print("Loading card database for tests...")
                try await CardData.shared.load()
                print("Card database loaded with \(CardData.shared.cards.count) cards")
            } else {
                print("Card database already loaded with \(CardData.shared.cards.count) cards")
            }
        } catch {
            print("⚠️ Failed to load card database: \(error). Tests may fail.")
        }
    }
    
    // MARK: - Initialization Tests
    
    @Test func testInitialization() {
        let builder = DeckBuilder()
        
        #expect(builder.invalid == false)
        #expect(builder.invalidMessage.isEmpty)
        #expect(builder.cards.isEmpty)
    }
    
    // MARK: - Basic Deck Loading Tests
    
    @Test func testLoadBasicDeckList() async {
        // Load card database before testing
        await Self.loadCardDatabase()
        
        let builder = DeckBuilder()
        let mockInput = "Custom Deck: Test Deck|2 Mountain|2 Plains|1 Sol Ring|"
        
        let deckData = builder.loadCardsFromList(code: mockInput)
        
        #expect(deckData.cards.count == 5)
        #expect(builder.invalid == false)
        
        // Verify card distribution
        let mountains = deckData.cards.filter { $0.name == "Mountain" }
        let plains = deckData.cards.filter { $0.name == "Plains" }
        let solRings = deckData.cards.filter { $0.name == "Sol Ring" }
        
        #expect(mountains.count == 2)
        #expect(plains.count == 2)
        #expect(solRings.count == 1)
    }
    
    @Test func testLoadEmptyDeckList() {
        let builder = DeckBuilder()
        let mockInput = "Custom Deck: Empty Deck|"
        
        let deckData = builder.loadCardsFromList(code: mockInput)
        
        #expect(deckData.cards.isEmpty)
        #expect(builder.invalid == false)
    }
    
    // MARK: - Commander Tests
    
    @Test func testLoadDeckWithCommanderMarker() async {
        // Load card database before testing
        await Self.loadCardDatabase()
        
        let builder = DeckBuilder()
        let mockInput = "Custom Deck: Commander Deck|CMDR: Golos, Tireless Pilgrim|2 Mountain|2 Plains|"
        
        let deckData = builder.loadCardsFromList(code: mockInput)
        
        #expect(deckData.commander != nil)
        #expect(deckData.commander?.name == "Golos, Tireless Pilgrim")
        #expect(deckData.commander?.kind.isCommander == true)
        #expect(deckData.cards.count == 5) // 1 commander + 4 other cards
    }
    
    @Test func testLoadDeckWithCommanderSection() async {
        // Load card database before testing
        await Self.loadCardDatabase()
        
        let builder = DeckBuilder()
        let mockInput = "Custom Deck: Commander Deck|Commander|1 Atraxa, Praetors' Voice|Deck|2 Mountain|2 Plains|"
        
        let deckData = builder.loadCardsFromList(code: mockInput)
        
        #expect(deckData.commander != nil)
        #expect(deckData.commander?.name == "Atraxa, Praetors' Voice")
        #expect(deckData.commander?.kind.isCommander == true)
        #expect(deckData.cards.count == 5) // 1 commander + 4 other cards
    }
    
    @Test func testLoadDeckWithInvalidCommander() async {
        // Load card database before testing
        await Self.loadCardDatabase()
        
        let builder = DeckBuilder()
        let mockInput = "Custom Deck: Commander Deck|CMDR: Invalid Commander Name|2 Mountain|"
        
        let _ = builder.loadCardsFromList(code: mockInput)
        
        #expect(builder.invalid == true)
        #expect(
            builder.invalidMessage.contains("Unable to find") || 
            builder.invalidMessage.contains("commander") || 
            builder.invalidMessage.contains("Commander")
        )
    }
    
    // MARK: - Companion Tests
    
    @Test func testLoadDeckWithCompanion() async {
        // Load card database before testing
        await Self.loadCardDatabase()
        
        let builder = DeckBuilder()
        let mockInput = "Custom Deck: Companion Deck|COMP: Lurrus of the Dream-Den|2 Mountain|2 Plains|"
        
        let deckData = builder.loadCardsFromList(code: mockInput)
        
        #expect(deckData.companion != nil)
        #expect(deckData.companion?.name == "Lurrus of the Dream-Den")
        #expect(deckData.companion?.kind.isCompanion == true)
        #expect(deckData.cards.count == 4) // Companion is not included in the deck
    }
    
    @Test func testLoadDeckWithInvalidCompanion() async {
        // Load card database before testing
        await Self.loadCardDatabase()
        
        let builder = DeckBuilder()
        let mockInput = "Custom Deck: Companion Deck|COMP: Invalid Companion Name|2 Mountain|"
        
        let _ = builder.loadCardsFromList(code: mockInput)
        
        #expect(builder.invalid == true)
        #expect(
            builder.invalidMessage.contains("Unable to find") || 
            builder.invalidMessage.contains("companion") || 
            builder.invalidMessage.contains("Companion")
        )
    }
    
    // MARK: - Format Parsing Tests
    
    @Test func testInvalidCardFormat() {
        let builder = DeckBuilder()
        let mockInput = "Custom Deck: Bad Format|Not A Valid Card Entry|"
        
        let deckData = builder.loadCardsFromList(code: mockInput)
        
        #expect(deckData.cards.isEmpty)
    }
    
    @Test func testCardWithInvalidQuantity() {
        let builder = DeckBuilder()
        let mockInput = "Custom Deck: Bad Quantity|0 Mountain|"
        
        let deckData = builder.loadCardsFromList(code: mockInput)
        
        #expect(deckData.cards.isEmpty)
    }
    
    @Test func testMissingCardInDatabase() async {
        // Load card database before testing
        await Self.loadCardDatabase()
        
        let builder = DeckBuilder()
        let mockInput = "Custom Deck: Missing Card|2 NonexistentCardName|"
        
        let _ = builder.loadCardsFromList(code: mockInput)
        
        #expect(builder.invalid == true)
        #expect(
            builder.invalidMessage.contains("Unable to find") || 
            builder.invalidMessage.contains("card") || 
            builder.invalidMessage.contains("not found")
        )
    }
    
    // MARK: - Integration Tests
    
    //@Test func testComplexDeckLoading() async {
    //    // Load card database before testing
    //    await Self.loadCardDatabase()
    //    
    //    let builder = DeckBuilder()
    //    let mockInput = "Custom Deck: Complex Deck|CMDR: Breya, Etherium Shaper|COMP: Jegantha, the Wellspring|Commander|1 Breya, Etherium Shaper|Deck|4 Mountain|4 Plains|4 Island|4 Swamp|2 Sol Ring|2 Arcane Signet|"
    //    
    //    let deckData = builder.loadCardsFromList(code: mockInput)
    //    
    //    // Should have 1 commander + 20 cards
    //    #expect(deckData.cards.count == 21)
    //    
    //    // Commander tests
    //    #expect(deckData.commander != nil)
    //    #expect(deckData.commander?.name == "Breya, Etherium Shaper")
    //    #expect(deckData.commander?.kind.isCommander == true)
    //    
    //    // Companion tests
    //    #expect(deckData.companion != nil)
    //    #expect(deckData.companion?.name == "Jegantha, the Wellspring")
    //    #expect(deckData.companion?.kind.isCompanion == true)
    //    
    //    // Card count tests
    //    let mountains = deckData.cards.filter { $0.name == "Mountain" }
    //    let plains = deckData.cards.filter { $0.name == "Plains" }
    //    let islands = deckData.cards.filter { $0.name == "Island" }
    //    let swamps = deckData.cards.filter { $0.name == "Swamp" }
    //    let solRings = deckData.cards.filter { $0.name == "Sol Ring" }
    //    let arcaneSignets = deckData.cards.filter { $0.name == "Arcane Signet" }
    //    
    //    #expect(mountains.count == 4)
    //    #expect(plains.count == 4)
    //    #expect(islands.count == 4)
    //    #expect(swamps.count == 4)
    //    #expect(solRings.count == 2)
    //    #expect(arcaneSignets.count == 2)
    //}
    
    // MARK: - Regex Tests
    
    @Test func testArenaLineRegex() {
        let regex = DeckBuilder.arenaLineRegex
        
        // Test basic card format
        let basicLine = "2 Mountain"
        if let result = regex.firstMatch(in: basicLine, range: NSRange(location: 0, length: basicLine.count)) {
            let nsString = basicLine as NSString
            
            // The first capture group is the amount, second is the name
            let amountRange = result.range(at: 1)
            let nameRange = result.range(at: 2)
            
            #expect(amountRange.location != NSNotFound)
            #expect(nameRange.location != NSNotFound)
            
            #expect(nsString.substring(with: amountRange) == "2")
            #expect(nsString.substring(with: nameRange).trimmingCharacters(in: .whitespaces) == "Mountain")
        } else {
            #expect(Bool(false), "Regex failed to match basic card format")
        }
        
        // Test expanded card format with set and number
        let expandedLine = "2 Lightning Bolt (M10) 146 #X=3 T=2 M=R"
        if let result = regex.firstMatch(in: expandedLine, range: NSRange(location: 0, length: expandedLine.count)) {
            let nsString = expandedLine as NSString
            
            // Using indexes instead of named captures for Swift 6 compatibility
            #expect(result.numberOfRanges >= 8) // Make sure we have enough captures
            
            let amountRange = result.range(at: 1)
            let nameRange = result.range(at: 2)
            
            #expect(nsString.substring(with: amountRange) == "2")
            #expect(nsString.substring(with: nameRange).trimmingCharacters(in: .whitespaces) == "Lightning Bolt")
        } else {
            #expect(Bool(false), "Regex failed to match expanded card format")
        }
    }
}
