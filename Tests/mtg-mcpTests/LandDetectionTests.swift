import XCTest
@testable import MTGServices

final class LandDetectionTests: XCTestCase {
    
    func testBasicLandDetection() {
        // Test basic lands
        XCTAssertTrue(LandDetectionService.isLand("Plains"))
        XCTAssertTrue(LandDetectionService.isLand("Island"))
        XCTAssertTrue(LandDetectionService.isLand("Swamp"))
        XCTAssertTrue(LandDetectionService.isLand("Mountain"))
        XCTAssertTrue(LandDetectionService.isLand("Forest"))
        XCTAssertTrue(LandDetectionService.isLand("Wastes"))
        
        // Test snow-covered basics
        XCTAssertTrue(LandDetectionService.isLand("Snow-Covered Plains"))
        XCTAssertTrue(LandDetectionService.isLand("Snow-Covered Island"))
        XCTAssertTrue(LandDetectionService.isLand("Snow-Covered Swamp"))
        XCTAssertTrue(LandDetectionService.isLand("Snow-Covered Mountain"))
        XCTAssertTrue(LandDetectionService.isLand("Snow-Covered Forest"))
    }
    
    func testSpecialLandDetection() {
        // Test command zone lands
        XCTAssertTrue(LandDetectionService.isLand("Command Tower"))
        XCTAssertTrue(LandDetectionService.isLand("Path of Ancestry"))
        XCTAssertTrue(LandDetectionService.isLand("Exotic Orchard"))
        
        // Test utility lands
        XCTAssertTrue(LandDetectionService.isLand("Ancient Tomb"))
        XCTAssertTrue(LandDetectionService.isLand("Strip Mine"))
        XCTAssertTrue(LandDetectionService.isLand("Wasteland"))
        XCTAssertTrue(LandDetectionService.isLand("Cabal Coffers"))
        
        // Test fetch lands
        XCTAssertTrue(LandDetectionService.isLand("Flooded Strand"))
        XCTAssertTrue(LandDetectionService.isLand("Polluted Delta"))
        XCTAssertTrue(LandDetectionService.isLand("Windswept Heath"))
        XCTAssertTrue(LandDetectionService.isLand("Fabled Passage"))
    }
    
    func testMDFCLandDetection() {
        // Test full MDFC names with land backs
        XCTAssertTrue(LandDetectionService.isLand("Malakir Rebirth // Malakir Mire"))
        XCTAssertTrue(LandDetectionService.isLand("Turntimber Symbiosis // Turntimber, Serpentine Wood"))
        XCTAssertTrue(LandDetectionService.isLand("Spikefield Hazard // Spikefield Cave"))
        
        // Test pathway cycle (land // land)
        XCTAssertTrue(LandDetectionService.isLand("Hengegate Pathway // Mistgate Pathway"))
        XCTAssertTrue(LandDetectionService.isLand("Riverglide Pathway // Lavaglide Pathway"))
        XCTAssertTrue(LandDetectionService.isLand("Cragcrown Pathway // Timbercrown Pathway"))
        
        // Test individual MDFC land faces
        XCTAssertTrue(LandDetectionService.isLand("Malakir Mire"))
        XCTAssertTrue(LandDetectionService.isLand("Turntimber, Serpentine Wood"))
        XCTAssertTrue(LandDetectionService.isLand("Spikefield Cave"))
        
        // Test individual pathway faces
        XCTAssertTrue(LandDetectionService.isLand("Hengegate Pathway"))
        XCTAssertTrue(LandDetectionService.isLand("Mistgate Pathway"))
        XCTAssertTrue(LandDetectionService.isLand("Riverglide Pathway"))
        XCTAssertTrue(LandDetectionService.isLand("Lavaglide Pathway"))
    }
    
    func testShockLandDetection() {
        XCTAssertTrue(LandDetectionService.isLand("Hallowed Fountain"))
        XCTAssertTrue(LandDetectionService.isLand("Sacred Foundry"))
        XCTAssertTrue(LandDetectionService.isLand("Steam Vents"))
        XCTAssertTrue(LandDetectionService.isLand("Overgrown Tomb"))
        XCTAssertTrue(LandDetectionService.isLand("Watery Grave"))
        XCTAssertTrue(LandDetectionService.isLand("Godless Shrine"))
        XCTAssertTrue(LandDetectionService.isLand("Stomping Ground"))
        XCTAssertTrue(LandDetectionService.isLand("Breeding Pool"))
        XCTAssertTrue(LandDetectionService.isLand("Blood Crypt"))
        XCTAssertTrue(LandDetectionService.isLand("Temple Garden"))
    }
    
    func testOtherLandDetection() {
        // Test other notable lands from the deck list
        XCTAssertTrue(LandDetectionService.isLand("Mystic Gate"))
        XCTAssertTrue(LandDetectionService.isLand("Sea of Clouds"))
        XCTAssertTrue(LandDetectionService.isLand("Tundra"))
    }
    
    func testNonLandDetection() {
        // Test non-land cards
        XCTAssertFalse(LandDetectionService.isLand("Lightning Bolt"))
        XCTAssertFalse(LandDetectionService.isLand("Sol Ring"))
        XCTAssertFalse(LandDetectionService.isLand("Counterspell"))
        XCTAssertFalse(LandDetectionService.isLand("Birds of Paradise"))
        XCTAssertFalse(LandDetectionService.isLand("Jace, the Mind Sculptor"))
        XCTAssertFalse(LandDetectionService.isLand("Rhystic Study"))
        XCTAssertFalse(LandDetectionService.isLand("Hope Estheim"))
    }
    
    func testDeckListLandCounting() {
        // Test the specific deck that was having issues
        let hopeDeckList = [
            "Hope Estheim", // Commander
            "The Water Crystal", "The Wind Crystal", "Dispel", "Archivist of Oghma",
            "Esper Sentinel", "Rhystic Study", "Sunbeam Spellbomb", "The Gaffer",
            "Windfall", "Delney, Streetwise Lookout", "Steel of the Godhead",
            // Lands start here (31 total)
            "Command Tower", "Hallowed Fountain", "Hengegate Pathway // Mistgate Pathway",
            "Island", "Island", "Island", "Island", "Island", "Island", "Island",
            "Island", "Island", "Island", "Island", "Island", "Island", // 13 Islands
            "Mystic Gate",
            "Plains", "Plains", "Plains", "Plains", "Plains", "Plains", "Plains",
            "Plains", "Plains", "Plains", "Plains", "Plains", // 12 Plains
            "Sea of Clouds", "Tundra",
            // More non-lands
            "Aetherflux Reservoir", "Auriok Champion", "Authority of the Consuls",
            "Chaplain's Blessing", "Guide of Souls", "Heliod, Sun-Crowned"
        ]
        
        let landCount = LandDetectionService.countLands(in: hopeDeckList)
        XCTAssertEqual(landCount, 31, "Expected 31 lands in Hope Estheim deck")
    }
    
    func testIndividualLandsFromDeck() {
        // Test each individual land from the problem deck
        XCTAssertTrue(LandDetectionService.isLand("Command Tower"))
        XCTAssertTrue(LandDetectionService.isLand("Hallowed Fountain"))
        XCTAssertTrue(LandDetectionService.isLand("Hengegate Pathway // Mistgate Pathway"))
        XCTAssertTrue(LandDetectionService.isLand("Island"))
        XCTAssertTrue(LandDetectionService.isLand("Mystic Gate"))
        XCTAssertTrue(LandDetectionService.isLand("Plains"))
        XCTAssertTrue(LandDetectionService.isLand("Sea of Clouds")) 
        XCTAssertTrue(LandDetectionService.isLand("Tundra"))
    }
    
    func testLandCategories() {
        // Test land category classification
        XCTAssertEqual(LandDetectionService.getLandCategory("Plains"), .basic)
        XCTAssertEqual(LandDetectionService.getLandCategory("Hallowed Fountain"), .shock)
        XCTAssertEqual(LandDetectionService.getLandCategory("Flooded Strand"), .fetch)
        XCTAssertEqual(LandDetectionService.getLandCategory("Hengegate Pathway // Mistgate Pathway"), .mdfc)
        XCTAssertEqual(LandDetectionService.getLandCategory("Ancient Tomb"), .utility)
        XCTAssertEqual(LandDetectionService.getLandCategory("Command Tower"), .other)
    }
    
    func testManaColorProduction() {
        // Test mana color production
        XCTAssertEqual(LandDetectionService.getManaColors("Plains"), ["W"])
        XCTAssertEqual(LandDetectionService.getManaColors("Island"), ["U"])
        XCTAssertEqual(Set(LandDetectionService.getManaColors("Command Tower")), Set(["W", "U", "B", "R", "G"]))
        XCTAssertEqual(Set(LandDetectionService.getManaColors("Hengegate Pathway")), Set(["W", "U"]))
        XCTAssertEqual(Set(LandDetectionService.getManaColors("Mistgate Pathway")), Set(["W", "U"]))
    }
    
    func testBatchLandDetection() {
        let cards = ["Plains", "Lightning Bolt", "Command Tower", "Sol Ring", "Island"]
        let results = LandDetectionService.detectLandsInDeck(cards)
        
        XCTAssertEqual(results["Plains"], true)
        XCTAssertEqual(results["Lightning Bolt"], false)
        XCTAssertEqual(results["Command Tower"], true)
        XCTAssertEqual(results["Sol Ring"], false)
        XCTAssertEqual(results["Island"], true)
    }
    
    func testLandCompositionAnalysis() {
        let deckList = [
            "Plains", "Plains", "Island", "Island",  // 4 basic lands
            "Hallowed Fountain", "Sacred Foundry",   // 2 shock lands
            "Flooded Strand", "Windswept Heath",     // 2 fetch lands
            "Ancient Tomb",                          // 1 utility land
            "Hengegate Pathway // Mistgate Pathway", // 1 MDFC land
            "Command Tower",                         // 1 other land
            "Lightning Bolt", "Sol Ring"             // 2 non-lands
        ]
        
        let composition = LandDetectionService.analyzeLandComposition(deckList)
        
        XCTAssertEqual(composition.totalLands, 11)
        XCTAssertEqual(composition.basicLands, 4)
        XCTAssertEqual(composition.shockLands, 2)
        XCTAssertEqual(composition.fetchLands, 2)
        XCTAssertEqual(composition.utilityLands, 1)
        XCTAssertEqual(composition.mdfcLands, 1)
        XCTAssertEqual(composition.otherLands, 1)
    }
    
    func testWhitespaceHandling() {
        // Test that whitespace doesn't affect detection
        XCTAssertTrue(LandDetectionService.isLand("  Plains  "))
        XCTAssertTrue(LandDetectionService.isLand("\tIsland\t"))
        XCTAssertTrue(LandDetectionService.isLand("Command Tower "))
        XCTAssertTrue(LandDetectionService.isLand(" Hengegate Pathway // Mistgate Pathway "))
    }
}