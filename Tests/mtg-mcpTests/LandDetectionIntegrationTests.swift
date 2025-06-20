import XCTest
@testable import MTGServices
@testable import Card

final class LandDetectionIntegrationTests: XCTestCase {
    
    func testHopeEstheimDeckLandCount() {
        // Test the specific deck that was having issues - Hope Estheim Commander deck
        let hopeDeckText = """
        Commander
        1 Hope Estheim

        Mainboard
        1 The Water Crystal
        1 The Wind Crystal
        1 Dispel
        1 Archivist of Oghma
        1 Esper Sentinel
        1 Rhystic Study
        1 Sunbeam Spellbomb
        1 The Gaffer
        1 Windfall
        1 Delney, Streetwise Lookout
        1 Steel of the Godhead
        1 Command Tower
        1 Hallowed Fountain
        1 Hengegate Pathway // Mistgate Pathway
        13 Island
        1 Mystic Gate
        12 Plains
        1 Sea of Clouds
        1 Tundra
        1 Aetherflux Reservoir
        1 Auriok Champion
        1 Authority of the Consuls
        1 Chaplain's Blessing
        1 Guide of Souls
        1 Heliod, Sun-Crowned
        1 Illusions of Grandeur
        1 Leyline of Hope
        1 Rest for the Weary
        1 Serra Ascendant
        1 Soul Warden
        1 Soul's Attendant
        1 Sunspring Expedition
        1 Suture Priest
        1 Tablet of the Guilds
        1 Voice of the Blessed
        1 Words of Worship
        1 Archive Trap
        1 Brain Freeze
        1 Bruvac the Grandiloquent
        1 Court of Cunning
        1 Fractured Sanity
        1 Maddening Cacophony
        1 Mindcrank
        1 Riverchurn Monument
        1 Tasha's Hideous Laughter
        1 Grand Abolisher
        1 Arcane Signet
        1 Smothering Tithe
        1 Sol Ring
        1 Will, Scion of Peace
        1 Elixir of Immortality
        1 Ajani, Strength of the Pride
        1 An Offer You Can't Refuse
        1 Cyclonic Rift
        1 Fierce Guardianship
        1 Grip of Amnesia
        1 Heliod's Intervention
        1 Honor the Fallen
        1 Lantern of the Lost
        1 Light of Hope
        1 Lucky Offering
        1 Pongify
        1 Rapid Hybridization
        1 Relic of Progenitus
        1 Soul-Guide Lantern
        1 Strix Serenade
        1 Swan Song
        1 Swords to Plowshares
        1 Thraben Charm
        1 Tormod's Crypt
        1 Morningtide
        1 Drannith Magistrate
        1 Grafdigger's Cage
        1 Rest in Peace
        1 Canoptek Scarab Swarm
        1 Voice of Victory
        """
        
        // Parse the deck
        let deckData = DeckParser.parseDeckList(hopeDeckText)
        
        // Extract all card names from the main deck
        let allCardNames = deckData.mainDeck.map { $0.name }
        
        // Count lands using our service
        let landCount = LandDetectionService.countLands(in: allCardNames)
        
        XCTAssertEqual(landCount, 31, "Expected 31 lands in Hope Estheim deck, got \(landCount)")
        
        // Test specific problematic card
        XCTAssertTrue(LandDetectionService.isLand("Hengegate Pathway // Mistgate Pathway"), 
                     "MDFC pathway should be detected as land")
        XCTAssertTrue(LandDetectionService.isLand("Hengegate Pathway"), 
                     "Individual pathway face should be detected as land")
        XCTAssertTrue(LandDetectionService.isLand("Mistgate Pathway"), 
                     "Individual pathway face should be detected as land")
    }
    
    func testMDFCLandParsing() {
        // Test that MDFC cards are parsed correctly and the individual faces are detected as lands
        let mdfcDeckText = """
        1 Hengegate Pathway // Mistgate Pathway
        1 Riverglide Pathway // Lavaglide Pathway
        1 Malakir Rebirth // Malakir Mire
        1 Lightning Bolt
        """
        
        let deckData = DeckParser.parseDeckList(mdfcDeckText)
        let allCardNames = deckData.mainDeck.map { $0.name }
        
        // Should detect 3 lands (2 pathway MDFCs + 1 spell//land MDFC)
        let landCount = LandDetectionService.countLands(in: allCardNames)
        XCTAssertEqual(landCount, 3, "Expected 3 MDFC lands, got \(landCount)")
        
        // Test individual detection
        XCTAssertTrue(LandDetectionService.isLand("Hengegate Pathway"))
        XCTAssertTrue(LandDetectionService.isLand("Riverglide Pathway"))
        XCTAssertTrue(LandDetectionService.isLand("Malakir Rebirth // Malakir Mire"))
        XCTAssertFalse(LandDetectionService.isLand("Lightning Bolt"))
    }
}