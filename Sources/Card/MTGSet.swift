import Foundation

/// Represents a Magic: The Gathering set
public struct MTGSet: Identifiable, Equatable, Hashable, Codable, Sendable {
    // MARK: - Properties
    
    /// Unique identifier for the set
    public var id = UUID()
    
    /// Set name (e.g., "Throne of Eldraine")
    public var name: String = ""
    
    /// Set code (e.g., "ELD")
    public var code: String = ""
    
    /// Type of set (core, expansion, etc.)
    public var type: MTGSetType = .unknown
    
    /// Release date of the set
    public var releaseDate: Date?
    
    /// Number of cards in the set
    public var cardCount: Int = 0
    
    /// Whether this set is digital-only (like on Arena)
    public var isDigital: Bool = false
    
    /// The block this set belongs to (if any)
    public var block: String?
    
    // MARK: - Computed Properties
    
    /// Gets the uppercase set code
    public var abbreviation: String {
        return code.uppercased()
    }
    
    /// Whether this set is legal in Standard format
    public var isStandardLegal: Bool {
        guard let releaseDate = releaseDate else {
            return false
        }
        
        // A set is Standard legal if:
        // 1. It's a premier set (core or expansion)
        // 2. It's not too old (generally within ~2 years)
        if type.isPremier {
            // Consider sets from the last 2 years to be Standard legal
            // This is a simplification - in reality, Standard rotation is more complex
            let twoYearsAgo = Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date()
            return releaseDate > twoYearsAgo
        }
        
        return false
    }
    
    /// Whether this set is legal in Modern format
    public var isModernLegal: Bool {
        guard let releaseDate = releaseDate else {
            return false
        }
        
        // Modern format starts from 8th Edition (July 2003)
        let modernStartDate = Date(timeIntervalSince1970: 1057017600) // July 2003
        
        // Only premier sets are Modern legal
        return type.isPremier && releaseDate >= modernStartDate
    }
    
    /// Whether this set is legal in Legacy format
    public var isLegacyLegal: Bool {
        // Almost all sets are Legacy legal except for special sets like Universes Beyond before June 2025
        return true
    }
    
    /// Whether this set is legal in Vintage format
    public var isVintageLegal: Bool {
        // Almost all sets are Vintage legal
        return true
    }
    
    /// Whether this set is legal in Commander format
    public var isCommanderLegal: Bool {
        // Commander generally follows Vintage legality with some exceptions
        return true
    }
    
    // MARK: - Initialization
    
    /// Creates a new empty set
    public init() {}
    
    /// Creates a set with specified properties
    public init(
        name: String = "",
        code: String = "",
        type: MTGSetType = .unknown,
        releaseDate: Date? = nil,
        cardCount: Int = 0,
        isDigital: Bool = false,
        block: String? = nil
    ) {
        self.name = name
        self.code = code
        self.type = type
        self.releaseDate = releaseDate
        self.cardCount = cardCount
        self.isDigital = isDigital
        self.block = block
    }
    
    // MARK: - Methods
    
    /// Gets a URL for the set icon with the specified rarity variant
    public func iconURL(variant: Rarity) -> URL? {
        // Base URL for set icons
        let baseURLString = "https://gatherer.wizards.com/Handlers/Image.ashx?type=symbol"
        
        // Construct URL based on set code and rarity
        var urlComponents = URLComponents(string: baseURLString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "set", value: abbreviation),
            URLQueryItem(name: "rarity", value: variant.rawValue.lowercased()),
            URLQueryItem(name: "size", value: "medium")
        ]
        
        return urlComponents?.url
    }
    
    // MARK: - Protocol Conformance
    
    /// Equatable conformance
    public static func == (lhs: MTGSet, rhs: MTGSet) -> Bool {
        return lhs.code == rhs.code
    }
    
    /// Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
}


// MARK: - Universe Enum

/// Represents the universe or IP a set belongs to
public enum Universe: String, Codable, Sendable, CaseIterable {
    case magic = "Magic: The Gathering"
    case lordOfTheRings = "The Lord of the Rings"
    case warhammer40k = "Warhammer 40,000"
    case doctorWho = "Doctor Who"
    case fallout = "Fallout"
    case assassinsCreed = "Assassin's Creed"
    case finalFantasy = "Final Fantasy"
    case marvel = "Marvel"
    case spiderMan = "Spider-Man"
    case avatarLastAirbender = "Avatar: The Last Airbender"
    case starWars = "Star Wars"
    case tmnt = "Teenage Mutant Ninja Turtles"
    case strangerThings = "Stranger Things"
    case walkingDead = "The Walking Dead"
    case streetFighter = "Street Fighter"
    case fortnite = "Fortnite"
    case transformers = "Transformers"
    case other = "Other IP"

    /// Determine the universe from a set name
    public static func determineFromName(_ name: String) -> Universe {
        let lowercaseName = name.lowercased()

        if lowercaseName.contains("magic") || !name.contains(":") {
            return .magic
        } else if lowercaseName.contains("lord of the rings")
            || lowercaseName.contains("middle-earth")
        {
            return .lordOfTheRings
        } else if lowercaseName.contains("warhammer") {
            return .warhammer40k
        } else if lowercaseName.contains("doctor who") {
            return .doctorWho
        } else if lowercaseName.contains("fallout") {
            return .fallout
        } else if lowercaseName.contains("assassin's creed") {
            return .assassinsCreed
        } else if lowercaseName.contains("final fantasy") {
            return .finalFantasy
        } else if lowercaseName.contains("spider-man") {
            return .spiderMan
        } else if lowercaseName.contains("marvel") {
            return .marvel
        } else if lowercaseName.contains("avatar") && lowercaseName.contains("airbender") {
            return .avatarLastAirbender
        } else if lowercaseName.contains("star wars") {
            return .starWars
        } else if lowercaseName.contains("teenage mutant")
            || lowercaseName.contains("ninja turtles") || lowercaseName.contains("tmnt")
        {
            return .tmnt
        } else if lowercaseName.contains("stranger things") {
            return .strangerThings
        } else if lowercaseName.contains("walking dead") {
            return .walkingDead
        } else if lowercaseName.contains("street fighter") {
            return .streetFighter
        } else if lowercaseName.contains("fortnite") {
            return .fortnite
        } else if lowercaseName.contains("transformers") {
            return .transformers
        }

        return .other
    }
}

// MARK: - Format Dates (static information about format date boundaries)

/// Contains date constants important for format legality
public enum FormatDates {
    /// June 13, 2025: Beginning of Universes Beyond sets being legal in all formats
    public static let ubInStandardStart = dateFromComponents(year: 2025, month: 6, day: 13)

    /// October 5, 2012: Release of Return to Ravnica (first Pioneer-legal set)
    public static let pioneerStart = dateFromComponents(year: 2012, month: 10, day: 5)

    /// July 29, 2003: Release of 8th Edition (first Modern-legal set)
    public static let modernStart = dateFromComponents(year: 2003, month: 7, day: 29)

    /// Helper to create dates from components
    private static func dateFromComponents(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }

    /// Calculate the date of the next Standard rotation
    public static func getNextStandardRotation(after date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)

        // Prior to 2027, rotation happens with the fall set (Q3/Q4)
        if components.year ?? 2025 < 2027 {
            // Fall rotation (typically September/October)
            if let year = components.year {
                // If we're past October, rotation is next year
                if components.month ?? 1 >= 10 {
                    components.year = year + 1
                }
                components.month = 9
                components.day = 15  // Approximation
            }
        } else {
            // From 2027, rotation happens with the first set of the year (Q1)
            if let year = components.year {
                // If we're in Q1, rotation is this year, otherwise next year
                if components.month ?? 1 > 3 {
                    components.year = year + 1
                }
                components.month = 1
                components.day = 15  // Approximation
            }
        }

        return calendar.date(from: components) ?? date
    }

    /// Calculate the start date for the current Standard format
    public static func getStandardStartDate(for date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)

        // Standard typically includes sets from the past 1-2 years
        if let year = components.year {
            components.year = year - 2
        }

        return calendar.date(from: components) ?? date
    }
}
