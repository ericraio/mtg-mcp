import Foundation
import Testing
@testable import Card  

/// Tests for the MTGSetType enum
struct MTGSetTypeTests {
    
    // MARK: - Enum Values Tests
    
    /// Test that all cases have the correct raw values
    @Test func testRawValues() {
        #expect(MTGSetType.core.rawValue == "core")
        #expect(MTGSetType.expansion.rawValue == "expansion")
        #expect(MTGSetType.masters.rawValue == "masters")
        #expect(MTGSetType.draft_innovation.rawValue == "draft_innovation")
        #expect(MTGSetType.funny.rawValue == "funny")
        #expect(MTGSetType.starter.rawValue == "starter")
        #expect(MTGSetType.box.rawValue == "box")
        #expect(MTGSetType.promo.rawValue == "promo")
        #expect(MTGSetType.token.rawValue == "token")
        #expect(MTGSetType.memorabilia.rawValue == "memorabilia")
        #expect(MTGSetType.commander.rawValue == "commander")
        #expect(MTGSetType.planechase.rawValue == "planechase")
        #expect(MTGSetType.archenemy.rawValue == "archenemy")
        #expect(MTGSetType.vanguard.rawValue == "vanguard")
        #expect(MTGSetType.treasure_chest.rawValue == "treasure_chest")
        #expect(MTGSetType.conspiracy.rawValue == "conspiracy")
        #expect(MTGSetType.masterpiece.rawValue == "masterpiece")
        #expect(MTGSetType.from_the_vault.rawValue == "from_the_vault")
        #expect(MTGSetType.premium_deck.rawValue == "premium_deck")
        #expect(MTGSetType.duel_deck.rawValue == "duel_deck")
        #expect(MTGSetType.spellbook.rawValue == "spellbook")
        #expect(MTGSetType.remastered.rawValue == "remastered")
        #expect(MTGSetType.minigame.rawValue == "minigame")
        #expect(MTGSetType.arsenal.rawValue == "arsenal")
        #expect(MTGSetType.alchemy.rawValue == "alchemy")
        #expect(MTGSetType.universes_beyond.rawValue == "universes_beyond")
        #expect(MTGSetType.unknown.rawValue == "unknown")
    }
    
    /// Test initialization from raw value
    @Test func testInitFromRawValue() {
        #expect(MTGSetType(rawValue: "core") == .core)
        #expect(MTGSetType(rawValue: "expansion") == .expansion)
        #expect(MTGSetType(rawValue: "masters") == .masters)
        #expect(MTGSetType(rawValue: "draft_innovation") == .draft_innovation)
        #expect(MTGSetType(rawValue: "funny") == .funny)
        #expect(MTGSetType(rawValue: "starter") == .starter)
        #expect(MTGSetType(rawValue: "box") == .box)
        #expect(MTGSetType(rawValue: "promo") == .promo)
        #expect(MTGSetType(rawValue: "token") == .token)
        #expect(MTGSetType(rawValue: "memorabilia") == .memorabilia)
        #expect(MTGSetType(rawValue: "commander") == .commander)
        #expect(MTGSetType(rawValue: "planechase") == .planechase)
        #expect(MTGSetType(rawValue: "archenemy") == .archenemy)
        #expect(MTGSetType(rawValue: "vanguard") == .vanguard)
        #expect(MTGSetType(rawValue: "treasure_chest") == .treasure_chest)
        #expect(MTGSetType(rawValue: "conspiracy") == .conspiracy)
        #expect(MTGSetType(rawValue: "masterpiece") == .masterpiece)
        #expect(MTGSetType(rawValue: "from_the_vault") == .from_the_vault)
        #expect(MTGSetType(rawValue: "premium_deck") == .premium_deck)
        #expect(MTGSetType(rawValue: "duel_deck") == .duel_deck)
        #expect(MTGSetType(rawValue: "spellbook") == .spellbook)
        #expect(MTGSetType(rawValue: "remastered") == .remastered)
        #expect(MTGSetType(rawValue: "minigame") == .minigame)
        #expect(MTGSetType(rawValue: "arsenal") == .arsenal)
        #expect(MTGSetType(rawValue: "alchemy") == .alchemy)
        #expect(MTGSetType(rawValue: "universes_beyond") == .universes_beyond)
        #expect(MTGSetType(rawValue: "unknown") == .unknown)
        
        // Test invalid raw value
        #expect(MTGSetType(rawValue: "invalid_value") == nil)
    }
    
    // MARK: - Display Name Tests
    
    /// Test display names for all set types
    @Test func testDisplayNames() {
        #expect(MTGSetType.core.displayName == "Core Set")
        #expect(MTGSetType.expansion.displayName == "Expansion")
        #expect(MTGSetType.masters.displayName == "Masters")
        #expect(MTGSetType.draft_innovation.displayName == "Draft Innovation")
        #expect(MTGSetType.funny.displayName == "Un-set")
        #expect(MTGSetType.starter.displayName == "Starter")
        #expect(MTGSetType.box.displayName == "Box Set")
        #expect(MTGSetType.promo.displayName == "Promotional")
        #expect(MTGSetType.token.displayName == "Token")
        #expect(MTGSetType.memorabilia.displayName == "Memorabilia")
        #expect(MTGSetType.commander.displayName == "Commander")
        #expect(MTGSetType.planechase.displayName == "Planechase")
        #expect(MTGSetType.archenemy.displayName == "Archenemy")
        #expect(MTGSetType.vanguard.displayName == "Vanguard")
        #expect(MTGSetType.treasure_chest.displayName == "Treasure Chest")
        #expect(MTGSetType.conspiracy.displayName == "Conspiracy")
        #expect(MTGSetType.masterpiece.displayName == "Masterpiece")
        #expect(MTGSetType.from_the_vault.displayName == "From the Vault")
        #expect(MTGSetType.premium_deck.displayName == "Premium Deck")
        #expect(MTGSetType.duel_deck.displayName == "Duel Deck")
        #expect(MTGSetType.spellbook.displayName == "Spellbook")
        #expect(MTGSetType.remastered.displayName == "Remastered")
        #expect(MTGSetType.minigame.displayName == "Minigame")
        #expect(MTGSetType.arsenal.displayName == "Arsenal")
        #expect(MTGSetType.alchemy.displayName == "Alchemy")
        #expect(MTGSetType.universes_beyond.displayName == "Universes Beyond")
        #expect(MTGSetType.unknown.displayName == "Unknown")
    }
    
    // MARK: - Premier Set Tests
    
    /// Test isPremier property for premier sets
    @Test func testIsPremierForPremierSets() {
        #expect(MTGSetType.core.isPremier)
        #expect(MTGSetType.expansion.isPremier)
    }
    
    /// Test isPremier property for non-premier sets
    @Test func testIsPremierForNonPremierSets() {
        #expect(!MTGSetType.masters.isPremier)
        #expect(!MTGSetType.draft_innovation.isPremier)
        #expect(!MTGSetType.funny.isPremier)
        #expect(!MTGSetType.starter.isPremier)
        #expect(!MTGSetType.box.isPremier)
        #expect(!MTGSetType.promo.isPremier)
        #expect(!MTGSetType.token.isPremier)
        #expect(!MTGSetType.memorabilia.isPremier)
        #expect(!MTGSetType.commander.isPremier)
        #expect(!MTGSetType.planechase.isPremier)
        #expect(!MTGSetType.archenemy.isPremier)
        #expect(!MTGSetType.vanguard.isPremier)
        #expect(!MTGSetType.treasure_chest.isPremier)
        #expect(!MTGSetType.conspiracy.isPremier)
        #expect(!MTGSetType.masterpiece.isPremier)
        #expect(!MTGSetType.from_the_vault.isPremier)
        #expect(!MTGSetType.premium_deck.isPremier)
        #expect(!MTGSetType.duel_deck.isPremier)
        #expect(!MTGSetType.spellbook.isPremier)
        #expect(!MTGSetType.remastered.isPremier)
        #expect(!MTGSetType.minigame.isPremier)
        #expect(!MTGSetType.arsenal.isPremier)
        #expect(!MTGSetType.alchemy.isPremier)
        #expect(!MTGSetType.unknown.isPremier)
    }
    
    /// Test isPremier property for universes_beyond set based on date
    @Test func testIsPremierForUniversesBeyond() {
        // Create a mock FormatDates for testing
        struct MockFormatDates {
            static let ubInStandardStart = Date(timeIntervalSince1970: 1751328000) // June 1, 2025
        }
        
        // Test with a date before June 2025
        let beforeUbDate = Date(timeIntervalSince1970: 1751000000) // Before June 1, 2025
        
        // Swizzle or replace FormatDates.ubInStandardStart for test
        // This would require more setup in a real test environment
        // For now, we'll just test the logic based on the current date
        
        // The actual test would vary depending on the current date
        // We need to either mock the Date() or FormatDates.ubInStandardStart
        
        // For demonstration, assuming current date is before June 2025:
        if Date() < MockFormatDates.ubInStandardStart {
            #expect(!MTGSetType.universes_beyond.isPremier)
        } else {
            #expect(MTGSetType.universes_beyond.isPremier)
        }
    }
    
    // MARK: - Codable Tests
    
    /// Test encoding and decoding MTGSetType
    @Test func testCodable() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        for setType in [
            MTGSetType.core,
            MTGSetType.expansion,
            MTGSetType.masters,
            MTGSetType.commander,
            MTGSetType.universes_beyond,
            MTGSetType.unknown
        ] {
            do {
                let encoded = try encoder.encode(setType)
                let decoded = try decoder.decode(MTGSetType.self, from: encoded)
                #expect(decoded == setType)
            } catch {
                #expect(false, "Failed to encode/decode \(setType): \(error)")
            }
        }
    }
}
