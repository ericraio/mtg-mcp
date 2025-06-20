import Foundation

/// Represents card rarity in Magic: The Gathering
public enum Rarity: String, CaseIterable, Codable, Sendable {
    case common = "common"
    case uncommon = "uncommon"
    case rare = "rare"
    case mythic = "mythic"
    case unknown = "unknown"

    /// Initialize a rarity from a string
    /// - Parameter string: The rarity string to parse
    public init(from string: String) {
        // Trim whitespace and convert to lowercase
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        switch trimmed {
        case "common":
            self = .common
        case "uncommon":
            self = .uncommon
        case "rare":
            self = .rare
        case "mythic", "mythic_rare", "mythic rare":
            self = .mythic
        default:
            self = .unknown
        }
    }

    /// Returns the string representation of the rarity
    public func toString() -> String {
        return self.rawValue
    }
}
