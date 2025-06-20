import Testing
@testable import Card

/// Tests for the CardKind struct
struct CardKindTests {
    
    // MARK: - Initialization Tests
    
    /// Test default initialization
    @Test func testDefaultInitialization() {
        let cardKind = CardKind()
        
        // All properties should be false by default
        #expect(!cardKind.isLand)
        #expect(!cardKind.isCreature)
        #expect(!cardKind.isSpell)
        #expect(!cardKind.isEnchantment)
        #expect(!cardKind.isInstant)
        #expect(!cardKind.isPlaneswalker)
        #expect(!cardKind.isSorcery)
        #expect(!cardKind.isArtifact)
        #expect(!cardKind.isUnknown)
        
        #expect(!cardKind.isBasicLand)
        #expect(!cardKind.isBattleLand)
        #expect(!cardKind.isTapLand)
        #expect(!cardKind.isCheckLand)
        #expect(!cardKind.isShockLand)
        #expect(!cardKind.isOtherLand)
        #expect(!cardKind.isForcedLand)
    }
    
    /// Test initialization with main card types
    @Test func testMainCardTypeInitialization() {
        let cardKind = CardKind(
            isLand: false,
            isCreature: true,
            isSpell: true,
            isEnchantment: false,
            isInstant: true,
            isPlaneswalker: false,
            isSorcery: false,
            isArtifact: false,
            isUnknown: false
        )
        
        #expect(!cardKind.isLand)
        #expect(cardKind.isCreature)
        #expect(cardKind.isSpell)
        #expect(!cardKind.isEnchantment)
        #expect(cardKind.isInstant)
        #expect(!cardKind.isPlaneswalker)
        #expect(!cardKind.isSorcery)
        #expect(!cardKind.isArtifact)
        #expect(!cardKind.isUnknown)
    }
    
    /// Test initialization with land types
    @Test func testLandTypeInitialization() {
        let cardKind = CardKind(
            isBasicLand: true,
            isBattleLand: false,
            isTapLand: false,
            isCheckLand: false,
            isShockLand: false,
            isOtherLand: false,
            isForcedLand: false
        )
        
        // isLand should be automatically set to true
        #expect(cardKind.isLand)
        #expect(cardKind.isBasicLand)
        #expect(!cardKind.isBattleLand)
        #expect(!cardKind.isTapLand)
        #expect(!cardKind.isCheckLand)
        #expect(!cardKind.isShockLand)
        #expect(!cardKind.isOtherLand)
        #expect(!cardKind.isForcedLand)
    }
    
    // MARK: - Method Tests
    
    /// Test setUnknown method
    @Test func testSetUnknown() {
        var cardKind = CardKind(
            isLand: true,
            isCreature: true,
            isSpell: true,
            isEnchantment: true,
            isInstant: true,
            isPlaneswalker: true,
            isSorcery: true,
            isArtifact: true,
            isUnknown: false
        )
        
        cardKind.setUnknown()
        
        #expect(!cardKind.isLand)
        #expect(!cardKind.isCreature)
        #expect(!cardKind.isSpell)
        #expect(!cardKind.isEnchantment)
        #expect(!cardKind.isInstant)
        #expect(!cardKind.isPlaneswalker)
        #expect(!cardKind.isSorcery)
        #expect(!cardKind.isArtifact)
        #expect(cardKind.isUnknown)
    }
    
    /// Test isLandCard method
    @Test func testIsLandCard() {
        let land = CardKind(isLand: true)
        let creature = CardKind(isCreature: true)
        
        #expect(land.isLandCard())
        #expect(!creature.isLandCard())
    }
    
    /// Test isNonland method
    @Test func testIsNonland() {
        let land = CardKind(isLand: true)
        let creature = CardKind(isCreature: true)
        
        #expect(!land.isNonland())
        #expect(creature.isNonland())
    }
    
    /// Test isNonlandPermanent method
    @Test func testIsNonlandPermanent() {
        let land = CardKind(isLand: true)
        let creature = CardKind(isCreature: true)
        let instant = CardKind(isInstant: true)
        let artifact = CardKind(isArtifact: true)
        let enchantment = CardKind(isEnchantment: true)
        let planeswalker = CardKind(isPlaneswalker: true)
        
        #expect(!land.isNonlandPermanent())
        #expect(creature.isNonlandPermanent())
        #expect(!instant.isNonlandPermanent())
        #expect(artifact.isNonlandPermanent())
        #expect(enchantment.isNonlandPermanent())
        #expect(planeswalker.isNonlandPermanent())
    }
    
    /// Test isInstantOrSorcery method
    @Test func testIsInstantOrSorcery() {
        let instant = CardKind(isInstant: true)
        let sorcery = CardKind(isSorcery: true)
        let creature = CardKind(isCreature: true)
        
        #expect(instant.isInstantOrSorcery())
        #expect(sorcery.isInstantOrSorcery())
        #expect(!creature.isInstantOrSorcery())
    }
    
    /// Test hasLandType method
    @Test func testHasLandType() {
        let noLandType = CardKind(isLand: true)
        let basicLand = CardKind(isBasicLand: true)
        let tapLand = CardKind(isTapLand: true)
        
        #expect(!noLandType.hasLandType())
        #expect(basicLand.hasLandType())
        #expect(tapLand.hasLandType())
    }
    
    /// Test landCategory method
    @Test func testLandCategory() {
        let notLand = CardKind(isCreature: true)
        let basicLand = CardKind(isBasicLand: true)
        let tapLand = CardKind(isTapLand: true)
        let checkLand = CardKind(isCheckLand: true)
        let shockLand = CardKind(isShockLand: true)
        let forcedLand = CardKind(isForcedLand: true)
        let otherLand = CardKind(isOtherLand: true)
        let unspecifiedLand = CardKind(isLand: true)
        
        #expect(notLand.landCategory() == nil)
        #expect(basicLand.landCategory() == "Basic Land")
        #expect(tapLand.landCategory() == "Tap Land")
        #expect(checkLand.landCategory() == "Check Land")
        #expect(shockLand.landCategory() == "Shock Land")
        #expect(forcedLand.landCategory() == "Forced Land")
        #expect(otherLand.landCategory() == "Other Land")
        #expect(unspecifiedLand.landCategory() == "Unspecified Land")
    }
    
    /// Test typeList method
    @Test func testTypeList() {
        let emptyCard = CardKind()
        #expect(emptyCard.typeList().isEmpty)
        
        let creature = CardKind(isCreature: true)
        #expect(creature.typeList().count == 1)
        #expect(creature.typeList().contains("Creature"))
        
        let creatureArtifact = CardKind(isCreature: true, isArtifact: true)
        #expect(creatureArtifact.typeList().count == 2)
        #expect(creatureArtifact.typeList().contains("Creature"))
        #expect(creatureArtifact.typeList().contains("Artifact"))
    }
    
    // MARK: - Protocol Conformance Tests
    
    /// Test Equatable conformance
    @Test func testEquatable() {
        let creatureA = CardKind(isCreature: true)
        let creatureB = CardKind(isCreature: true)
        let land = CardKind(isLand: true)
        
        #expect(creatureA == creatureB)
        #expect(creatureA != land)
    }
    
    ///// Test Hashable conformance
    //@Test func testHashable() {
    //    let creature = CardKind(isCreature: true)
    //    let land = CardKind(isLand: true)
    //    
    //    var cardSet = Set<CardKind>()
    //    cardSet.insert(creature)
    //    cardSet.insert(land)
    //    cardSet.insert(creature) // Duplicate
    //    
    //    #expect(cardSet.count == 2)
    //}
    
    /// Test CustomStringConvertible conformance
    @Test func testDescription() {
        let emptyCard = CardKind()
        #expect(emptyCard.description == "Unknown")
        
        let creature = CardKind(isCreature: true)
        #expect(creature.description == "Creature")
        
        let creatureArtifact = CardKind(isCreature: true, isArtifact: true)
        #expect(creatureArtifact.description == "Creature Artifact" || creatureArtifact.description == "Artifact Creature")
        
        let allTypes = CardKind(
            isLand: true,
            isCreature: true,
            isSpell: true,
            isEnchantment: true,
            isInstant: true,
            isPlaneswalker: true,
            isSorcery: true,
            isArtifact: true
        )
        #expect(allTypes.description.contains("Land"))
        #expect(allTypes.description.contains("Creature"))
        #expect(allTypes.description.contains("Spell"))
        #expect(allTypes.description.contains("Enchantment"))
        #expect(allTypes.description.contains("Instant"))
        #expect(allTypes.description.contains("Planeswalker"))
        #expect(allTypes.description.contains("Sorcery"))
        #expect(allTypes.description.contains("Artifact"))
    }
    
    // MARK: - Integration Tests
    
    /// Test creation of common Magic card types
    @Test func testCommonMagicCardTypes() {
        // Basic land
        let plains = CardKind(isBasicLand: true)
        #expect(plains.isLand)
        #expect(plains.isBasicLand)
        #expect(plains.landCategory() == "Basic Land")
        
        // Creature
        let goblin = CardKind(isCreature: true)
        #expect(goblin.isCreature)
        #expect(goblin.isNonland())
        #expect(goblin.isNonlandPermanent())
        #expect(!goblin.isInstantOrSorcery())
        
        // Instant
        let counterspell = CardKind(isSpell: true, isInstant: true)
        #expect(counterspell.isInstant)
        #expect(counterspell.isSpell)
        #expect(counterspell.isInstantOrSorcery())
        #expect(!counterspell.isNonlandPermanent())
        
        // Artifact creature
        let golem = CardKind(isCreature: true, isArtifact: true)
        #expect(golem.isCreature)
        #expect(golem.isArtifact)
        #expect(golem.isNonlandPermanent())
        #expect(golem.typeList().count == 2)
        
        // Shock land
        let shockLand = CardKind(isShockLand: true)
        #expect(shockLand.isLand)
        #expect(shockLand.isShockLand)
        #expect(shockLand.landCategory() == "Shock Land")
    }
}
