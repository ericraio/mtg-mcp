import Foundation
import Testing
@testable import Card  

/// Tests for the MTGSet struct/class
struct MTGSetTests {
    
    // MARK: - Initialization Tests
    
    /// Test default initialization
    @Test func testDefaultInitialization() {
        let set = MTGSet()
        
        // Default values should be set appropriately
        #expect(set.name.isEmpty)
        #expect(set.code.isEmpty)
        #expect(set.type == .unknown)
        #expect(set.releaseDate == nil)
        //#expect(set.cardCount == 0)
        #expect(!set.isDigital)
    }
    
    /// Test initialization with parameters
    @Test func testParameterizedInitialization() {
        let releaseDate = Date(timeIntervalSince1970: 1577836800) // Jan 1, 2020
        let set = MTGSet(
            name: "Throne of Eldraine",
            code: "ELD",
            type: .expansion,
            releaseDate: releaseDate,
            cardCount: 302,
            isDigital: false
        )
        
        #expect(set.name == "Throne of Eldraine")
        #expect(set.code == "ELD")
        #expect(set.type == .expansion)
        #expect(set.releaseDate == releaseDate)
        #expect(set.cardCount == 302)
        #expect(!set.isDigital)
    }
    
    // MARK: - Property Tests
    
    /*
    /// Test set abbreviation
    @Test func testSetAbbreviation() {
        let set = MTGSet(name: "Throne of Eldraine", code: "ELD")
        
        #expect(set.abbreviation == "ELD")
        
        // Test with a lowercase code
        let lowerSet = MTGSet(name: "Tempest", code: "tmp")
        #expect(lowerSet.abbreviation == "TMP")
    }
    
    /// Test set block property
    @Test func testSetBlock() {
        // Test a set with a block
        let ravnicaSet = MTGSet(name: "Ravnica Allegiance", code: "RNA", block: "Ravnica")
        #expect(ravnicaSet.block == "Ravnica")
        
        // Test a set without a block
        let coreSet = MTGSet(name: "Core Set 2021", code: "M21")
        #expect(coreSet.block == nil)
    }
    
    /// Test set icon URL
    @Test func testSetIconURL() {
        let set = MTGSet(name: "Throne of Eldraine", code: "ELD")
        
        // The URL should contain the set code
        let iconURL = set.iconURL(variant: .common)
        #expect(iconURL != nil)
        if let url = iconURL {
            #expect(url.absoluteString.contains("ELD"))
        }
        
        // Test different rarity variants
        let uncommonURL = set.iconURL(variant: .uncommon)
        let rareURL = set.iconURL(variant: .rare)
        let mythicURL = set.iconURL(variant: .mythic)
        
        if let url = uncommonURL {
            #expect(url.absoluteString.contains("uncommon"))
        }
        if let url = rareURL {
            #expect(url.absoluteString.contains("rare"))
        }
        if let url = mythicURL {
            #expect(url.absoluteString.contains("mythic"))
        }
    }
    */
    
    /// Test format legality properties
    @Test func testFormatLegality() {
        // Current Standard-legal set
        let standardSet = MTGSet(
            name: "Modern Horizons 3",
            code: "MH3",
            type: .expansion,
            releaseDate: Date()  // Current date
        )
        
        #expect(standardSet.isStandardLegal)
        #expect(standardSet.isModernLegal)
        #expect(standardSet.isLegacyLegal)
        #expect(standardSet.isVintageLegal)
        
        // Older set not in Standard
        let pastDate = Date(timeIntervalSince1970: 1262304000)  // Jan 1, 2010
        let oldSet = MTGSet(
            name: "Mirrodin",
            code: "MRD",
            type: .expansion,
            releaseDate: pastDate
        )
        
        #expect(!oldSet.isStandardLegal)
        #expect(oldSet.isModernLegal)
        #expect(oldSet.isLegacyLegal)
        #expect(oldSet.isVintageLegal)
        
        // Supplemental set
        let commanderSet = MTGSet(
            name: "Commander 2021",
            code: "C21",
            type: .commander,
            releaseDate: Date()
        )
        
        #expect(!commanderSet.isStandardLegal)
        #expect(!commanderSet.isModernLegal)
        #expect(commanderSet.isLegacyLegal)
        #expect(commanderSet.isVintageLegal)
        #expect(commanderSet.isCommanderLegal)
    }
    
    // MARK: - Integration with Card Tests
    
    /// Test relationship between Card and MTGSet
    @Test func testCardSetRelationship() {
        let eldraineSet = MTGSet(
            name: "Throne of Eldraine",
            code: "ELD",
            type: .expansion,
            releaseDate: Date(),
            cardCount: 302,
            isDigital: false
        )

        // Create cards in this set using the safe factory method
        let oko = Card.createWithManaCost(
            name: "Oko, Thief of Crowns", 
            manaCostString: "{1}{G}{U}", 
            set: eldraineSet
        )

        let questing = Card.createWithManaCost(
            name: "Questing Beast", 
            manaCostString: "{2}{G}{G}", 
            set: eldraineSet
        )

        // Test card's reference to set
        #expect(oko.set.code == "ELD")
        #expect(oko.set.name == "Throne of Eldraine")
        #expect(questing.set.type == .expansion)

        // Standard legality should be inherited from set
        #expect(oko.isStandardLegal == eldraineSet.isStandardLegal)
        #expect(questing.isStandardLegal == eldraineSet.isStandardLegal)

        // Change set property and verify the card's legality reflects this
        var nonStandardSet = eldraineSet
        nonStandardSet.type = .commander

        let cmdCard = Card.createWithManaCost(
            name: "Commander Card", 
            manaCostString: "", 
            set: nonStandardSet
        )

        #expect(!cmdCard.isStandardLegal)
    } 

    /// Test creating various card types in a set
    @Test func testFactoryMethodsWithSet() {
        let set = MTGSet(name: "Throne of Eldraine", code: "ELD", type: .expansion)
        
        // Create cards using factory methods
        let land = Card.basicLand(name: "Forest", set: set)
        let creature = Card.creature(name: "Questing Beast", manaCost: "{2}{G}{G}", set: set)
        let instant = Card.instant(name: "Once Upon a Time", manaCost: "{1}{G}", set: set)
        let sorcery = Card.sorcery(name: "Escape to the Wilds", manaCost: "{3}{G}{G}", set: set)
        
        // Verify all cards reference the same set
        #expect(land.set.code == "ELD")
        #expect(creature.set.code == "ELD")
        #expect(instant.set.code == "ELD")
        #expect(sorcery.set.code == "ELD")
        
        // Verify card types were set correctly
        #expect(land.kind.isLand)
        #expect(land.kind.isBasicLand)
        #expect(creature.kind.isCreature)
        #expect(instant.kind.isInstant)
        #expect(sorcery.kind.isSorcery)
    }
    
    // MARK: - Equatable Conformance Tests
    
    /// Test Equatable conformance
    @Test func testEquatable() {
        let set1 = MTGSet(name: "Throne of Eldraine", code: "ELD")
        let set2 = MTGSet(name: "Throne of Eldraine", code: "ELD")
        let set3 = MTGSet(name: "Theros Beyond Death", code: "THB")
        
        #expect(set1 == set2)
        #expect(set1 != set3)
    }
    
    // MARK: - Hashable Conformance Tests
    
    /// Test Hashable conformance
    @Test func testHashable() {
        let set1 = MTGSet(name: "Throne of Eldraine", code: "ELD")
        let set2 = MTGSet(name: "Theros Beyond Death", code: "THB")
        let set3 = MTGSet(name: "Throne of Eldraine", code: "ELD")
        
        var setSet = Set<MTGSet>()
        setSet.insert(set1)
        setSet.insert(set2)
        setSet.insert(set3)  // Should be considered a duplicate of set1
        
        #expect(setSet.count == 2)
    }
    
    // MARK: - Codable Conformance Tests
    
    /// Test Codable conformance
    @Test func testCodable() {
        let set = MTGSet(
            name: "Throne of Eldraine",
            code: "ELD",
            type: .expansion,
            releaseDate: Date(timeIntervalSince1970: 1569888000),  // Oct 1, 2019
            cardCount: 302,
            isDigital: false,
            block: "Return to Return to Ravnica"
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let encoded = try encoder.encode(set)
            let decoded = try decoder.decode(MTGSet.self, from: encoded)
            
            #expect(decoded.name == set.name)
            #expect(decoded.code == set.code)
            #expect(decoded.type == set.type)
            #expect(decoded.cardCount == set.cardCount)
            #expect(decoded.isDigital == set.isDigital)
            #expect(decoded.block == set.block)
            
            // Date encoding/decoding might have precision issues
            if let decodedDate = decoded.releaseDate, let originalDate = set.releaseDate {
                let timeIntervalDifference = abs(decodedDate.timeIntervalSince1970 - originalDate.timeIntervalSince1970)
                #expect(timeIntervalDifference < 1.0)  // Within 1 second
            }
        } catch {
            #expect(Bool(false), "Failed to encode/decode MTGSet: \(error)")
        }
    }
    
    // MARK: - Collection Tests
    
    /// Test filtering cards by set
    @Test func testFilteringCardsBySet() {
        let eldraineSet = MTGSet(name: "Throne of Eldraine", code: "ELD")
        let ikoriaSet = MTGSet(name: "Ikoria: Lair of Behemoths", code: "IKO")
        
        // Create cards from different sets
        let oko = Card(name: "Oko, Thief of Crowns", set: eldraineSet)
        let beast = Card(name: "Questing Beast", set: eldraineSet)
        let lukka = Card(name: "Lukka, Coppercoat Outcast", set: ikoriaSet)
        let godzilla = Card(name: "Godzilla, King of the Monsters", set: ikoriaSet)
        
        // Create a collection of cards
        let cards = [oko, beast, lukka, godzilla]
        
        // Filter cards by set
        let eldraineCards = cards.filter { $0.set.code == eldraineSet.code }
        let ikoriaCards = cards.filter { $0.set.code == ikoriaSet.code }
        
        #expect(eldraineCards.count == 2)
        #expect(ikoriaCards.count == 2)
        
        #expect(eldraineCards.contains(oko))
        #expect(eldraineCards.contains(beast))
        #expect(ikoriaCards.contains(lukka))
        #expect(ikoriaCards.contains(godzilla))
    }
    
    // MARK: - Utility Methods Tests
    
    /// Test formatting of release date 
    @Test func testFormattedReleaseDate() {
        let set = MTGSet(
            name: "Throne of Eldraine",
            code: "ELD",
            type: .expansion,
            releaseDate: Date(timeIntervalSince1970: 1569888000)  // September 30, 2019
        )
        
        // Test date formatting - this depends on how your MTGSet implements date formatting
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        if let releaseDate = set.releaseDate {
            let formattedDate = dateFormatter.string(from: releaseDate)
            #expect(formattedDate.contains("September"))
            #expect(formattedDate.contains("2019"))
        }
    }
}
