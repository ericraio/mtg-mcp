//import Testing
//@testable import Card
//
///// Tests for the ManaCost struct
//struct ManaCostTests {
//    
//  
//    // MARK: - Initialization Tests
//    
//    /// Test basic initialization with default values
//    @Test func testDefaultInitialization() {
//        let cost = ManaCost()
//        
//        #expect(cost.red == 0)
//        #expect(cost.green == 0)
//        #expect(cost.black == 0)
//        #expect(cost.blue == 0)
//        #expect(cost.white == 0)
//        #expect(cost.colorless == 0)
//        #expect(cost.bits == 0)
//        #expect(cost.splitColors.isEmpty)
//    }
//    
//    /// Test initialization with specific color values
//    @Test func testColorInitialization() {
//        let cost = ManaCost(white: 1, blue: 3, black: 0, red: 2, green: 1, colorless: 2)
//        
//        #expect(cost.red == 2)
//        #expect(cost.green == 1)
//        #expect(cost.black == 0)
//        #expect(cost.blue == 3)
//        #expect(cost.white == 1)
//        #expect(cost.colorless == 2)
//        
//        // Bits should be set for all non-zero colors
//        #expect((cost.bits & ManaCost.redBit) != 0)
//        #expect((cost.bits & ManaCost.greenBit) != 0)
//        #expect((cost.bits & ManaCost.blackBit) == 0)
//        #expect((cost.bits & ManaCost.blueBit) != 0)
//        #expect((cost.bits & ManaCost.whiteBit) != 0)
//        #expect((cost.bits & ManaCost.colorlessBit) != 0)
//    }
//    
//    /// Test static factory method with WUBRG order
//    @Test func testFromColorCountsWUBRG() {
//        let cost = ManaCost.fromColorCounts(white: 1, blue: 3, black: 0, red: 2, green: 1, colorless: 2)
//        
//        #expect(cost.red == 2)
//        #expect(cost.green == 1)
//        #expect(cost.black == 0)
//        #expect(cost.blue == 3)
//        #expect(cost.white == 1)
//        #expect(cost.colorless == 2)
//    }
//    
//    /// Test setting color counts
//    @Test func testSetColorCounts() {
//        var cost = ManaCost()
//        cost.setColorCounts(
//            white: 2,
//            blue: 0,
//            black: 3,
//            red: 1,
//            green: 2, 
//            colorless: 1
//        )
//        
//        #expect(cost.red == 1)
//        #expect(cost.green == 2)
//        #expect(cost.black == 3)
//        #expect(cost.blue == 0)
//        #expect(cost.white == 2)
//        #expect(cost.colorless == 1)
//        
//        // Check bits were updated
//        #expect((cost.bits & ManaCost.redBit) != 0)
//        #expect((cost.bits & ManaCost.greenBit) != 0)
//        #expect((cost.bits & ManaCost.blackBit) != 0)
//        #expect((cost.bits & ManaCost.blueBit) == 0)
//        #expect((cost.bits & ManaCost.whiteBit) != 0)
//        #expect((cost.bits & ManaCost.colorlessBit) != 0)
//    }
//    
//    // MARK: - CMC Tests
//    
//    /// Test CMC calculation for simple mana costs
//    @Test func testCMCSimple() {
//        let cost = ManaCost(white: 2, blue: 0, black: 0, red: 1, green: 1, colorless: 3)
//        #expect(cost.cmc() == 7)
//    }
//    
//    /// Test CMC calculation for costs with split colors
//    @Test func testCMCWithSplitColors() {
//        var cost = ManaCost(white: 0, blue: 0, black: 1, red: 1, green: 1, colorless: 1)
//        
//        // Add 2 split colors
//        var redGreen = ManaColor()
//        redGreen.isRed = true
//        redGreen.isGreen = true
//        
//        var blackWhite = ManaColor()
//        blackWhite.isBlack = true
//        blackWhite.isWhite = true
//        
//        cost.splitColors = [redGreen, blackWhite]
//        
//        // Total CMC should be 4 - 2 = 2
//        #expect(cost.cmc() == 2)
//    }
//    
//    // MARK: - Bit Manipulation Tests
//    
//    /// Test bit manipulation for color detection
//    @Test func testBitManipulation() {
//        var cost = ManaCost()
//        
//        // Start with no colors
//        #expect(cost.bits == 0)
//        
//        // Add red
//        cost.red = 1
//        cost.updateBits()
//        #expect((cost.bits & ManaCost.redBit) != 0)
//        
//        // Add multiple red (should still only set one bit)
//        cost.red = 3
//        cost.updateBits()
//        #expect((cost.bits & ManaCost.redBit) != 0)
//        
//        // Set all colors
//        cost.setColorCounts(
//            white: 1,
//            blue: 1,
//            black: 1,
//            red: 1,
//            green: 1,
//            colorless: 1
//        )
//        let allBits = ManaCost.redBit | ManaCost.greenBit | ManaCost.blackBit | 
//                       ManaCost.blueBit | ManaCost.whiteBit | ManaCost.colorlessBit
//        #expect(cost.bits == allBits)
//    }
//    
//    // MARK: - String Parsing Tests
//    
//    /// Test parsing a simple mana cost string
//    @Test func testParseSimpleMana() {
//        var cost = ManaCost()
//        cost.set(from: "{1}{W}{U}")
//        
//        #expect(cost.white == 1)
//        #expect(cost.blue == 1)
//        #expect(cost.colorless == 1)
//        #expect(cost.cmc() == 3)
//    }
//    
//    /// Test parsing a complex mana cost string
//    @Test func testParseComplexMana() {
//        var cost = ManaCost()
//        cost.set(from: "{2}{B}{B}{G/W}")
//        
//        #expect(cost.colorless == 2)
//        #expect(cost.black == 2)
//        #expect(cost.splitColors.count == 1)
//        
//        // The G/W should be recorded as a split color
//        if !cost.splitColors.isEmpty {
//            let splitColor = cost.splitColors[0]
//            #expect(splitColor.isGreen)
//            #expect(splitColor.isWhite)
//        }
//    }
//    
//    /// Test parsing a split card mana cost
//    @Test func testParseSplitCard() {
//        var cost = ManaCost()
//        let card = Card()
//        cost.card = card
//        cost.set(from: "{1}{R}//{2}{U}")
//        
//        // The card should now have both mana costs
//        #expect(card.allManaCosts.count == 2)
//        if card.allManaCosts.count >= 2 {
//            let firstCost = card.allManaCosts[0]
//            let secondCost = card.allManaCosts[1]
//            
//            #expect(firstCost.red == 1)
//            #expect(firstCost.colorless == 1)
//            
//            #expect(secondCost.blue == 1)
//            #expect(secondCost.colorless == 2)
//        }
//    }
//    
//    /// Test parsing hybrid mana
//    @Test func testParseHybridMana() {
//        var cost = ManaCost()
//        cost.set(from: "{R/W}{G/U}")
//        
//        #expect(cost.splitColors.count == 2)
//        
//        if cost.splitColors.count >= 2 {
//            let firstSplit = cost.splitColors[0]
//            let secondSplit = cost.splitColors[1]
//            
//            #expect(firstSplit.isRed)
//            #expect(firstSplit.isWhite)
//            
//            #expect(secondSplit.isGreen)
//            #expect(secondSplit.isBlue)
//        }
//    }
//    
//    /// Test parsing X costs
//    @Test func testParseXCost() {
//        var cost = ManaCost()
//        cost.set(from: "{X}{R}{R}")
//        
//        // X doesn't contribute to the color count directly
//        #expect(cost.red == 2)
//        #expect(cost.cmc() == 2)
//    }
//    
//    // MARK: - Card Integration Tests
//    
//    /// Test integration with the Card class
//    @Test func testCardIntegration() {
//        let card = Card()
//        var cost = ManaCost()
//        cost.card = card
//        
//        cost.set(from: "{2}{W}{W}")
//        
//        #expect(card.manaCost != nil)
//        #expect(card.manaCostString == "{2}{W}{W}")
//        #expect(card.turn == 4)  // Turn should be set to CMC
//        
//        if let cardCost = card.manaCost {
//            #expect(cardCost.white == 2)
//            #expect(cardCost.colorless == 2)
//            #expect(cardCost.cmc() == 4)
//        }
//    }
//    
//    /// Test turn calculation for zero cost cards
//    @Test func testZeroCostTurn() {
//        let card = Card()
//        var cost = ManaCost()
//        cost.card = card
//        
//        cost.set(from: "{0}")
//        
//        #expect(card.turn == 1)  // Zero cost cards get turn 1
//    }
//    
//    // MARK: - Utility Function Tests
//    
//    /// Test isColorless function
//    @Test func testIsColorless() {
//        #expect(ManaCost.isColorless("1"))
//        #expect(ManaCost.isColorless("2"))
//        #expect(ManaCost.isColorless("X"))
//        #expect(!ManaCost.isColorless("R"))
//        #expect(!ManaCost.isColorless("1R"))
//        #expect(!ManaCost.isColorless("WU"))
//    }
//    
//    /// Test description generation
//    @Test func testDescription() {
//        let cost = ManaCost(
//            white: 1,
//            blue: 0,
//            black: 1,
//            red: 2,
//            green: 0,
//            colorless: 3
//        )
//        let description = cost.description
//        
//        #expect(description.contains("1W"))
//        #expect(description.contains("1B"))
//        #expect(description.contains("2R"))
//        #expect(description.contains("3C"))
//        #expect(description.contains("CMC: 7"))
//    }
//    
//    // MARK: - Edge Case Tests
//    
//    /// Test parsing empty mana cost
//    @Test func testEmptyManaCost() {
//        var cost = ManaCost()
//        cost.set(from: "")
//        
//        #expect(cost.red == 0)
//        #expect(cost.green == 0)
//        #expect(cost.black == 0)
//        #expect(cost.blue == 0)
//        #expect(cost.white == 0)
//        #expect(cost.colorless == 0)
//        #expect(cost.cmc() == 0)
//    }
//    
//    /// Test malformed mana cost strings
//    @Test func testMalformedManaCost() {
//        var cost = ManaCost()
//        cost.set(from: "{R{G}")  // Missing closing brace
//        
//        // Should handle the error gracefully
//        #expect(cost.cmc() >= 0)  // Just make sure it doesn't crash
//    }
//
//    /// Test basic mana cost creation
//    @Test func testManaCostCreation() {
//        let manaCost = ManaCost(white: 1, blue: 1, black: 0, red: 0, green: 0, colorless: 1)
//        
//        #expect(manaCost.colorless == 1)
//        #expect(manaCost.white == 1)
//        #expect(manaCost.blue == 1)
//        #expect(manaCost.black == 0)
//        #expect(manaCost.red == 0)
//        #expect(manaCost.green == 0)
//        #expect(manaCost.cmc() == 3)
//        #expect(manaCost.colorCount == 2)
//    }
//    
//    /// Test mana cost parsing from string
//    @Test func testManaCostParsing() {
//        var manaCost = ManaCost()
//        manaCost.set(from: "{1}{W}{U}")
//        
//        #expect(manaCost.colorless == 1)
//        #expect(manaCost.white == 1)
//        #expect(manaCost.blue == 1)
//        #expect(manaCost.black == 0)
//        #expect(manaCost.red == 0)
//        #expect(manaCost.green == 0)
//        #expect(manaCost.cmc() == 3)
//        #expect(manaCost.colorCount == 2)
//    }
//    
//    /// Test mana cost parsing with hybrid mana
//    @Test func testHybridManaParsing() {
//        var manaCost = ManaCost()
//        manaCost.set(from: "{W/U}{R/G}")
//        
//        #expect(manaCost.white == 1)
//        #expect(manaCost.blue == 1)
//        #expect(manaCost.black == 0)
//        #expect(manaCost.red == 1)
//        #expect(manaCost.green == 1)
//        #expect(manaCost.colorless == 0)
//        #expect(manaCost.colorCount == 4)
//    }
//    
//    /// Test mana cost parsing with Phyrexian mana
//    @Test func testPhyrexianManaParsing() {
//        var manaCost = ManaCost()
//        manaCost.set(from: "{2/R}{B/P}")
//        
//        #expect(manaCost.red == 1)
//        #expect(manaCost.black == 1)
//        #expect(manaCost.white == 0)
//        #expect(manaCost.blue == 0)
//        #expect(manaCost.green == 0)
//        #expect(manaCost.colorless == 0)
//        #expect(manaCost.colorCount == 2)
//    }
//    
//    /// Test mana cost parsing with a large generic cost
//    @Test func testLargeGenericCost() {
//        var manaCost = ManaCost()
//        manaCost.set(from: "{15}")
//        
//        #expect(manaCost.colorless == 15)
//        #expect(manaCost.white == 0)
//        #expect(manaCost.blue == 0)
//        #expect(manaCost.black == 0)
//        #expect(manaCost.red == 0)
//        #expect(manaCost.green == 0)
//        #expect(manaCost.cmc() == 15)
//        #expect(manaCost.colorCount == 0)
//    }
//    
//    /// Test mana cost string description
//    @Test func testManaCostDescription() {
//        let manaCost = ManaCost(white: 1, blue: 0, black: 0, red: 2, green: 0, colorless: 2)
//        let description = manaCost.description
//        
//        #expect(description.contains("1W"))
//        #expect(description.contains("2R"))
//        #expect(description.contains("2C"))
//        #expect(description.contains("CMC: 5"))
//    }
//    
//    /// Test mana cost helper properties
//    @Test func testManaCostProperties() {
//        let monoWhite = ManaCost(white: 3)
//        let azorius = ManaCost(white: 1, blue: 1)
//        let jund = ManaCost(black: 1, red: 1, green: 1)
//        let fiveColor = ManaCost(white: 1, blue: 1, black: 1, red: 1, green: 1)
//        let colorless = ManaCost(colorless: 3)
//        
//        #expect(monoWhite.isMonoColored)
//        #expect(!monoWhite.isMultiColored)
//        
//        #expect(!azorius.isMonoColored)
//        #expect(azorius.isMultiColored)
//        #expect(azorius.isTwoColored)
//        
//        #expect(jund.isThreeColored)
//        #expect(jund.isMultiColored)
//        #expect(!jund.isMonoColored)
//        
//        #expect(fiveColor.isMultiColored)
//        #expect(!fiveColor.isMonoColored)
//        
//        #expect(!colorless.isMonoColored)
//        #expect(colorless.isColorless)
//        #expect(!colorless.isMultiColored)
//    }
//    
//    /// Test basic ManaColorCount creation and counting
//    @Test func testManaColorCountCreation() {
//        var colorCount = ManaColorCount()
//        let azorius = ManaCost(white: 1, blue: 1)
//        
//        colorCount.add(azorius)
//        #expect(colorCount.white == 1)
//        #expect(colorCount.blue == 1)
//        #expect(colorCount.azorius == 1)
//        
//        let monoWhite = ManaCost(white: 1)
//        colorCount.add(monoWhite)
//        #expect(colorCount.white == 2)
//        #expect(colorCount.blue == 1)
//        #expect(colorCount.azorius == 1)
//    }
//    
//    /// Test ManaColorCount with two-color guilds
//    @Test func testTwoColorGuilds() {
//        var colorCount = ManaColorCount()
//        
//        // Add Azorius (WU) costs
//        let azorius1 = ManaCost(white: 1, blue: 1)
//        let azorius2 = ManaCost(white: 2, blue: 1)
//        let azorius3 = ManaCost(white: 1, blue: 2)
//        
//        colorCount.add(azorius1)
//        colorCount.add(azorius2)
//        colorCount.add(azorius3)
//        
//        #expect(colorCount.azorius == 3)
//        
//        // Add Boros (RW) costs
//        let boros1 = ManaCost(white: 1, red: 1)
//        let boros2 = ManaCost(white: 2, red: 1)
//        
//        colorCount.add(boros1)
//        colorCount.add(boros2)
//        
//        #expect(colorCount.boros == 2)
//        
//        // Add Dimir (UB) costs
//        let dimir = ManaCost(blue: 1, black: 1)
//        colorCount.add(dimir)
//        
//        #expect(colorCount.dimir == 1)
//        
//        // Check guild counts
//        #expect(colorCount.azorius == 3)
//        #expect(colorCount.boros == 2)
//        #expect(colorCount.dimir == 1)
//        #expect(colorCount.orzhov == 0)
//        #expect(colorCount.izzet == 0)
//        
//        // Test most common guild
//        let mostCommon = colorCount.mostCommonGuild()
//        #expect(mostCommon?.name == "Azorius")
//        #expect(mostCommon?.count == 3)
//    }
//    
//    /// Test ManaColorCount with three-color combinations (shards)
//    @Test func testThreeColorShards() {
//        var colorCount = ManaColorCount()
//        
//        // Add Bant (GWU) costs
//        let bant1 = ManaCost(white: 1, blue: 1, green: 1)
//        let bant2 = ManaCost(white: 2, blue: 1, green: 1)
//        
//        colorCount.add(bant1)
//        colorCount.add(bant2)
//        
//        #expect(colorCount.bant == 2)
//        
//        // Add Grixis (UBR) costs
//        let grixis1 = ManaCost(blue: 1, black: 1, red: 1)
//        let grixis2 = ManaCost(blue: 1, black: 2, red: 1)
//        let grixis3 = ManaCost(blue: 2, black: 1, red: 1)
//        
//        colorCount.add(grixis1)
//        colorCount.add(grixis2)
//        colorCount.add(grixis3)
//        
//        #expect(colorCount.grixis == 3)
//        
//        // Add Naya (RGW) costs
//        let naya = ManaCost(white: 1, red: 1, green: 1)
//        colorCount.add(naya)
//        
//        #expect(colorCount.naya == 1)
//        
//        // Check shard counts
//        #expect(colorCount.bant == 2)
//        #expect(colorCount.grixis == 3)
//        #expect(colorCount.naya == 1)
//        
//        // Test most common shard
//        let mostCommonShard = colorCount.mostCommonShard()
//        #expect(mostCommonShard?.name == "Grixis")
//        #expect(mostCommonShard?.count == 3)
//    }
//    
//    /// Test ManaColorCount with three-color combinations (wedges)
//    @Test func testThreeColorWedges() {
//        var colorCount = ManaColorCount()
//        
//        // Add Abzan (WBG) costs
//        let abzan1 = ManaCost(white: 1, black: 1, green: 1)
//        let abzan2 = ManaCost(white: 2, black: 1, green: 1)
//        
//        colorCount.add(abzan1)
//        colorCount.add(abzan2)
//        
//        #expect(colorCount.abzan == 2)
//        
//        // Add Mardu (RWB) costs
//        let mardu1 = ManaCost(white: 1, black: 1, red: 1)
//        let mardu2 = ManaCost(white: 1, black: 2, red: 1)
//        let mardu3 = ManaCost(white: 2, black: 1, red: 1)
//        
//        colorCount.add(mardu1)
//        colorCount.add(mardu2)
//        colorCount.add(mardu3)
//        
//        #expect(colorCount.mardu == 3)
//        
//        // Add Jeskai (URW) costs
//        let jeskai = ManaCost(white: 1, blue: 1, red: 1)
//        colorCount.add(jeskai)
//        
//        #expect(colorCount.jeskai == 1)
//        
//        // Check wedge counts
//        #expect(colorCount.abzan == 2)
//        #expect(colorCount.mardu == 3)
//        #expect(colorCount.jeskai == 1)
//        
//        // Test most common wedge
//        let mostCommonWedge = colorCount.mostCommonWedge()
//        #expect(mostCommonWedge?.name == "Mardu")
//        #expect(mostCommonWedge?.count == 3)
//    }
//    
//    /// Test mixed guild and shard/wedge counting
//    @Test func testMixedColorCounting() {
//        var colorCount = ManaColorCount()
//        
//        // Add various color combinations
//        let azorius = ManaCost(white: 1, blue: 1)
//        let boros = ManaCost(white: 1, red: 1)
//        let dimir = ManaCost(blue: 1, black: 1)
//        
//        let bant = ManaCost(white: 1, blue: 1, green: 1)
//        let grixis = ManaCost(blue: 1, black: 1, red: 1)
//        let abzan = ManaCost(white: 1, black: 1, green: 1)
//        
//        colorCount.add(azorius)
//        colorCount.add(boros)
//        colorCount.add(dimir)
//        colorCount.add(bant)
//        colorCount.add(grixis)
//        colorCount.add(abzan)
//        
//        // Check specific counts
//        #expect(colorCount.white == 4)
//        #expect(colorCount.blue == 4)
//        #expect(colorCount.black == 3)
//        #expect(colorCount.red == 2)
//        #expect(colorCount.green == 2)
//        
//        #expect(colorCount.azorius == 1)
//        #expect(colorCount.boros == 1)
//        #expect(colorCount.dimir == 1)
//        
//        #expect(colorCount.bant == 1)
//        #expect(colorCount.grixis == 1)
//        #expect(colorCount.abzan == 1)
//        
//        // Check distribution by color count
//        let distribution = colorCount.colorCountDistribution()
//        #expect(distribution["One-color"] == 0)
//        #expect(distribution["Two-color"] == 3)
//        #expect(distribution["Three-color"] == 3)
//    }
//    
//    /// Test the MTGColorReference static data
//    @Test func testMTGColorReference() {
//        // Test guild data
//        #expect(MTGColorReference.guilds.count == 10)
//        #expect(MTGColorReference.guilds[0].name == "Azorius")
//        #expect(MTGColorReference.guilds[0].colors == "WU")
//        
//        // Test shard data
//        #expect(MTGColorReference.shards.count == 5)
//        #expect(MTGColorReference.shards[0].name == "Bant")
//        #expect(MTGColorReference.shards[0].colors == "GWU")
//        
//        // Test wedge data
//        #expect(MTGColorReference.wedges.count == 5)
//        #expect(MTGColorReference.wedges[1].name == "Jeskai")
//        #expect(MTGColorReference.wedges[1].colors == "URW")
//    }
//    
//    /// Test mana cost parsing with variable X cost
//    @Test func testXCostParsing() {
//        var manaCost = ManaCost()
//        manaCost.set(from: "{X}{R}{R}")
//        
//        #expect(manaCost.colorless == 0)  // X doesn't count as colorless in this implementation
//        #expect(manaCost.red == 2)
//        #expect(manaCost.cmc() == 2)  // X is not counted in CMC
//        #expect(manaCost.isMonoColored)
//    }
//    
//    /// Test mana cost parsing with mixed symbol types
//    @Test func testMixedSymbolTypes() {
//        var manaCost = ManaCost()
//        manaCost.set(from: "{2}{W/U}{B/P}{R}")
//        
//        #expect(manaCost.colorless == 2)
//        #expect(manaCost.white == 1)
//        #expect(manaCost.blue == 1)
//        #expect(manaCost.black == 1)
//        #expect(manaCost.red == 1)
//        #expect(manaCost.green == 0)
//        #expect(manaCost.cmc() == 5)
//        #expect(manaCost.isMultiColored)
//    }
//}
