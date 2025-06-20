import XCTest
@testable import MTGServices
@testable import MTGModels

final class ImprovedDeckParserTests: XCTestCase {
    
    // MARK: - Land Recognition Integration Tests
    
    func testBasicLandParsing() {
        let deckList = """
        Deck
        4 Plains
        4 Island
        4 Swamp
        4 Mountain
        4 Forest
        2 Wastes
        """
        
        let deckData = DeckParser.parseDeckList(deckList)
        let landCards = deckData.mainDeck.filter { $0.isLand }
        
        XCTAssertEqual(landCards.count, 22, "Should parse all 22 basic lands")
        
        // Check specific land types
        let plains = landCards.filter { $0.name == "Plains" }
        XCTAssertEqual(plains.count, 4)
        XCTAssertTrue(plains.first?.kind.isBasicLand == true)
        
        let wastes = landCards.filter { $0.name == "Wastes" }
        XCTAssertEqual(wastes.count, 2)
        XCTAssertTrue(wastes.first?.kind.isBasicLand == true)
    }
    
    func testShockLandParsing() {
        let deckList = """
        Deck
        1 Sacred Foundry
        1 Steam Vents
        1 Overgrown Tomb
        1 Watery Grave
        """
        
        let deckData = DeckParser.parseDeckList(deckList)
        let shockLands = deckData.mainDeck.filter { $0.kind.isShockLand }
        
        XCTAssertEqual(shockLands.count, 4, "Should parse all 4 shock lands")
        
        for land in shockLands {
            XCTAssertTrue(land.isLand, "\(land.name) should be detected as a land")
            XCTAssertTrue(land.kind.isShockLand, "\(land.name) should be detected as a shock land")
        }
    }
    
    func testFetchLandParsing() {
        let deckList = """
        Deck
        1 Arid Mesa
        1 Bloodstained Mire
        1 Flooded Strand
        1 Misty Rainforest
        1 Fabled Passage
        1 Evolving Wilds
        """
        
        let deckData = DeckParser.parseDeckList(deckList)
        let fetchLands = deckData.mainDeck.filter { $0.isLand && LandDetectionService.getLandCategory($0.name) == .fetch }
        
        XCTAssertEqual(fetchLands.count, 6, "Should parse all 6 fetch lands")
        
        for land in fetchLands {
            XCTAssertTrue(land.isLand, "\(land.name) should be detected as a land")
            XCTAssertTrue(land.kind.isOtherLand, "\(land.name) fetch lands should be categorized as other lands")
        }
    }
    
    func testUtilityLandParsing() {
        let deckList = """
        Deck
        1 Ancient Tomb
        1 Strip Mine
        1 Wasteland
        1 Cabal Coffers
        1 Urborg, Tomb of Yawgmoth
        1 Thespian's Stage
        1 Inkmoth Nexus
        1 Cavern of Souls
        """
        
        let deckData = DeckParser.parseDeckList(deckList)
        let utilityLands = deckData.mainDeck.filter { $0.isLand && LandDetectionService.getLandCategory($0.name) == .utility }
        
        XCTAssertEqual(utilityLands.count, 8, "Should parse all 8 utility lands")
        
        for land in utilityLands {
            XCTAssertTrue(land.isLand, "\(land.name) should be detected as a land")
            XCTAssertTrue(land.kind.isOtherLand, "\(land.name) utility lands should be categorized as other lands")
        }
    }
    
    func testMDFCLandParsing() {
        let deckList = """
        Deck
        1 Malakir Rebirth // Malakir Mire
        1 Turntimber Symbiosis // Turntimber, Serpentine Wood
        1 Ondu Inversion // Ondu Skyruins
        1 Jwari Disruption // Jwari Ruins
        """
        
        let deckData = DeckParser.parseDeckList(deckList)
        let mdfcLands = deckData.mainDeck.filter { $0.isLand && LandDetectionService.getLandCategory($0.name) == .mdfc }
        
        XCTAssertEqual(mdfcLands.count, 4, "Should parse all 4 MDFC lands")
        
        for land in mdfcLands {
            XCTAssertTrue(land.isLand, "\(land.name) should be detected as a land")
            XCTAssertTrue(land.kind.hasLandBackface, "\(land.name) should have land backface property")
        }
    }
    
    func testCommanderLandParsing() {
        let deckList = """
        Deck
        1 Command Tower
        1 Path of Ancestry
        1 Exotic Orchard
        1 Reflecting Pool
        1 City of Brass
        1 Mana Confluence
        """
        
        let deckData = DeckParser.parseDeckList(deckList)
        let commanderLands = deckData.mainDeck.filter { 
            $0.isLand && ["Command Tower", "Path of Ancestry", "Exotic Orchard", "Reflecting Pool", "City of Brass", "Mana Confluence"].contains($0.name)
        }
        
        XCTAssertEqual(commanderLands.count, 6, "Should parse all 6 commander-specific lands")
        
        for land in commanderLands {
            XCTAssertTrue(land.isLand, "\(land.name) should be detected as a land")
        }
    }
    
    // MARK: - Mixed Deck Tests
    
    func testMixedDeckWithProblematicLands() {
        // This deck list contains the types of lands that were previously missed
        let deckList = """
        Deck
        4 Lightning Bolt
        4 Counterspell
        1 Sol Ring
        2 Plains
        2 Island
        1 Command Tower
        1 Ancient Tomb
        1 Strip Mine
        1 Cabal Coffers
        1 Urborg, Tomb of Yawgmoth
        1 Malakir Rebirth // Malakir Mire
        1 Jwari Disruption // Jwari Ruins
        1 Sacred Foundry
        1 Arid Mesa
        1 Thespian's Stage
        1 Cavern of Souls
        """
        
        let deckData = DeckParser.parseDeckList(deckList)
        let allCards = deckData.mainDeck
        let landCards = allCards.filter { $0.isLand }
        let nonLandCards = allCards.filter { !$0.isLand }
        
        // Should correctly identify 15 lands total
        XCTAssertEqual(landCards.count, 15, "Should correctly identify 15 lands")
        XCTAssertEqual(nonLandCards.count, 9, "Should correctly identify 9 non-lands")
        
        // Verify specific problematic cards are detected
        let problematicLandNames = ["Ancient Tomb", "Strip Mine", "Cabal Coffers", "Urborg, Tomb of Yawgmoth", 
                                   "Malakir Rebirth // Malakir Mire", "Jwari Disruption // Jwari Ruins", 
                                   "Thespian's Stage", "Cavern of Souls"]
        
        for landName in problematicLandNames {
            let found = landCards.contains { $0.name == landName }
            XCTAssertTrue(found, "\(landName) should be detected as a land")
        }
        
        // Verify non-lands are not detected as lands
        let nonLandNames = ["Lightning Bolt", "Counterspell", "Sol Ring"]
        for nonLandName in nonLandNames {
            let foundAsLand = landCards.contains { $0.name == nonLandName }
            XCTAssertFalse(foundAsLand, "\(nonLandName) should NOT be detected as a land")
        }
    }
    
    func testCommanderDeckWithCorrectLandCount() {
        // A realistic Commander deck that should have exactly 32 lands
        let deckList = """
        Commander
        1 Atraxa, Praetors' Voice
        
        Deck
        1 Command Tower
        1 Path of Ancestry  
        1 Exotic Orchard
        1 City of Brass
        1 Mana Confluence
        1 Reflecting Pool
        1 Ancient Tomb
        1 Strip Mine
        1 Wasteland
        1 Cabal Coffers
        1 Urborg, Tomb of Yawgmoth
        1 Bojuka Bog
        1 Academy Ruins
        1 Inventors' Fair
        1 Cavern of Souls
        1 Boseiju, Who Shelters All
        1 Rishadan Port
        1 Thespian's Stage
        1 Dark Depths
        1 Inkmoth Nexus
        2 Plains
        2 Island  
        2 Swamp
        2 Forest
        1 Sacred Foundry
        1 Temple Garden
        1 Overgrown Tomb
        1 Watery Grave
        1 Breeding Pool
        1 Godless Shrine
        1 Hallowed Fountain
        1 Stomping Ground
        60 Lightning Bolt
        """
        
        let deckData = DeckParser.parseDeckList(deckList)
        let landCards = deckData.mainDeck.filter { $0.isLand }
        
        XCTAssertEqual(landCards.count, 32, "Should correctly identify exactly 32 lands in Commander deck")
        
        // Verify commander is not counted as a land (even though Atraxa isn't a land, this tests the logic)
        XCTAssertNotNil(deckData.commander)
        XCTAssertEqual(deckData.commander?.name, "Atraxa, Praetors' Voice")
        
        // Verify total deck composition
        let totalMainDeck = deckData.mainDeck.count
        let expectedTotal = 32 + 60 // 32 lands + 60 Lightning Bolts
        XCTAssertEqual(totalMainDeck, expectedTotal, "Total main deck count should be \(expectedTotal)")
    }
    
    // MARK: - Edge Cases and Error Handling
    
    func testTypoInLandNames() {
        let deckList = """
        Deck
        1 Plains
        1 Planis
        1 Command tower
        1 ancient tomb
        1 STRIP MINE
        """
        
        let deckData = DeckParser.parseDeckList(deckList)
        let landCards = deckData.mainDeck.filter { $0.isLand }
        
        // Should detect Plains, Command tower (case insensitive), ancient tomb (case insensitive), STRIP MINE (case insensitive)
        // Should NOT detect "Planis" (typo)
        XCTAssertEqual(landCards.count, 4, "Should detect 4 valid lands, ignoring typo")
        
        let landNames = landCards.map { $0.name }
        XCTAssertTrue(landNames.contains("Plains"))
        XCTAssertTrue(landNames.contains("Command tower"))
        XCTAssertTrue(landNames.contains("ancient tomb"))
        XCTAssertTrue(landNames.contains("STRIP MINE"))
        XCTAssertFalse(landNames.contains("Planis"))
    }
    
    func testEmptyLines() {
        let deckList = """
        Deck
        
        1 Plains
        
        1 Island
        
        1 Command Tower
        
        """
        
        let deckData = DeckParser.parseDeckList(deckList)
        let landCards = deckData.mainDeck.filter { $0.isLand }
        
        XCTAssertEqual(landCards.count, 3, "Should handle empty lines correctly")
    }
    
    func testSideboardLands() {
        let deckList = """
        Deck
        1 Plains
        1 Lightning Bolt
        
        Sideboard
        1 Island
        1 Ancient Tomb
        1 Counterspell
        """
        
        let deckData = DeckParser.parseDeckList(deckList)
        let mainDeckLands = deckData.mainDeck.filter { $0.isLand }
        let sideboardLands = deckData.sideboard.filter { $0.isLand }
        
        XCTAssertEqual(mainDeckLands.count, 1, "Should detect 1 land in main deck")
        XCTAssertEqual(sideboardLands.count, 2, "Should detect 2 lands in sideboard")
        
        XCTAssertEqual(mainDeckLands.first?.name, "Plains")
        let sideboardLandNames = sideboardLands.map { $0.name }
        XCTAssertTrue(sideboardLandNames.contains("Island"))
        XCTAssertTrue(sideboardLandNames.contains("Ancient Tomb"))
    }
    
    // MARK: - Performance Tests
    
    func testLargeDeckParsingPerformance() {
        // Create a large deck list with many lands
        var deckComponents: [String] = ["Deck"]
        
        // Add 100 different land cards (some repeated)
        let landNames = [
            "Plains", "Island", "Swamp", "Mountain", "Forest",
            "Command Tower", "Ancient Tomb", "Strip Mine", "Cabal Coffers",
            "Sacred Foundry", "Steam Vents", "Arid Mesa", "Flooded Strand",
            "Malakir Rebirth // Malakir Mire", "Jwari Disruption // Jwari Ruins"
        ]
        
        for i in 0..<100 {
            let landName = landNames[i % landNames.count]
            deckComponents.append("1 \(landName)")
        }
        
        let largeDeckList = deckComponents.joined(separator: "\n")
        
        measure {
            let deckData = DeckParser.parseDeckList(largeDeckList)
            let landCards = deckData.mainDeck.filter { $0.isLand }
            XCTAssertEqual(landCards.count, 100, "Should correctly parse 100 lands")
        }
    }
    
    // MARK: - Regression Tests
    
    func testRegressionBugReportScenario() {
        // This is a scenario similar to the bug report where land count was incorrect
        let problematicDeckList = """
        Commander
        1 Some Commander
        
        Deck
        10 Plains
        5 Island
        3 Command Tower
        2 Ancient Tomb
        2 Strip Mine
        1 Wasteland
        1 Cabal Coffers
        1 Urborg, Tomb of Yawgmoth
        2 Thespian's Stage
        1 Inkmoth Nexus
        1 Cavern of Souls
        1 Boseiju, Who Shelters All
        1 Rishadan Port
        1 Malakir Rebirth // Malakir Mire
        60 Other Spells
        """
        
        let deckData = DeckParser.parseDeckList(problematicDeckList)
        let landCards = deckData.mainDeck.filter { $0.isLand }
        
        // Total should be: 10+5+3+2+2+1+1+1+2+1+1+1+1+1 = 32 lands
        XCTAssertEqual(landCards.count, 32, "Should correctly detect all 32 lands that were previously missed")
        
        // Verify specific problematic cards
        let problematicCards = ["Ancient Tomb", "Strip Mine", "Wasteland", "Cabal Coffers", 
                               "Urborg, Tomb of Yawgmoth", "Thespian's Stage", "Inkmoth Nexus",
                               "Cavern of Souls", "Boseiju, Who Shelters All", "Rishadan Port",
                               "Malakir Rebirth // Malakir Mire"]
        
        for cardName in problematicCards {
            let found = landCards.contains { $0.name == cardName }
            XCTAssertTrue(found, "Previously problematic card '\(cardName)' should now be detected as a land")
        }
    }
}