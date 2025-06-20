import Card
import Foundation
import Scryfall

/// Comprehensive land detection service based on swift-landlord implementation
public struct LandDetectionService {

    /// Special lands that need manual override for mana production
    public static let SPECIAL_LANDS: [String: [String]] = [
        // Utility Lands - produce colorless
        "Slayers' Stronghold": ["C"],
        "Alchemist's Refuge": ["C"],
        "Desolate Lighthouse": ["C"],
        "Ancient Tomb": ["C"],
        "Strip Mine": [],
        "Wasteland": [],
        "Cabal Coffers": ["B"],
        "Urborg, Tomb of Yawgmoth": ["B"],
        "Shizo, Death's Storehouse": ["B"],
        "Eiganjo Castle": ["W"],
        "Minamo, School at Water's Edge": ["U"],
        "Okina, Temple to the Grandfathers": ["G"],
        "Thespian's Stage": ["C"],
        "Dark Depths": [],
        "Inkmoth Nexus": ["C"],
        "Boseiju, Who Shelters All": ["C"],
        "Cavern of Souls": ["C"],
        "Rishadan Port": ["C"],
        "Mutavault": ["C"],
        "Maze of Ith": [],
        "Academy Ruins": ["C"],
        "Buried Ruin": ["C"],
        "Inventors' Fair": ["C"],
        "Tower of the Magistrate": ["C"],
        "Dust Bowl": [],
        "Ghost Quarter": [],
        "Tectonic Edge": [],
        "Field of Ruin": [],

        // Fetch Lands - can find multiple colors
        "Arid Mesa": ["W", "R"],
        "Bloodstained Mire": ["B", "R"],
        "Flooded Strand": ["W", "U"],
        "Marsh Flats": ["W", "B"],
        "Misty Rainforest": ["U", "G"],
        "Polluted Delta": ["U", "B"],
        "Scalding Tarn": ["U", "R"],
        "Verdant Catacombs": ["B", "G"],
        "Windswept Heath": ["W", "G"],
        "Wooded Foothills": ["R", "G"],
        "Fabled Passage": ["W", "U", "B", "R", "G"],
        "Evolving Wilds": ["W", "U", "B", "R", "G"],
        "Terramorphic Expanse": ["W", "U", "B", "R", "G"],
        "Prismatic Vista": ["W", "U", "B", "R", "G"],

        // Command Zone Lands
        "Command Tower": ["W", "U", "B", "R", "G"],
        "Path of Ancestry": ["W", "U", "B", "R", "G"],
        "Exotic Orchard": ["W", "U", "B", "R", "G"],
        "Reflecting Pool": ["W", "U", "B", "R", "G"],
        "City of Brass": ["W", "U", "B", "R", "G"],
        "Mana Confluence": ["W", "U", "B", "R", "G"],
        "Grand Coliseum": ["W", "U", "B", "R", "G"],

        // Basic Lands
        "Plains": ["W"],
        "Island": ["U"],
        "Swamp": ["B"],
        "Mountain": ["R"],
        "Forest": ["G"],
        "Wastes": ["C"],

        // Snow Basics
        "Snow-Covered Plains": ["W"],
        "Snow-Covered Island": ["U"],
        "Snow-Covered Swamp": ["B"],
        "Snow-Covered Mountain": ["R"],
        "Snow-Covered Forest": ["G"],

        // Pathway cycle lands (both faces)
        "Hengegate Pathway": ["W", "U"],
        "Mistgate Pathway": ["W", "U"],
        "Riverglide Pathway": ["U", "R"],
        "Lavaglide Pathway": ["U", "R"],
        "Cragcrown Pathway": ["B", "R"],
        "Timbercrown Pathway": ["B", "G"],
        "Needleverge Pathway": ["R", "W"],
        "Pillarverge Pathway": ["R", "W"],
        "Clearwater Pathway": ["W", "U"],
        "Murkwater Pathway": ["U", "B"],
        "Brightclimb Pathway": ["W", "B"],
        "Grimclimb Pathway": ["W", "B"],
    ]

    /// Basic land names for quick identification
    private static let basicLandNames = Set([
        "Plains", "Island", "Swamp", "Mountain", "Forest", "Wastes",
        "Snow-Covered Plains", "Snow-Covered Island", "Snow-Covered Swamp",
        "Snow-Covered Mountain", "Snow-Covered Forest",
    ])

    /// Keywords that strongly indicate a land card
    private static let landKeywords = [
        "Plains", "Island", "Swamp", "Mountain", "Forest",
        "Command Tower", "Path of Ancestry", "Exotic Orchard",
        "Temple", "Guildgate", "Shockland", "Fetchland", "Basic",
        "Wastes", "Cave", "Tower", "Sanctuary", "Citadel",
        "Lagoon", "Catacombs", "Heath", "Mesa", "Tarn",
        "Mire", "Strand", "Flats", "Rainforest", "Delta",
        "enters the battlefield", "tapped", "untapped",
    ]

    /// Modal Double-Faced Card patterns (spell // land)
    private static let mdflPatterns = [
        " // ",  // Generic MDFC separator
        "Malakir Rebirth", "Turntimber Symbiosis", "Ondu Inversion",
        "Emeria's Call", "Sea Gate Restoration", "Shatterskull Smashing",
        "Spikefield Hazard", "Khalni Ambush", "Bala Ged Recovery",
        "Tangled Florahedron", "Jwari Disruption", "Hagra Mauling",
        "Pelakka Predation", "Makindi Stampede", "Zof Consumption",
        "Valakut Awakening", "Silundi Vision", "Umara Wizard",
        // Zendikar Rising MDFCs
        "Cosima, God of the Voyage", "Sink into Stupor", "Sundering Eruption",
        // Pathway cycle (both sides are lands)
        "Hengegate Pathway", "Mistgate Pathway", "Riverglide Pathway", "Lavaglide Pathway",
        "Cragcrown Pathway", "Timbercrown Pathway", "Needleverge Pathway", "Pillarverge Pathway",
        "Clearwater Pathway", "Murkwater Pathway", "Brightclimb Pathway", "Grimclimb Pathway",
        // Add more known MDFCs
        "Fabled Passage", "Sejiri Shelter", "Kabira Takedown",
    ]

    /// Known MDFC land faces for better detection
    private static let mdfcLandFaces = [
        "Malakir Mire", "Turntimber, Serpentine Wood", "Ondu Skyruins",
        "Emeria, the Sky Ruin", "Sea Gate, Reborn", "Shatterskull, the Hammer Pass",
        "Spikefield Cave", "Khalni Territory", "Bala Ged Sanctuary",
        "Tangled Vale", "Jwari Ruins", "Hagra Broodpit",
        "Pelakka Caverns", "Makindi Stomping Grounds", "Zof Bloodbog",
        "Valakut Stoneforge", "Silundi Isle", "Umara Skyfalls",
        "The Omenkeel", "Soporific Springs", "Volcanic Fissure",
        "Sejiri Glacier", "Kabira Plateau",
        // Pathway cycle land faces
        "Hengegate Pathway", "Mistgate Pathway", "Riverglide Pathway", "Lavaglide Pathway",
        "Cragcrown Pathway", "Timbercrown Pathway", "Needleverge Pathway", "Pillarverge Pathway",
        "Clearwater Pathway", "Murkwater Pathway", "Brightclimb Pathway", "Grimclimb Pathway",
    ]

    /// Primary land detection function
    public static func isLand(_ cardName: String) -> Bool {
        let name = cardName.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check special lands database first
        if SPECIAL_LANDS.keys.contains(name) {
            return true
        }

        // Check basic lands
        if basicLandNames.contains(name) {
            return true
        }

        // Check for MDFC lands
        if isMDFCLand(name) {
            return true
        }

        // Pattern-based detection
        return isLandByPattern(name)
    }

    /// Determines if a card is a Modal Double-Faced Card with a land back
    public static func isMDFCLand(_ cardName: String) -> Bool {
        // Check if it's a full MDFC name format
        if cardName.contains(" // ") {
            let faces = cardName.components(separatedBy: " // ")
            if faces.count == 2 {
                let backFace = faces[1].trimmingCharacters(in: .whitespaces)
                // Check if back face is a known land face or matches land patterns
                return mdfcLandFaces.contains(backFace) || isLandByPattern(backFace)
            }
        }

        // Check against known MDFC front faces
        for pattern in mdflPatterns {
            if cardName.contains(pattern) {
                return true
            }
        }

        // Check if it's a known land face name
        return mdfcLandFaces.contains(cardName)
    }

    /// Pattern-based land detection for unknown cards
    private static func isLandByPattern(_ cardName: String) -> Bool {
        let lowerName = cardName.lowercased()

        for keyword in landKeywords {
            if lowerName.contains(keyword.lowercased()) {
                return true
            }
        }

        // Check for guild land patterns
        if lowerName.contains("guild") && lowerName.contains("gate") {
            return true
        }

        // Check for common dual land patterns
        let dualPatterns = [
            "temple of", "sacred foundry", "steam vents", "overgrown tomb",
            "watery grave", "godless shrine", "stomping ground", "breeding pool",
            "hallowed fountain", "blood crypt", "stomping ground",
        ]

        for pattern in dualPatterns {
            if lowerName.contains(pattern) {
                return true
            }
        }

        return false
    }

    /// Gets the land category for classification
    public static func getLandCategory(_ cardName: String) -> LandCategory {
        let name = cardName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard isLand(name) else { return .none }

        // Basic lands
        if basicLandNames.contains(name) {
            return .basic
        }

        // MDFC lands
        if isMDFCLand(name) {
            return .mdfc
        }

        // Fetch lands
        if isFetchLand(name) {
            return .fetch
        }

        // Shock lands (simplified detection)
        let shockLands = [
            "Sacred Foundry", "Steam Vents", "Overgrown Tomb", "Watery Grave",
            "Godless Shrine", "Stomping Ground", "Breeding Pool", "Hallowed Fountain",
            "Blood Crypt", "Temple Garden",
        ]
        if shockLands.contains(name) {
            return .shock
        }

        // Utility lands
        if isUtilityLand(name) {
            return .utility
        }

        return .other
    }

    /// Determines if this is a fetch land
    private static func isFetchLand(_ cardName: String) -> Bool {
        let fetchLands = [
            "Arid Mesa", "Bloodstained Mire", "Flooded Strand", "Marsh Flats",
            "Misty Rainforest", "Polluted Delta", "Scalding Tarn", "Verdant Catacombs",
            "Windswept Heath", "Wooded Foothills", "Fabled Passage", "Evolving Wilds",
            "Terramorphic Expanse", "Prismatic Vista",
        ]
        return fetchLands.contains(cardName)
    }

    /// Determines if this is a utility land
    private static func isUtilityLand(_ cardName: String) -> Bool {
        let utilityLands = [
            "Ancient Tomb", "Strip Mine", "Wasteland", "Cabal Coffers", "Urborg",
            "Shizo", "Eiganjo", "Minamo", "Okina", "Thespian's Stage", "Dark Depths",
            "Inkmoth Nexus", "Boseiju", "Cavern of Souls", "Rishadan Port", "Mutavault",
            "Maze of Ith", "Academy Ruins", "Buried Ruin", "Inventors' Fair",
            "Tower of the Magistrate", "Dust Bowl", "Ghost Quarter", "Tectonic Edge",
            "Field of Ruin",
        ]

        return utilityLands.contains { utility in
            cardName.contains(utility)
        }
    }

    /// Asynchronous land detection with Scryfall fallback
    public static func isLandWithScryfallFallback(_ cardName: String) async -> Bool {
        // First try pattern-based detection
        if isLand(cardName) {
            return true
        }

        // Fallback to Scryfall API for unknown cards
        do {
            let scryfallCard = try await ScryfallService.getCardByName(name: cardName, fuzzy: true)
            return scryfallCard.typeLine.contains("Land")
        } catch {
            // If API fails, fall back to pattern detection
            return isLandByPattern(cardName)
        }
    }

    /// Enhanced land detection using Scryfall data
    public static func detectLandWithScryfallData(_ scryfallCard: ScryfallCard) -> Bool {
        return scryfallCard.typeLine.contains("Land")
    }

    /// Gets mana colors produced by a land
    public static func getManaColors(_ cardName: String) -> [String] {
        let name = cardName.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check special lands database
        if let colors = SPECIAL_LANDS[name] {
            return colors
        }

        // Basic land color mapping
        let basicColors = [
            "Plains": ["W"], "Island": ["U"], "Swamp": ["B"],
            "Mountain": ["R"], "Forest": ["G"], "Wastes": ["C"],
        ]

        for (basicName, colors) in basicColors {
            if name.contains(basicName) {
                return colors
            }
        }

        // Default for unknown lands
        return ["C"]
    }

    /// Batch land detection for deck analysis
    public static func detectLandsInDeck(_ cardNames: [String]) -> [String: Bool] {
        var results: [String: Bool] = [:]

        for cardName in cardNames {
            results[cardName] = isLand(cardName)
        }

        return results
    }

    /// Count lands in a deck list
    public static func countLands(in deckList: [String]) -> Int {
        return deckList.filter { isLand($0) }.count
    }

    /// Analyze land composition in a deck
    public static func analyzeLandComposition(_ deckList: [String]) -> LandComposition {
        var composition = LandComposition()

        for cardName in deckList {
            if isLand(cardName) {
                let category = getLandCategory(cardName)

                switch category {
                case .basic:
                    composition.basicLands += 1
                case .shock:
                    composition.shockLands += 1
                case .fetch:
                    composition.fetchLands += 1
                case .check:
                    composition.checkLands += 1
                case .battle:
                    composition.battleLands += 1
                case .tap:
                    composition.tapLands += 1
                case .utility:
                    composition.utilityLands += 1
                case .mdfc:
                    composition.mdfcLands += 1
                case .other:
                    composition.otherLands += 1
                case .none:
                    break
                }

                composition.totalLands += 1
            }
        }

        return composition
    }
}

/// Land category classification
public enum LandCategory {
    case basic
    case shock
    case fetch
    case check
    case battle
    case tap
    case utility
    case mdfc
    case other
    case none
}

/// Land composition analysis result
public struct LandComposition {
    public var totalLands: Int = 0
    public var basicLands: Int = 0
    public var shockLands: Int = 0
    public var fetchLands: Int = 0
    public var checkLands: Int = 0
    public var battleLands: Int = 0
    public var tapLands: Int = 0
    public var utilityLands: Int = 0
    public var mdfcLands: Int = 0
    public var otherLands: Int = 0

    public var landDistribution: [String: Int] {
        return [
            "Basic": basicLands,
            "Shock": shockLands,
            "Fetch": fetchLands,
            "Check": checkLands,
            "Battle": battleLands,
            "Tap": tapLands,
            "Utility": utilityLands,
            "MDFC": mdfcLands,
            "Other": otherLands,
        ]
    }
}

