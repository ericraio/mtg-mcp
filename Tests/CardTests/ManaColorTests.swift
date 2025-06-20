import Testing
@testable import Card  

/// Tests for the ManaColor struct
struct ManaColorTests {
    
    // MARK: - Initialization Tests
    
    /// Test default initialization
    @Test func testDefaultInitialization() {
        let manaColor = ManaColor()
        
        // All properties should be false by default
        #expect(!manaColor.isRed)
        #expect(!manaColor.isGreen)
        #expect(!manaColor.isBlack)
        #expect(!manaColor.isBlue)
        #expect(!manaColor.isWhite)
        #expect(!manaColor.isColorless)
        #expect(!manaColor.hasAnyColor)
        #expect(manaColor.colorCount == 0)
        #expect(manaColor.colorIdentity.isEmpty)
    }
    
    /// Test initialization with specific colors
    @Test func testColorInitialization() {
        let manaColor = ManaColor(
            isWhite: true,
            isBlue: false,
            isBlack: true,
            isRed: false,
            isGreen: true,
            isColorless: false
        )
        
        #expect(!manaColor.isRed)
        #expect(manaColor.isGreen)
        #expect(manaColor.isBlack)
        #expect(!manaColor.isBlue)
        #expect(manaColor.isWhite)
        #expect(!manaColor.isColorless)
        #expect(manaColor.hasAnyColor)
        #expect(manaColor.colorCount == 3)
    }
    
    /// Test WUBRG-ordered initialization
    @Test func testWUBRGInitialization() {
        let manaColor = ManaColor.wubrg(
            white: true,
            blue: true,
            black: false,
            red: false,
            green: true
        )
        
        #expect(!manaColor.isRed)
        #expect(manaColor.isGreen)
        #expect(!manaColor.isBlack)
        #expect(manaColor.isBlue)
        #expect(manaColor.isWhite)
        #expect(!manaColor.isColorless)
        #expect(manaColor.colorCount == 3)
    }
    
    // MARK: - Methods Tests
    
    /// Test setting colors from string
    @Test func testSetFromString() {
        var manaColor = ManaColor()
        
        manaColor.set(from: "RG")
        #expect(manaColor.isRed)
        #expect(manaColor.isGreen)
        #expect(!manaColor.isBlack)
        #expect(!manaColor.isBlue)
        #expect(!manaColor.isWhite)
        #expect(!manaColor.isColorless)
        
        // Reset and test another string
        manaColor = ManaColor()
        manaColor.set(from: "WUBRG")
        #expect(manaColor.isRed)
        #expect(manaColor.isGreen)
        #expect(manaColor.isBlack)
        #expect(manaColor.isBlue)
        #expect(manaColor.isWhite)
        #expect(!manaColor.isColorless)
        
        // Test with special characters
        manaColor = ManaColor()
        manaColor.set(from: "W/U{B}R//G")
        #expect(manaColor.isRed)
        #expect(manaColor.isGreen)
        #expect(manaColor.isBlack)
        #expect(manaColor.isBlue)
        #expect(manaColor.isWhite)
        #expect(!manaColor.isColorless)
        
        // Test with colorless
        manaColor = ManaColor()
        manaColor.set(from: "1")
        #expect(!manaColor.isRed)
        #expect(!manaColor.isGreen)
        #expect(!manaColor.isBlack)
        #expect(!manaColor.isBlue)
        #expect(!manaColor.isWhite)
        #expect(manaColor.isColorless)
        
        // Test with X
        manaColor = ManaColor()
        manaColor.set(from: "X")
        #expect(!manaColor.isRed)
        #expect(!manaColor.isGreen)
        #expect(!manaColor.isBlack)
        #expect(!manaColor.isBlue)
        #expect(!manaColor.isWhite)
        #expect(!manaColor.isColorless) // X should be ignored
    }
    
    // MARK: - Property Tests
    
    /// Test hasAnyColor property
    @Test func testHasAnyColor() {
        let emptyColor = ManaColor()
        #expect(!emptyColor.hasAnyColor)
        
        let red = ManaColor(isRed: true)
        #expect(red.hasAnyColor)
        
        let colorless = ManaColor(isColorless: true)
        #expect(colorless.hasAnyColor)
    }
    
    /// Test colorCount property
    @Test func testColorCount() {
        let emptyColor = ManaColor()
        #expect(emptyColor.colorCount == 0)
        
        let mono = ManaColor(isBlue: true)
        #expect(mono.colorCount == 1)
        
        let dual = ManaColor(isRed: true, isGreen: true)
        #expect(dual.colorCount == 2)
        
        let tri = ManaColor(isWhite: true, isBlue: true, isBlack: true)
        #expect(tri.colorCount == 3)
        
        let four = ManaColor(isWhite: true, isBlue: true, isBlack: true, isRed: true)
        #expect(four.colorCount == 4)
        
        let five = ManaColor(isWhite: true, isBlue: true, isBlack: true, isRed: true, isGreen: true)
        #expect(five.colorCount == 5)
        
        // Colorless shouldn't add to the color count
        let colorless = ManaColor(isColorless: true)
        #expect(colorless.colorCount == 0)
    }
    
    /// Test colorIdentity property
    @Test func testColorIdentity() {
        let emptyColor = ManaColor()
        #expect(emptyColor.colorIdentity.isEmpty)
        
        let mono = ManaColor(isBlue: true)
        #expect(mono.colorIdentity == "U")
        
        let dual = ManaColor(isRed: true, isGreen: true)
        #expect(dual.colorIdentity == "RG")
        
        let esper = ManaColor(isWhite: true, isBlue: true, isBlack: true)
        #expect(esper.colorIdentity == "WUB")
        
        let nonGreen = ManaColor(isWhite: true, isBlue: true, isBlack: true, isRed: true)
        #expect(nonGreen.colorIdentity == "WUBR")
        
        let allColors = ManaColor(isWhite: true, isBlue: true, isBlack: true, isRed: true, isGreen: true)
        #expect(allColors.colorIdentity == "WUBRG")
        
        let colorless = ManaColor(isColorless: true)
        #expect(colorless.colorIdentity == "C")
    }
    
    /// Test isMulticolored property
    @Test func testIsMulticolored() {
        let emptyColor = ManaColor()
        #expect(!emptyColor.isMulticolored)
        
        let mono = ManaColor(isBlue: true)
        #expect(!mono.isMulticolored)
        
        let dual = ManaColor(isRed: true, isGreen: true)
        #expect(dual.isMulticolored)
        
        let tri = ManaColor(isWhite: true, isBlue: true, isBlack: true)
        #expect(tri.isMulticolored)
        
        let colorless = ManaColor(isColorless: true)
        #expect(!colorless.isMulticolored)
    }
    
    /// Test isMonocolored property
    @Test func testIsMonocolored() {
        let emptyColor = ManaColor()
        #expect(!emptyColor.isMonocolored)
        
        let mono = ManaColor(isBlue: true)
        #expect(mono.isMonocolored)
        
        let dual = ManaColor(isRed: true, isGreen: true)
        #expect(!dual.isMonocolored)
        
        let colorless = ManaColor(isColorless: true)
        #expect(!colorless.isMonocolored)
    }
    
    // MARK: - Protocol Conformance Tests
    
    /// Test CustomStringConvertible conformance
    @Test func testDescription() {
        let emptyColor = ManaColor()
        #expect(emptyColor.description == "No Color")
        
        let mono = ManaColor(isBlue: true)
        #expect(mono.description == "U")
        
        let izzet = ManaColor(isBlue: true, isRed: true)
        #expect(izzet.description == "UR")
        
        let esper = ManaColor(isWhite: true, isBlue: true, isBlack: true)
        #expect(esper.description == "WUB")
        
        let colorless = ManaColor(isColorless: true)
        #expect(colorless.description == "Colorless")
        
        // Test a colorless with actual colors (edge case)
        let strangeCase = ManaColor(isRed: true, isColorless: true)
        #expect(strangeCase.description == "R")
    }
    
    /// Test Equatable conformance
    @Test func testEquatable() {
        let redA = ManaColor(isRed: true)
        let redB = ManaColor(isRed: true)
        let blue = ManaColor(isBlue: true)
        
        #expect(redA == redB)
        #expect(redA != blue)
    }
    
    /// Test Hashable conformance
    @Test func testHashable() {
        let red = ManaColor(isRed: true)
        let blue = ManaColor(isBlue: true)
        let anotherRed = ManaColor(isRed: true)
        
        var colorSet = Set<ManaColor>()
        colorSet.insert(red)
        colorSet.insert(blue)
        colorSet.insert(anotherRed) // Should be considered a duplicate
        
        #expect(colorSet.count == 2)
    }
    
    // MARK: - Integration Tests
    
    /// Test creation of common Magic: The Gathering color combinations
    @Test func testCommonMagicColorCombinations() {
        // Monocolored
        let white = ManaColor(isWhite: true)
        #expect(white.colorIdentity == "W")
        #expect(white.isMonocolored)
        
        let blue = ManaColor(isBlue: true)
        #expect(blue.colorIdentity == "U")
        #expect(blue.isMonocolored)
        
        let black = ManaColor(isBlack: true)
        #expect(black.colorIdentity == "B")
        #expect(black.isMonocolored)
        
        let red = ManaColor(isRed: true)
        #expect(red.colorIdentity == "R")
        #expect(red.isMonocolored)
        
        let green = ManaColor(isGreen: true)
        #expect(green.colorIdentity == "G")
        #expect(green.isMonocolored)
        
        // Guild color pairs
        let azorius = ManaColor(isWhite: true, isBlue: true)
        #expect(azorius.colorIdentity == "WU")
        #expect(azorius.isMulticolored)
        
        let dimir = ManaColor(isBlue: true, isBlack: true)
        #expect(dimir.colorIdentity == "UB")
        #expect(dimir.isMulticolored)
        
        // Shards (allied three-color combinations)
        let bant = ManaColor(isWhite: true, isBlue: true, isGreen: true)
        #expect(bant.colorIdentity == "WUG")
        #expect(bant.isMulticolored)
        
        let esper = ManaColor(isWhite: true, isBlue: true, isBlack: true)
        #expect(esper.colorIdentity == "WUB")
        #expect(esper.isMulticolored)
        
        // Wedges (enemy three-color combinations)
        let abzan = ManaColor(
            isWhite: true,
            isBlack: true,
            isGreen: true
        )
        #expect(abzan.colorIdentity == "WBG")
        #expect(abzan.isMulticolored)

        let jeskai = ManaColor(
            isWhite: true,
            isBlue: true,
            isRed: true
        )
        #expect(jeskai.colorIdentity == "URW")
        #expect(jeskai.isMulticolored)

        let sultai = ManaColor(
            isBlue: true,
            isBlack: true,
            isGreen: true
        )
        #expect(sultai.colorIdentity == "BGU")
        #expect(sultai.isMulticolored)

        let mardu = ManaColor(
            isWhite: true,
            isBlack: true,
            isRed: true
        )
        #expect(mardu.colorIdentity == "RWB")
        #expect(mardu.isMulticolored)

        let temur = ManaColor(
            isBlue: true,
            isRed: true,
            isGreen: true
        )
        #expect(temur.colorIdentity == "GUR")
        #expect(temur.isMulticolored)
        
        // Four-color
        let nonGreen = ManaColor(isWhite: true, isBlue: true, isBlack: true, isRed: true)
        #expect(nonGreen.colorIdentity == "WUBR")
        #expect(nonGreen.isMulticolored)
        
        // Five-color
        let allColors = ManaColor(isWhite: true, isBlue: true, isBlack: true, isRed: true, isGreen: true)
        #expect(allColors.colorIdentity == "WUBRG")
        #expect(allColors.isMulticolored)
        
        // Colorless
        let colorless = ManaColor(isColorless: true)
        #expect(colorless.colorIdentity == "C")
        #expect(!colorless.isMulticolored)
        #expect(!colorless.isMonocolored)
    }
    
    /// Test setting and checking various Magic specific color combinations
    @Test func testMagicColorCombinations() {
        var jeskai = ManaColor()
        jeskai.set(from: "URW")
        #expect(jeskai.colorCount == 3)
        #expect(jeskai.colorIdentity == "URW" || jeskai.colorIdentity == "WUR") // Order might differ
        
        var grixis = ManaColor()
        grixis.set(from: "UBR")
        #expect(grixis.colorCount == 3)
        #expect(grixis.colorIdentity.contains("U"))
        #expect(grixis.colorIdentity.contains("B"))
        #expect(grixis.colorIdentity.contains("R"))
        
        var fiveColor = ManaColor()
        fiveColor.set(from: "WUBRG")
        #expect(fiveColor.colorCount == 5)
        #expect(fiveColor.isMulticolored)
        
        var hybrid = ManaColor()
        hybrid.set(from: "W/U")
        #expect(hybrid.colorCount == 2)
        #expect(hybrid.isWhite)
        #expect(hybrid.isBlue)
    }
}
