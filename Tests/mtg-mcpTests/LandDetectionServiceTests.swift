import XCTest
@testable import MTGServices

final class LandDetectionServiceTests: XCTestCase {
    
    // MARK: - Basic Land Tests
    
    func testBasicLandDetection() {
        let basicLands = [
            "Plains", "Island", "Swamp", "Mountain", "Forest", "Wastes"
        ]
        
        for land in basicLands {
            XCTAssertTrue(LandDetectionService.isLand(land), "\(land) should be detected as a land")
            XCTAssertEqual(LandDetectionService.getLandCategory(land), .basic, "\(land) should be categorized as basic")
        }
    }
    
    func testSnowBasicLands() {
        let snowLands = [
            "Snow-Covered Plains", "Snow-Covered Island", "Snow-Covered Swamp", 
            "Snow-Covered Mountain", "Snow-Covered Forest"
        ]
        
        for land in snowLands {
            XCTAssertTrue(LandDetectionService.isLand(land), "\(land) should be detected as a land")
            XCTAssertEqual(LandDetectionService.getLandCategory(land), .basic, "\(land) should be categorized as basic")
        }
    }
    
    // MARK: - Dual Land Tests
    
    func testShockLands() {
        let shockLands = [
            "Sacred Foundry", "Steam Vents", "Overgrown Tomb", "Watery Grave",
            "Godless Shrine", "Stomping Ground", "Breeding Pool", "Hallowed Fountain",
            "Blood Crypt", "Temple Garden"
        ]
        
        for land in shockLands {
            XCTAssertTrue(LandDetectionService.isLand(land), "\(land) should be detected as a land")
            XCTAssertEqual(LandDetectionService.getLandCategory(land), .shock, "\(land) should be categorized as shock")
        }
    }
    
    func testFetchLands() {
        let fetchLands = [
            "Arid Mesa", "Bloodstained Mire", "Flooded Strand", "Marsh Flats",
            "Misty Rainforest", "Polluted Delta", "Scalding Tarn", "Verdant Catacombs",
            "Windswept Heath", "Wooded Foothills", "Fabled Passage", "Evolving Wilds"
        ]
        
        for land in fetchLands {
            XCTAssertTrue(LandDetectionService.isLand(land), "\(land) should be detected as a land")
            XCTAssertEqual(LandDetectionService.getLandCategory(land), .fetch, "\(land) should be categorized as fetch")
        }
    }
    
    // MARK: - Utility Land Tests
    
    func testUtilityLands() {
        let utilityLands = [
            "Ancient Tomb", "Strip Mine", "Wasteland", "Cabal Coffers",
            "Urborg, Tomb of Yawgmoth", "Shizo, Death's Storehouse", "Thespian's Stage",
            "Dark Depths", "Inkmoth Nexus", "Boseiju, Who Shelters All", "Cavern of Souls",
            "Rishadan Port", "Mutavault", "Maze of Ith", "Academy Ruins"
        ]
        
        for land in utilityLands {
            XCTAssertTrue(LandDetectionService.isLand(land), "\(land) should be detected as a land")
            XCTAssertEqual(LandDetectionService.getLandCategory(land), .utility, "\(land) should be categorized as utility")
        }
    }
    
    // MARK: - Commander Lands Tests
    
    func testCommanderLands() {
        let commanderLands = [
            "Command Tower", "Path of Ancestry", "Exotic Orchard", "Reflecting Pool",
            "City of Brass", "Mana Confluence", "Grand Coliseum"
        ]
        
        for land in commanderLands {
            XCTAssertTrue(LandDetectionService.isLand(land), "\(land) should be detected as a land")
            // These are in SPECIAL_LANDS so should be detected as lands
        }
    }
    
    // MARK: - Modal Double-Faced Card Tests
    
    func testMDFCLands() {
        let mdfcLands = [
            "Malakir Rebirth // Malakir Mire",
            "Turntimber Symbiosis // Turntimber, Serpentine Wood", 
            "Ondu Inversion // Ondu Skyruins",
            "Emeria's Call // Emeria, Shattered Skyclave",
            "Sea Gate Restoration // Sea Gate, Reborn",
            "Jwari Disruption // Jwari Ruins"
        ]
        
        for land in mdfcLands {
            XCTAssertTrue(LandDetectionService.isLand(land), "\(land) should be detected as a land")
            XCTAssertEqual(LandDetectionService.getLandCategory(land), .mdfc, "\(land) should be categorized as MDFC")
        }
    }
    
    func testIsMDFCLand() {
        XCTAssertTrue(LandDetectionService.isMDFCLand("Malakir Rebirth // Malakir Mire"))
        XCTAssertTrue(LandDetectionService.isMDFCLand("Jwari Disruption"))
        XCTAssertFalse(LandDetectionService.isMDFCLand("Lightning Bolt"))
        XCTAssertFalse(LandDetectionService.isMDFCLand("Plains"))
    }
    
    // MARK: - Non-Land Tests
    
    func testNonLands() {
        let nonLands = [
            "Lightning Bolt", "Counterspell", "Sol Ring", "Llanowar Elves",
            "Black Lotus", "Ancestral Recall", "Time Walk", "Mox Pearl",
            "Jace, the Mind Sculptor", "Tarmogoyf", "Dark Confidant"
        ]
        
        for nonLand in nonLands {
            XCTAssertFalse(LandDetectionService.isLand(nonLand), "\(nonLand) should NOT be detected as a land")
            XCTAssertEqual(LandDetectionService.getLandCategory(nonLand), .none, "\(nonLand) should be categorized as none")
        }
    }
    
    // MARK: - Mana Color Tests
    
    func testBasicLandManaColors() {
        XCTAssertEqual(LandDetectionService.getManaColors("Plains"), ["W"])
        XCTAssertEqual(LandDetectionService.getManaColors("Island"), ["U"])
        XCTAssertEqual(LandDetectionService.getManaColors("Swamp"), ["B"])
        XCTAssertEqual(LandDetectionService.getManaColors("Mountain"), ["R"])
        XCTAssertEqual(LandDetectionService.getManaColors("Forest"), ["G"])
        XCTAssertEqual(LandDetectionService.getManaColors("Wastes"), ["C"])
    }
    
    func testFetchLandManaColors() {
        XCTAssertEqual(Set(LandDetectionService.getManaColors("Arid Mesa")), Set(["W", "R"]))
        XCTAssertEqual(Set(LandDetectionService.getManaColors("Misty Rainforest")), Set(["U", "G"]))
        XCTAssertEqual(Set(LandDetectionService.getManaColors("Fabled Passage")), Set(["W", "U", "B", "R", "G"]))
    }
    
    func testCommandTowerManaColors() {
        // Command Tower produces all colors in Commander
        XCTAssertEqual(Set(LandDetectionService.getManaColors("Command Tower")), Set(["W", "U", "B", "R", "G"]))
    }
    
    // MARK: - Deck Analysis Tests
    
    func testCountLandsInDeck() {
        let deckList = [
            "Plains", "Island", "Mountain", "Lightning Bolt", "Counterspell",
            "Command Tower", "Sol Ring", "Arid Mesa", "Tarmogoyf", "Ancient Tomb"
        ]
        
        let landCount = LandDetectionService.countLands(in: deckList)
        XCTAssertEqual(landCount, 6, "Should count 6 lands: Plains, Island, Mountain, Command Tower, Arid Mesa, Ancient Tomb")
    }
    
    func testAnalyzeLandComposition() {
        let deckList = [
            "Plains", "Plains", "Island", "Sacred Foundry", "Arid Mesa", 
            "Ancient Tomb", "Command Tower", "Lightning Bolt", "Counterspell",
            "Malakir Rebirth // Malakir Mire"
        ]
        
        let composition = LandDetectionService.analyzeLandComposition(deckList)
        
        XCTAssertEqual(composition.totalLands, 7)
        XCTAssertEqual(composition.basicLands, 3) // 2 Plains + 1 Island
        XCTAssertEqual(composition.shockLands, 1) // Sacred Foundry
        XCTAssertEqual(composition.fetchLands, 1) // Arid Mesa
        XCTAssertEqual(composition.utilityLands, 1) // Ancient Tomb
        XCTAssertEqual(composition.mdfcLands, 1) // Malakir Rebirth
        XCTAssertEqual(composition.otherLands, 1) // Command Tower (not in special categories)
    }
    
    func testBatchLandDetection() {
        let cardNames = [
            "Plains", "Lightning Bolt", "Command Tower", "Sol Ring", "Ancient Tomb"
        ]
        
        let results = LandDetectionService.detectLandsInDeck(cardNames)
        
        XCTAssertEqual(results["Plains"], true)
        XCTAssertEqual(results["Lightning Bolt"], false)
        XCTAssertEqual(results["Command Tower"], true)
        XCTAssertEqual(results["Sol Ring"], false)
        XCTAssertEqual(results["Ancient Tomb"], true)
    }
    
    // MARK: - Edge Cases and Pattern Matching
    
    func testCaseInsensitiveDetection() {
        XCTAssertTrue(LandDetectionService.isLand("plains"))
        XCTAssertTrue(LandDetectionService.isLand("ISLAND"))
        XCTAssertTrue(LandDetectionService.isLand("Command tower"))
        XCTAssertTrue(LandDetectionService.isLand("ANCIENT TOMB"))
    }
    
    func testWhitespaceHandling() {
        XCTAssertTrue(LandDetectionService.isLand("  Plains  "))
        XCTAssertTrue(LandDetectionService.isLand("\tCommand Tower\n"))
        XCTAssertEqual(LandDetectionService.getLandCategory("  Ancient Tomb  "), .utility)
    }
    
    func testEmptyAndInvalidInputs() {
        XCTAssertFalse(LandDetectionService.isLand(""))
        XCTAssertFalse(LandDetectionService.isLand("   "))
        XCTAssertEqual(LandDetectionService.getLandCategory(""), .none)
        XCTAssertEqual(LandDetectionService.getManaColors("Unknown Card"), ["C"])
    }
    
    // MARK: - Problem Cards from Bug Report
    
    func testProblematicLands() {
        // These are the types of lands that were being missed
        let problematicLands = [
            "Strip Mine", "Wasteland", "Ancient Tomb", "Cabal Coffers",
            "Urborg, Tomb of Yawgmoth", "Shizo, Death's Storehouse",
            "Thespian's Stage", "Inkmoth Nexus", "Cavern of Souls",
            "Malakir Rebirth // Malakir Mire", "Jwari Disruption // Jwari Ruins"
        ]
        
        for land in problematicLands {
            XCTAssertTrue(LandDetectionService.isLand(land), "\(land) should be detected as a land (was previously missed)")
        }
    }
    
    func testLegendaryLands() {
        let legendaryLands = [
            "Urborg, Tomb of Yawgmoth", "Cabal Coffers", "Shizo, Death's Storehouse",
            "Eiganjo Castle", "Minamo, School at Water's Edge", "Okina, Temple to the Grandfathers"
        ]
        
        for land in legendaryLands {
            XCTAssertTrue(LandDetectionService.isLand(land), "\(land) legendary land should be detected")
        }
    }
    
    // MARK: - Performance Tests
    
    func testPerformance() {
        let testCards = Array(repeating: ["Plains", "Lightning Bolt", "Command Tower", "Ancient Tomb"], count: 250).flatMap { $0 }
        
        measure {
            for card in testCards {
                _ = LandDetectionService.isLand(card)
            }
        }
    }
}