import Foundation

/// Types of Magic: The Gathering sets
public enum MTGSetType: String, Codable, Sendable {
    case core = "core"
    case expansion = "expansion"
    case masters = "masters"
    case draft_innovation = "draft_innovation"
    case funny = "funny"
    case starter = "starter"
    case box = "box"
    case promo = "promo"
    case token = "token"
    case memorabilia = "memorabilia"
    case commander = "commander"
    case planechase = "planechase"
    case archenemy = "archenemy"
    case vanguard = "vanguard"
    case treasure_chest = "treasure_chest"
    case conspiracy = "conspiracy"
    case masterpiece = "masterpiece"
    case from_the_vault = "from_the_vault"
    case premium_deck = "premium_deck"
    case duel_deck = "duel_deck"
    case spellbook = "spellbook"
    case remastered = "remastered"
    case minigame = "minigame"
    case arsenal = "arsenal"
    case alchemy = "alchemy"
    case universes_beyond = "universes_beyond"
    case unknown = "unknown"

    /// Human readable name for display
    public var displayName: String {
        switch self {
        case .core: return "Core Set"
        case .expansion: return "Expansion"
        case .masters: return "Masters"
        case .draft_innovation: return "Draft Innovation"
        case .funny: return "Un-set"
        case .starter: return "Starter"
        case .box: return "Box Set"
        case .promo: return "Promotional"
        case .token: return "Token"
        case .memorabilia: return "Memorabilia"
        case .commander: return "Commander"
        case .planechase: return "Planechase"
        case .archenemy: return "Archenemy"
        case .vanguard: return "Vanguard"
        case .treasure_chest: return "Treasure Chest"
        case .conspiracy: return "Conspiracy"
        case .masterpiece: return "Masterpiece"
        case .from_the_vault: return "From the Vault"
        case .premium_deck: return "Premium Deck"
        case .duel_deck: return "Duel Deck"
        case .spellbook: return "Spellbook"
        case .remastered: return "Remastered"
        case .minigame: return "Minigame"
        case .arsenal: return "Arsenal"
        case .alchemy: return "Alchemy"
        case .universes_beyond: return "Universes Beyond"
        case .unknown: return "Unknown"
        }
    }

    /// Whether this set type is considered a premier set (Standard-legal)
    public var isPremier: Bool {
        switch self {
        case .core, .expansion:
            return true
        case .universes_beyond:
            // After June 2025, Universes Beyond sets are premier sets
            return Date() > FormatDates.ubInStandardStart
        default:
            return false
        }
    }
}
