import XCTest
@testable import mtg_mcp
@testable import MTGModels
@testable import MTGServices

final class CardModelTests: XCTestCase {
    
    func testCardCreation() {
        let card = Card(
            name: "Lightning Bolt",
            manaCostString: "{R}",
            rarity: .common,
            typeLine: "Instant",
            oracleText: "Lightning Bolt deals 3 damage to any target."
        )
        
        XCTAssertEqual(card.name, "Lightning Bolt")
        XCTAssertEqual(card.manaCostString, "{R}")
        XCTAssertEqual(card.rarity, .common)
        XCTAssertEqual(card.typeLine, "Instant")
        XCTAssertEqual(card.oracleText, "Lightning Bolt deals 3 damage to any target.")
        XCTAssertEqual(card.cmc, 1)
    }
    
    func testManaCostParsing() {
        let manaCost = ManaCost(from: "{2}{R}{R}")
        
        XCTAssertEqual(manaCost.red, 2)
        XCTAssertEqual(manaCost.colorless, 2)
        XCTAssertEqual(manaCost.cmc(), 4)
        XCTAssertEqual(manaCost.colorCount, 1) // Only red
        XCTAssertTrue(manaCost.isMonoColored)
    }
    
    func testMulticolorManaCost() {
        let manaCost = ManaCost(from: "{W}{U}{B}{R}{G}")
        
        XCTAssertEqual(manaCost.white, 1)
        XCTAssertEqual(manaCost.blue, 1)
        XCTAssertEqual(manaCost.black, 1)
        XCTAssertEqual(manaCost.red, 1)
        XCTAssertEqual(manaCost.green, 1)
        XCTAssertEqual(manaCost.cmc(), 5)
        XCTAssertEqual(manaCost.colorCount, 5)
        XCTAssertTrue(manaCost.isMultiColored)
    }
    
    func testColorlessManaCost() {
        let manaCost = ManaCost(from: "{7}")
        
        XCTAssertEqual(manaCost.colorless, 7)
        XCTAssertEqual(manaCost.cmc(), 7)
        XCTAssertEqual(manaCost.colorCount, 0)
        XCTAssertTrue(manaCost.isColorless)
    }
    
    func testCardKindBasics() {
        var cardKind = CardKind()
        cardKind.isCreature = true
        cardKind.isLand = false
        
        XCTAssertTrue(cardKind.isCreature)
        XCTAssertFalse(cardKind.isLand)
        XCTAssertTrue(cardKind.isNonland())
        XCTAssertFalse(cardKind.isManaProducer())
    }
    
    func testManaProducerCards() {
        var landKind = CardKind()
        landKind.isLand = true
        XCTAssertTrue(landKind.isManaProducer())
        
        var manaRockKind = CardKind()
        manaRockKind.isManaRock = true
        XCTAssertTrue(manaRockKind.isManaProducer())
        
        var manaDorkKind = CardKind()
        manaDorkKind.isManaDork = true
        XCTAssertTrue(manaDorkKind.isManaProducer())
    }
    
    func testRarityParsing() {
        XCTAssertEqual(Rarity(from: "common"), .common)
        XCTAssertEqual(Rarity(from: "uncommon"), .uncommon)
        XCTAssertEqual(Rarity(from: "rare"), .rare)
        XCTAssertEqual(Rarity(from: "mythic"), .mythic)
        XCTAssertEqual(Rarity(from: "mythic_rare"), .mythic)
        XCTAssertEqual(Rarity(from: "invalid"), .unknown)
    }
    
    func testCardFactoryMethods() {
        let basicLand = Card.basicLand(name: "Island")
        XCTAssertEqual(basicLand.name, "Island")
        XCTAssertTrue(basicLand.kind.isLand)
        XCTAssertTrue(basicLand.kind.isBasicLand)
        
        let creature = Card.creature(name: "Grizzly Bears", manaCost: "{1}{G}", power: "2", toughness: "2")
        XCTAssertEqual(creature.name, "Grizzly Bears")
        XCTAssertTrue(creature.kind.isCreature)
        XCTAssertEqual(creature.power, "2")
        XCTAssertEqual(creature.toughness, "2")
        
        let instant = Card.instant(name: "Lightning Bolt", manaCost: "{R}")
        XCTAssertEqual(instant.name, "Lightning Bolt")
        XCTAssertTrue(instant.kind.isInstant)
    }
    
    func testCardDescription() {
        let card = Card(
            name: "Lightning Bolt",
            manaCostString: "{R}",
            typeLine: "Instant"
        )
        
        let description = card.description
        XCTAssertTrue(description.contains("Lightning Bolt"))
        XCTAssertTrue(description.contains("{R}"))
        XCTAssertTrue(description.contains("Instant"))
        XCTAssertTrue(description.contains("CMC: 1"))
    }
}