import Testing
@testable import Card  // Assuming ManaColorCount is in the Card module

/// Tests for the ManaColorCount struct
struct ManaColorCountTests {
    
    // MARK: - Initialization Tests
    
    /// Test default initialization
    @Test func testDefaultInitialization() {
        let colorCount = ManaColorCount()
        
        // All counts should be zero initially
        #expect(colorCount.total == 0)
        #expect(colorCount.colorless == 0)
        #expect(colorCount.white == 0)
        #expect(colorCount.blue == 0)
        #expect(colorCount.black == 0)
        #expect(colorCount.red == 0)
        #expect(colorCount.green == 0)
        
        // All guild counts should be zero
        #expect(colorCount.azorius == 0)
        #expect(colorCount.orzhov == 0)
        #expect(colorCount.dimir == 0)
        #expect(colorCount.izzet == 0)
        #expect(colorCount.rakdos == 0)
        #expect(colorCount.golgari == 0)
        #expect(colorCount.gruul == 0)
        #expect(colorCount.boros == 0)
        #expect(colorCount.selesnya == 0)
        #expect(colorCount.simic == 0)
        
        // All shard counts should be zero
        #expect(colorCount.bant == 0)
        #expect(colorCount.esper == 0)
        #expect(colorCount.grixis == 0)
        #expect(colorCount.jund == 0)
        #expect(colorCount.naya == 0)
        
        // All wedge counts should be zero
        #expect(colorCount.abzan == 0)
        #expect(colorCount.jeskai == 0)
        #expect(colorCount.sultai == 0)
        #expect(colorCount.mardu == 0)
        #expect(colorCount.temur == 0)
    }
    
    // MARK: - Count Method Tests
    
    /// Test counting a colorless mana cost
    @Test func testCountColorless() {
        var colorCount = ManaColorCount()
        let manaCost = ManaCost(colorless: 3)
        
        colorCount.count(manaCost: manaCost)
        
        #expect(colorCount.total == 1)
        #expect(colorCount.colorless == 3)
        #expect(colorCount.totalTwoColorCards == 0)
        #expect(colorCount.totalThreeColorCards == 0)
    }
    
    /// Test counting single colors
    @Test func testCountSingleColors() {
        var colorCount = ManaColorCount()
        
        // Count a single white mana
        colorCount.count(manaCost: ManaCost(white: 1))
        
        #expect(colorCount.total == 1)
        #expect(colorCount.white == 1)
        #expect(colorCount.totalTwoColorCards == 0)
        
        // Count a single blue mana
        colorCount.count(manaCost: ManaCost(blue: 1))
        
        #expect(colorCount.total == 2)
        #expect(colorCount.blue == 1)
        
        // Count a black mana
        colorCount.count(manaCost: ManaCost(black: 2))
        
        #expect(colorCount.total == 3)
        #expect(colorCount.black == 2)
        
        // Count a red mana
        colorCount.count(manaCost: ManaCost(red: 3))
        
        #expect(colorCount.total == 4)
        #expect(colorCount.red == 3)
        
        // Count a green mana
        colorCount.count(manaCost: ManaCost(green: 4))
        
        #expect(colorCount.total == 5)
        #expect(colorCount.green == 4)
    }
    
    /// Test counting guild color pairs
    @Test func testCountGuildColorPairs() {
        var colorCount = ManaColorCount()
        
        // Test Azorius (WU)
        colorCount.count(manaCost: ManaCost(white: 1, blue: 1))
        #expect(colorCount.azorius == 1)
        #expect(colorCount.white == 1)
        #expect(colorCount.blue == 1)
        #expect(colorCount.totalTwoColorCards == 1)
        
        // Test Orzhov (WB)
        colorCount.count(manaCost: ManaCost(white: 1, black: 1))
        #expect(colorCount.orzhov == 1)
        #expect(colorCount.totalTwoColorCards == 2)
        
        // Test Dimir (UB)
        colorCount.count(manaCost: ManaCost(blue: 1, black: 1))
        #expect(colorCount.dimir == 1)
        #expect(colorCount.totalTwoColorCards == 3)
        
        // Test Izzet (UR)
        colorCount.count(manaCost: ManaCost(blue: 1, red: 1))
        #expect(colorCount.izzet == 1)
        #expect(colorCount.totalTwoColorCards == 4)
        
        // Test Rakdos (BR)
        colorCount.count(manaCost: ManaCost(black: 1, red: 1))
        #expect(colorCount.rakdos == 1)
        #expect(colorCount.totalTwoColorCards == 5)
        
        // Test Golgari (BG)
        colorCount.count(manaCost: ManaCost(black: 1, green: 1))
        #expect(colorCount.golgari == 1)
        #expect(colorCount.totalTwoColorCards == 6)
        
        // Test Gruul (RG)
        colorCount.count(manaCost: ManaCost(red: 1, green: 1))
        #expect(colorCount.gruul == 1)
        #expect(colorCount.totalTwoColorCards == 7)
        
        // Test Boros (RW)
        colorCount.count(manaCost: ManaCost(white: 1, red: 1))
        #expect(colorCount.boros == 1)
        #expect(colorCount.totalTwoColorCards == 8)
        
        // Test Selesnya (GW)
        colorCount.count(manaCost: ManaCost(white: 1, green: 1))
        #expect(colorCount.selesnya == 1)
        #expect(colorCount.totalTwoColorCards == 9)
        
        // Test Simic (GU)
        colorCount.count(manaCost: ManaCost(blue: 1, green: 1))
        #expect(colorCount.simic == 1)
        #expect(colorCount.totalTwoColorCards == 10)
        
        // Check that all guild combinations were counted
        let guildCounts = colorCount.guildCounts
        for (_, count) in guildCounts {
            #expect(count == 1)
        }
    }
    
    /// Test counting shard color combinations (allied three-color)
    @Test func testCountShards() {
        var colorCount = ManaColorCount()
        
        // Test Bant (GWU)
        colorCount.count(manaCost: ManaCost(white: 1, blue: 1, green: 1))
        #expect(colorCount.bant == 1)
        #expect(colorCount.totalThreeColorCards == 1)
        
        // Test Esper (WUB)
        colorCount.count(manaCost: ManaCost(white: 1, blue: 1, black: 1))
        #expect(colorCount.esper == 1)
        #expect(colorCount.totalThreeColorCards == 2)
        
        // Test Grixis (UBR)
        colorCount.count(manaCost: ManaCost(blue: 1, black: 1, red: 1))
        #expect(colorCount.grixis == 1)
        #expect(colorCount.totalThreeColorCards == 3)
        
        // Test Jund (BRG)
        colorCount.count(manaCost: ManaCost(black: 1, red: 1, green: 1))
        #expect(colorCount.jund == 1)
        #expect(colorCount.totalThreeColorCards == 4)
        
        // Test Naya (RGW)
        colorCount.count(manaCost: ManaCost(white: 1, red: 1, green: 1))
        #expect(colorCount.naya == 1)
        #expect(colorCount.totalThreeColorCards == 5)
        
        // Check that all shard combinations were counted
        let shardCounts = colorCount.shardCounts
        for (_, count) in shardCounts {
            #expect(count == 1)
        }
    }
    
    /// Test counting wedge color combinations (enemy three-color)
    @Test func testCountWedges() {
        var colorCount = ManaColorCount()
        
        // Test Abzan (WBG)
        colorCount.count(manaCost: ManaCost(white: 1, black: 1, green: 1))
        #expect(colorCount.abzan == 1)
        #expect(colorCount.totalThreeColorCards == 1)
        
        // Test Jeskai (URW)
        colorCount.count(manaCost: ManaCost(white: 1, blue: 1, red: 1))
        #expect(colorCount.jeskai == 1)
        #expect(colorCount.totalThreeColorCards == 2)
        
        // Test Sultai (BGU)
        colorCount.count(manaCost: ManaCost(blue: 1, black: 1, green: 1))
        #expect(colorCount.sultai == 1)
        #expect(colorCount.totalThreeColorCards == 3)
        
        // Test Mardu (RWB)
        colorCount.count(manaCost: ManaCost(white: 1, black: 1, red: 1))
        #expect(colorCount.mardu == 1)
        #expect(colorCount.totalThreeColorCards == 4)
        
        // Test Temur (GUR)
        colorCount.count(manaCost: ManaCost(blue: 1, red: 1, green: 1))
        #expect(colorCount.temur == 1)
        #expect(colorCount.totalThreeColorCards == 5)
        
        // Check that all wedge combinations were counted
        let wedgeCounts = colorCount.wedgeCounts
        for (_, count) in wedgeCounts {
            #expect(count == 1)
        }
    }
    
    /// Test counting mixed mana costs
    @Test func testCountMixedManaCosts() {
        var colorCount = ManaColorCount()
        
        // Count a colorless plus red mana
        colorCount.count(manaCost: ManaCost(red: 1, colorless: 2))
        #expect(colorCount.total == 1)
        #expect(colorCount.red == 1)
        #expect(colorCount.colorless == 2)
        #expect(colorCount.totalTwoColorCards == 0)
        
        // Count a two-color plus colorless
        colorCount.count(manaCost: ManaCost(blue: 1, black: 1, colorless: 3))
        #expect(colorCount.total == 2)
        #expect(colorCount.dimir == 1)
        #expect(colorCount.colorless == 5)  // 2 + 3
        
        // Count a three-color plus colorless
        colorCount.count(manaCost: ManaCost(white: 1, blue: 1, black: 1, colorless: 1))
        #expect(colorCount.total == 3)
        #expect(colorCount.esper == 1)
        #expect(colorCount.colorless == 6)  // 2 + 3 + 1
    }
    
    // MARK: - Computed Property Tests
    
    /// Test guildCounts property
    @Test func testGuildCounts() {
        var colorCount = ManaColorCount()
        
        // Add some guild combinations
        colorCount.count(manaCost: ManaCost(white: 1, blue: 1))  // Azorius
        colorCount.count(manaCost: ManaCost(red: 1, green: 1))   // Gruul
        colorCount.count(manaCost: ManaCost(red: 1, green: 1))   // Gruul again
        
        let guildCounts = colorCount.guildCounts
        #expect(guildCounts["Azorius"] == 1)
        #expect(guildCounts["Gruul"] == 2)
        #expect(guildCounts.count == 10)  // All 10 guilds should be in the dictionary
    }
    
    /// Test shardCounts property
    @Test func testShardCounts() {
        var colorCount = ManaColorCount()
        
        // Add some shard combinations
        colorCount.count(manaCost: ManaCost(white: 1, blue: 1, green: 1))  // Bant
        colorCount.count(manaCost: ManaCost(blue: 1, black: 1, red: 1))    // Grixis
        colorCount.count(manaCost: ManaCost(blue: 1, black: 1, red: 1))    // Grixis again
        
        let shardCounts = colorCount.shardCounts
        #expect(shardCounts["Bant"] == 1)
        #expect(shardCounts["Grixis"] == 2)
        #expect(shardCounts.count == 5)  // All 5 shards should be in the dictionary
    }
    
    /// Test wedgeCounts property
    @Test func testWedgeCounts() {
        var colorCount = ManaColorCount()
        
        // Add some wedge combinations
        colorCount.count(manaCost: ManaCost(white: 1, black: 1, green: 1))  // Abzan
        colorCount.count(manaCost: ManaCost(blue: 1, red: 1, green: 1))     // Temur
        colorCount.count(manaCost: ManaCost(blue: 1, red: 1, green: 1))     // Temur again
        
        let wedgeCounts = colorCount.wedgeCounts
        #expect(wedgeCounts["Abzan"] == 1)
        #expect(wedgeCounts["Temur"] == 2)
        #expect(wedgeCounts.count == 5)  // All 5 wedges should be in the dictionary
    }
    
    /// Test tricolorCounts property
    @Test func testTricolorCounts() {
        var colorCount = ManaColorCount()
        
        // Add some three-color combinations
        colorCount.count(manaCost: ManaCost(white: 1, blue: 1, green: 1))  // Bant (shard)
        colorCount.count(manaCost: ManaCost(white: 1, black: 1, green: 1))  // Abzan (wedge)
        
        let tricolorCounts = colorCount.tricolorCounts
        #expect(tricolorCounts["Bant"] == 1)
        #expect(tricolorCounts["Abzan"] == 1)
        #expect(tricolorCounts.count == 10)  // All 10 three-color combinations should be in the dictionary
    }
    
    /// Test mostCommonGuild property
    @Test func testMostCommonGuild() {
        var colorCount = ManaColorCount()
        
        // Initially, there should be no most common guild
        #expect(colorCount.mostCommonGuild == nil)
        
        // Add some guild combinations
        colorCount.count(manaCost: ManaCost(white: 1, red: 1))  // Boros
        colorCount.count(manaCost: ManaCost(white: 1, red: 1))  // Boros again
        colorCount.count(manaCost: ManaCost(white: 1, red: 1))  // Boros again
        colorCount.count(manaCost: ManaCost(blue: 1, black: 1))  // Dimir
        colorCount.count(manaCost: ManaCost(blue: 1, black: 1))  // Dimir again
        
        let mostCommon = colorCount.mostCommonGuild
        #expect(mostCommon != nil)
        #expect(mostCommon?.name == "Boros")
        #expect(mostCommon?.count == 3)
    }
    
    /// Test mostCommonTricolor property
    @Test func testMostCommonTricolor() {
        var colorCount = ManaColorCount()
        
        // Initially, there should be no most common tricolor
        #expect(colorCount.mostCommonTricolor == nil)
        
        // Add some three-color combinations
        colorCount.count(manaCost: ManaCost(blue: 1, black: 1, red: 1))  // Grixis
        colorCount.count(manaCost: ManaCost(blue: 1, black: 1, red: 1))  // Grixis again
        colorCount.count(manaCost: ManaCost(blue: 1, black: 1, red: 1))  // Grixis again
        colorCount.count(manaCost: ManaCost(blue: 1, red: 1, green: 1))  // Temur
        
        let mostCommon = colorCount.mostCommonTricolor
        #expect(mostCommon != nil)
        #expect(mostCommon?.name == "Grixis")
        #expect(mostCommon?.count == 3)
    }
    
    /// Test colorDistribution property
    @Test func testColorDistribution() {
        var colorCount = ManaColorCount()
        
        // Add various mana costs
        colorCount.count(manaCost: ManaCost(colorless: 2))  // Colorless
        colorCount.count(manaCost: ManaCost(white: 1))      // White
        colorCount.count(manaCost: ManaCost(blue: 1))       // Blue
        colorCount.count(manaCost: ManaCost(black: 1))      // Black
        colorCount.count(manaCost: ManaCost(red: 1))        // Red
        colorCount.count(manaCost: ManaCost(green: 1))      // Green
        colorCount.count(manaCost: ManaCost(white: 1, blue: 1))  // Azorius (two-color)
        colorCount.count(manaCost: ManaCost(white: 1, blue: 1, black: 1))  // Esper (three-color)
        
        let distribution = colorCount.colorDistribution
        #expect(distribution["Colorless"] == 2)
        #expect(distribution["White"] == 3)  // 1 + 1 + 1
        #expect(distribution["Blue"] == 3)   // 1 + 1 + 1
        #expect(distribution["Black"] == 2)  // 1 + 1
        #expect(distribution["Red"] == 1)
        #expect(distribution["Green"] == 1)
        #expect(distribution["Two-color"] == 1)
        #expect(distribution["Three-color"] == 1)
    }
    
    // MARK: - Integration Tests
    
    /// Test counting multiple mana costs and verifying overall statistics
    @Test func testIntegrationMultipleCounts() {
        var colorCount = ManaColorCount()
        
        // Add 10 different mana costs
        colorCount.count(manaCost: ManaCost(colorless: 3))  // Colorless
        colorCount.count(manaCost: ManaCost(white: 1))      // White
        colorCount.count(manaCost: ManaCost(blue: 1))       // Blue
        colorCount.count(manaCost: ManaCost(black: 1))      // Black
        colorCount.count(manaCost: ManaCost(red: 1))        // Red
        colorCount.count(manaCost: ManaCost(green: 1))      // Green
        
        // Two-color combinations
        colorCount.count(manaCost: ManaCost(white: 1, blue: 1))  // Azorius
        colorCount.count(manaCost: ManaCost(blue: 1, black: 1))  // Dimir
        
        // Three-color combinations
        colorCount.count(manaCost: ManaCost(white: 1, blue: 1, black: 1))  // Esper (shard)
        colorCount.count(manaCost: ManaCost(white: 1, black: 1, green: 1))  // Abzan (wedge)
        
        // Check totals
        #expect(colorCount.total == 10)
        #expect(colorCount.totalTwoColorCards == 2)
        #expect(colorCount.totalThreeColorCards == 2)
        
        // Check individual color counts
        #expect(colorCount.white == 4)  // 1 + 1 + 1 + 1
        #expect(colorCount.blue == 4)   // 1 + 1 + 1 + 1
        #expect(colorCount.black == 4)  // 1 + 1 + 1 + 1
        #expect(colorCount.red == 1)
        #expect(colorCount.green == 2)  // 1 + 1
        #expect(colorCount.colorless == 3)
        
        // Check guild counts
        #expect(colorCount.azorius == 1)
        #expect(colorCount.dimir == 1)
        
        // Check three-color counts
        #expect(colorCount.esper == 1)
        #expect(colorCount.abzan == 1)
        
        // Check most common combinations
        let mostCommonGuild = colorCount.mostCommonGuild
        #expect(mostCommonGuild?.count == 1)  // All guilds have the same count (1)
        
        let mostCommonTricolor = colorCount.mostCommonTricolor
        #expect(mostCommonTricolor?.count == 1)  // All tricolors have the same count (1)
    }
    
    /// Test with complex mixed mana costs using ManaCost properties
    @Test func testMixedManaCostBitSignatures() {
        var colorCount = ManaColorCount()
        
        // Create a mana cost with various properties
        let complexManaCost = ManaCost(white: 2, blue: 1, black: 1, red: 3, green: 2, colorless: 4)
        
        // Verify the mana cost properties 
        #expect(complexManaCost.isMultiColored)
        #expect(!complexManaCost.isMonoColored)
        #expect(!complexManaCost.isTwoColored)
        #expect(!complexManaCost.isThreeColored)
        #expect(complexManaCost.colorCount == 5)
        #expect(complexManaCost.cmc() == 13)
        
        // Count it in our color distribution
        colorCount.count(manaCost: complexManaCost)
        
        // We should have increments for each color, but no specific guild/shard/wedge
        // since this is a five-color card
        #expect(colorCount.total == 1)
        #expect(colorCount.white == 2)
        #expect(colorCount.blue == 1)
        #expect(colorCount.black == 1)
        #expect(colorCount.red == 3)
        #expect(colorCount.green == 2)
        #expect(colorCount.colorless == 4)
        #expect(colorCount.totalTwoColorCards == 0)
        #expect(colorCount.totalThreeColorCards == 0)
        
        // All specific guild/shard/wedge counts should be 0
        #expect(colorCount.azorius == 0)
        #expect(colorCount.bant == 0)
        #expect(colorCount.abzan == 0)
    }
    
    /// Test with specific mana cost patterns common in Magic: The Gathering
    @Test func testMagicSpecificManaCosts() {
        var colorCount = ManaColorCount()
        
        // Common mono-colored mana costs
        // White Weenie: 1W (Plains + White creature)
        colorCount.count(manaCost: ManaCost(white: 1, colorless: 1))
        
        // Blue control: 1UU (Island + Counterspell)
        colorCount.count(manaCost: ManaCost(blue: 2, colorless: 1))
        
        // Black removal: 1BB (Swamp + Doom Blade)
        colorCount.count(manaCost: ManaCost(black: 2, colorless: 1))
        
        // Red burn: R (Mountain + Lightning Bolt)
        colorCount.count(manaCost: ManaCost(red: 1))
        
        // Green ramp: 2G (Forest + Rampant Growth)
        colorCount.count(manaCost: ManaCost(green: 1, colorless: 2))
        
        // Common multi-colored costs
        // Azorius control: WUU (Supreme Verdict)
        colorCount.count(manaCost: ManaCost(white: 1, blue: 2))
        
        // Golgari midrange: 1BG (Deathrite Shaman)
        colorCount.count(manaCost: ManaCost(black: 1, green: 1, colorless: 1))
        
        // Check counts
        #expect(colorCount.total == 7)
        #expect(colorCount.white == 2)
        #expect(colorCount.blue == 4)
        #expect(colorCount.black == 3)
        #expect(colorCount.red == 1)
        #expect(colorCount.green == 2)
        #expect(colorCount.totalTwoColorCards == 2)  // Azorius and Golgari
        
        // Check guild-specific counts
        #expect(colorCount.azorius == 1)
        #expect(colorCount.golgari == 1)
    }
}
