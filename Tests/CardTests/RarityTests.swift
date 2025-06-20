import Testing

@testable import Card

/// Tests for the Rarity enum
struct RarityTests {

    // MARK: - Basic Enum Tests

    /// Test the basic properties of the Rarity enum
    @Test func testRarityEnum() {
        // Test that we have the expected number of cases
        #expect(Rarity.allCases.count == 5, "Rarity should have exactly 5 cases")

        // Test that all expected cases exist
        #expect(Rarity.allCases.contains(.common), "Rarity should contain common")
        #expect(Rarity.allCases.contains(.uncommon), "Rarity should contain uncommon")
        #expect(Rarity.allCases.contains(.rare), "Rarity should contain rare")
        #expect(Rarity.allCases.contains(.mythic), "Rarity should contain mythic")
        #expect(Rarity.allCases.contains(.unknown), "Rarity should contain unknown")
    }

    /// Test raw values for each rarity type
    @Test func testRawValues() {
        #expect(Rarity.common.rawValue == "common")
        #expect(Rarity.uncommon.rawValue == "uncommon")
        #expect(Rarity.rare.rawValue == "rare")
        #expect(Rarity.mythic.rawValue == "mythic")
        #expect(Rarity.unknown.rawValue == "unknown")
    }

    // MARK: - Initialization Tests

    /// Test initialization with exact lowercase strings
    @Test func testExactLowercaseInitialization() {
        #expect(Rarity(from: "common") == .common)
        #expect(Rarity(from: "uncommon") == .uncommon)
        #expect(Rarity(from: "rare") == .rare)
        #expect(Rarity(from: "mythic") == .mythic)
    }

    /// Test case-insensitive initialization
    @Test func testCaseInsensitiveInitialization() {
        #expect(Rarity(from: "COMMON") == .common)
        #expect(Rarity(from: "Uncommon") == .uncommon)
        #expect(Rarity(from: "RARE") == .rare)
        #expect(Rarity(from: "Mythic") == .mythic)
        #expect(Rarity(from: "MiXeD") == .unknown)
    }

    /// Test mythic rare variations
    @Test func testMythicRareVariations() {
        #expect(Rarity(from: "mythic_rare") == .mythic)
        #expect(Rarity(from: "mythic rare") == .mythic)
        #expect(Rarity(from: "MYTHIC_RARE") == .mythic)
        #expect(Rarity(from: "Mythic Rare") == .mythic)
    }

    /// Test unknown values
    @Test func testUnknownValues() {
        #expect(Rarity(from: "") == .unknown)
        #expect(Rarity(from: "super rare") == .unknown)
        #expect(Rarity(from: "special") == .unknown)
        #expect(Rarity(from: "123") == .unknown)
    }

    // MARK: - String Conversion Tests

    /// Test converting from Rarity to String
    @Test func testToString() {
        #expect(Rarity.common.toString() == "common")
        #expect(Rarity.uncommon.toString() == "uncommon")
        #expect(Rarity.rare.toString() == "rare")
        #expect(Rarity.mythic.toString() == "mythic")
        #expect(Rarity.unknown.toString() == "unknown")
    }

    /// Test the rawValue property matches toString() result
    @Test func testRawValueMatchesToString() {
        for rarity in Rarity.allCases {
            #expect(rarity.rawValue == rarity.toString(), "rawValue should match toString()")
        }
    }

    // MARK: - Comparison Tests

    /// Test equality for rarities
    @Test func testEquality() {
        #expect(Rarity.common == Rarity.common)
        #expect(Rarity(from: "common") == Rarity.common)
        #expect(Rarity(from: "COMMON") == Rarity.common)

        #expect(Rarity.common != Rarity.rare)
        #expect(Rarity(from: "common") != Rarity.uncommon)
    }

    // MARK: - Edge Cases

    /// Test initialization with strings that have whitespace
    @Test func testWhitespaceHandling() {
        #expect(Rarity(from: " common ") == .common)
        #expect(Rarity(from: "  uncommon  ") == .uncommon)
        #expect(Rarity(from: "\trare\n") == .rare)
    }

    /// Test initialization with strings that have unexpected characters
    @Test func testSpecialCharactersHandling() {
        #expect(Rarity(from: "common!") == .unknown)
        #expect(Rarity(from: "*uncommon*") == .unknown)
        #expect(Rarity(from: "rare.") == .unknown)
    }
}
