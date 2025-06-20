import Testing

@testable import Card

/// Tests for the ManaType enum
struct ManaTypeTests {

    /// Test that all color types are properly defined
    @Test func testManaTypeDefinition() {
        // Verify all mana types
        let manaTypes = ManaType.allCases

        #expect(manaTypes.count == 6, "ManaType should have 6 cases")
        #expect(manaTypes.contains(.red), "ManaType should contain red")
        #expect(manaTypes.contains(.green), "ManaType should contain green")
        #expect(manaTypes.contains(.black), "ManaType should contain black")
        #expect(manaTypes.contains(.blue), "ManaType should contain blue")
        #expect(manaTypes.contains(.white), "ManaType should contain white")
        #expect(manaTypes.contains(.colorless), "ManaType should contain colorless")
    }

    /// Test the raw string values of mana types
    @Test func testRawValues() {
        #expect(ManaType.red.rawValue == "R", "Red mana type should have raw value R")
        #expect(ManaType.green.rawValue == "G", "Green mana type should have raw value G")
        #expect(ManaType.black.rawValue == "B", "Black mana type should have raw value B")
        #expect(ManaType.blue.rawValue == "U", "Blue mana type should have raw value U")
        #expect(ManaType.white.rawValue == "W", "White mana type should have raw value W")
        #expect(
            ManaType.colorless.rawValue == "C", "Colorless mana type should have empty raw value")
    }

    /// Test initialization from raw values
    @Test func testInitFromRawValue() {
        #expect(ManaType(rawValue: "R") == .red, "Should create red from R")
        #expect(ManaType(rawValue: "G") == .green, "Should create green from G")
        #expect(ManaType(rawValue: "B") == .black, "Should create black from B")
        #expect(ManaType(rawValue: "U") == .blue, "Should create blue from U")
        #expect(ManaType(rawValue: "W") == .white, "Should create white from W")
        #expect(ManaType(rawValue: "") == nil, "Should not create anything from empty string")
        #expect(ManaType(rawValue: "X") == nil, "Should not create anything from invalid string")
    }

    /// Test the isColor property
    @Test func testIsColor() {
        #expect(ManaType.red.isColor, "Red should be a color")
        #expect(ManaType.green.isColor, "Green should be a color")
        #expect(ManaType.black.isColor, "Black should be a color")
        #expect(ManaType.blue.isColor, "Blue should be a color")
        #expect(ManaType.white.isColor, "White should be a color")
        #expect(!ManaType.colorless.isColor, "Colorless should not be a color")
    }

    /// Test for WUBRG order
    @Test func testWUBRGOrder() {
        let sortedColors = ManaType.allCases
            .filter { $0.isColor }
            .sorted { $0.rawValue < $1.rawValue }

        // WUBRG order is typically alphabetical by single-letter code
        #expect(sortedColors[0] == .black, "B (black) should be first alphabetically")
        #expect(sortedColors[1] == .green, "G (green) should be second alphabetically")
        #expect(sortedColors[2] == .red, "R (red) should be third alphabetically")
        #expect(sortedColors[3] == .blue, "U (blue) should be fourth alphabetically")
        #expect(sortedColors[4] == .white, "W (white) should be fifth alphabetically")
    }

    /// Test equality and comparison
    @Test func testEquality() {
        let red1 = ManaType.red
        let red2 = ManaType.red
        let blue = ManaType.blue

        #expect(red1 == red2, "Same mana types should be equal")
        #expect(red1 != blue, "Different mana types should not be equal")
    }

    /// Test conformance to CaseIterable
    @Test func testCaseIterable() {
        let allCases = ManaType.allCases

        #expect(allCases.count == 6, "Should have 6 cases")

        // Verify we can iterate through all cases
        var foundTypes: [ManaType] = []
        for manaType in ManaType.allCases {
            foundTypes.append(manaType)
        }

        #expect(foundTypes.count == 6, "Should find all 6 cases when iterating")
    }

    /// Test String representation
    @Test func testStringRepresentation() {
        #expect(String(describing: ManaType.red) == "red", "String description should be 'red'")
        #expect(
            String(describing: ManaType.green) == "green", "String description should be 'green'")
        #expect(
            String(describing: ManaType.black) == "black", "String description should be 'black'")
        #expect(String(describing: ManaType.blue) == "blue", "String description should be 'blue'")
        #expect(
            String(describing: ManaType.white) == "white", "String description should be 'white'")
        #expect(
            String(describing: ManaType.colorless) == "colorless",
            "String description should be 'colorless'")
    }

    /// Test filtering colors vs. colorless
    @Test func testFilteringColors() {
        let allTypes = ManaType.allCases
        let onlyColors = allTypes.filter { $0.isColor }
        let onlyColorless = allTypes.filter { !$0.isColor }

        #expect(onlyColors.count == 5, "Should have 5 color types")
        #expect(onlyColorless.count == 1, "Should have 1 colorless type")
        #expect(onlyColorless[0] == .colorless, "The colorless type should be .colorless")
    }
}
