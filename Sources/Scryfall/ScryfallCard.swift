import Foundation
import Card

public struct ScryfallCard {
    // Keywords that indicate a card can be a commander
    private static let commanderKeywords = [
        "can be your commander",
    ]
    
    // Keywords that indicate a card can be a companion
    private static let companionKeywords = [
        "companion",
        "if this card is your chosen companion"
    ]

    // Known mana rocks by name
    private static let knownManaRocks = [
        "Arcane Signet",
        "Basalt Monolith",
        "Caged Sun",
        "Chromatic Lantern",
        "Chrome Mox",
        "Commander's Sphere",
        "Fellwar Stone",
        "Gilded Lotus",
        "Grim Monolith",
        "Jeweled Lotus",
        "Lotus",
        "Lotus Petal",
        "Mana Crypt",
        "Mana Vault",
        "Mind Stone",
        "Mox Amber",
        "Mox Jasper",
        "Mox Opal",
        "Mox", 
        "Signet",
        "Sol Ring",
        "Talisman of",
        "Thran Dynamo",
    ]

    private static let knownManaDorks = [
        "Llanowar Elves",
        "Birds of Paradise",
        "Ornithopter of Paradise",
    ]

    // Common patterns in mana rock oracle text
    private static let manaPatterns = [
        "{T}: Add ", // Tap symbol followed by add
        "Tap: Add ", // Tap keyword followed by add
        "Add one mana of ", // Generic mana production
        "Add two mana ", // 2+ mana production
        "Add three mana ", // 3+ mana production
        "{T}: Add {", // Tap for specific mana
        "When you tap this artifact for mana", // Mana artifact trigger
        "When tapped for mana", // Another mana trigger
        "taps for mana", // Generic mana reference
        "can be tapped for mana" // Generic mana reference
    ]

    public let object: String?
    public var id: String?
    public var oracleId: String?
    public let multiverseIds: [Int]?
    public let name: String?
    public let lang: String?
    public let releasedAt: String?
    public let uri: String?
    public let scryfallUri: String?
    public let layout: String?
    public let highresImage: Bool?
    public let cmc: Double?
    public let oracleText: String?
    public let manaCost: String?
    public let typeLine: String?
    public let colorIdentity: [String]?
    public let keywords: [String]?
    public var imageUris: ImageUris?
    public let cardFaces: [ScryfallCard]?
    public let legalities: Legalities?
    public let games: [String]?
    public let reserved: Bool?
    public let foil: Bool?
    public let nonfoil: Bool?
    public let oversized: Bool?
    public let promo: Bool?
    public let reprint: Bool?
    public let variation: Bool?
    public var set: String?
    public let setName: String?
    public let setType: String?
    public let setUri: String?
    public let setSearchUri: String?
    public let scryfallSetUri: String?
    public let rulingsUri: String?
    public let printsSearchUri: String?
    public var collectorNumber: String?
    public let digital: Bool?
    public var rarity: String?
    public let cardBackId: String?
    public let artist: String?
    public let artistIds: [String]?
    public let arenaId: Int64?
    public let borderColor: String?
    public let frame: String?
    public let fullArt: Bool?
    public let textless: Bool?
    public let booster: Bool?
    public let storySpotlight: Bool?
    public let prices: Prices?
    public var relatedUris: RelatedUris?
    
    public func notLegal() -> Bool {
        return legalities?.notLegal() ?? false
    }
    
    public func convertToCard() -> Card {
        // Collect all properties first
        let cardName = name ?? ""
        let cardOracleID = oracleId ?? ""
        let cardManaCostString = manaCost ?? ""
        let cardImageURI = imageUris?.normal ?? ""
        let cardArenaID = arenaId ?? 0
        let cardRarity = Rarity(from: rarity ?? "")
        let cardIsFace = object == "card_face"
        
        // Create mutable set
        var cardSet = MTGSet()
        cardSet.code = set ?? ""
        cardSet.name = setName ?? ""
        
        // Create mutable kind and set properties based on type
        var cardKind = CardKind()
        
        // Check if this card can be a commander or companion  
        if let oracleText = oracleText {
            if isCommander(oracleText: oracleText) {
                cardKind.isCommander = true
            }
            
            if isCompanion(oracleText: oracleText) {
                cardKind.isCompanion = true
            }
        }
        
        // Set card type properties
        if let typeLine = typeLine {
            if typeLine.contains("Land") {
                cardKind.isLand = true
                setLandAttributesOnKind(&cardKind)
            } else if typeLine.contains("Artifact") {
                cardKind.isArtifact = true
                if isManaRock() {
                    cardKind.isManaRock = true
                }
            } else if typeLine.contains("Planeswalker") {
                cardKind.isPlaneswalker = true
            } else if typeLine.contains("Creature") {
                cardKind.isCreature = true
                if isManaDork() {
                    cardKind.isManaDork = true
                }
            } else if typeLine.contains("Instant") {
                cardKind.isInstant = true
                cardKind.isSpell = true
            } else if typeLine.contains("Sorcery") {
                cardKind.isSorcery = true
                cardKind.isSpell = true
            } else if typeLine.contains("Enchantment") {
                cardKind.isEnchantment = true
            } else {
                cardKind.isUnknown = true
            }
        }
        
        // Create the final card with all properties
        let card = Card(
            name: cardName,
            oracleID: cardOracleID,
            manaCostString: cardManaCostString,
            imageURI: cardImageURI,
            kind: cardKind,
            arenaID: cardArenaID,
            rarity: cardRarity,
            set: cardSet,
            isFace: cardIsFace
        )
        
        return card
    }
    
    // Helper method to set land attributes on CardKind
    private func setLandAttributesOnKind(_ cardKind: inout CardKind) {
        guard let typeLine = typeLine else { return }
        
        let isBasicLand = typeLine.contains("Basic Land")
        if isBasicLand {
            cardKind.isBasicLand = true
            return
        }
        
        // Check for various land types based on oracle text
        if let oracleText = oracleText {
            let isShockLand = oracleText.contains("pay 2 life") && 
                             oracleText.contains("enters the battlefield tapped")
            let isTapLand = oracleText.contains("enters the battlefield tapped") && 
                           !isShockLand
            let isCheckLand = oracleText.contains("enters the battlefield tapped unless you control")
            let isBattleLand = oracleText.contains("enters the battlefield tapped unless you control two or more basic lands")
            
            if isShockLand {
                cardKind.isShockLand = true
            } else if isTapLand {
                cardKind.isTapLand = true
            } else if isCheckLand {
                cardKind.isCheckLand = true
            } else if isBattleLand {
                cardKind.isBattleLand = true
            } else {
                cardKind.isOtherLand = true
            }
        }
    }
    
    /// Determines if this card is a modal double-faced card (has two faces with potentially different types)
    private func isModalDoubleFaced() -> Bool {
        guard let layout = layout else { return false }
        
        return (layout == "modal_dfc" || layout == "transform") && cardFaces != nil && cardFaces!.count > 1
    }
    
    /// Determines if this card can be a commander based on its oracle text
    private func isCommander(oracleText: String) -> Bool {
        // Check for commander keywords in oracle text
        for keyword in ScryfallCard.commanderKeywords {
            if oracleText.lowercased().contains(keyword.lowercased()) {
                return true
            }
        }
        
        // Check if it's a legendary creature or planeswalker (common commander types)
        if let typeLine = typeLine?.lowercased() {
            if typeLine.contains("legendary") && (typeLine.contains("creature") || typeLine.contains("planeswalker")) {
                return true
            }
        }
        
        return false
    }
    
    /// Determines if this card can be a companion based on its oracle text
    private func isCompanion(oracleText: String) -> Bool {
        // Check for companion keywords in oracle text
        for keyword in ScryfallCard.companionKeywords {
            if oracleText.lowercased().contains(keyword.lowercased()) {
                return true
            }
        }
        
        // Check if it has the companion ability
        if let keywords = keywords, keywords.contains(where: { $0.lowercased() == "companion" }) {
            return true
        }
        
        return false
    }
    
    /// Determines if this card is a mana rock by analyzing its oracle text
    private func isManaRock() -> Bool {
        guard let oracleText = oracleText, 
              let typeLine = typeLine,
              typeLine.contains("Artifact") else {
            return false
        }
        
        // Check for known mana rock names
        if let name = name {
            for rockName in ScryfallCard.knownManaRocks {
                if name == rockName || name.contains(rockName) {
                    return true
                }
            }
        }
        
        // Check for mana production patterns in oracle text
        for pattern in ScryfallCard.manaPatterns {
            if oracleText.contains(pattern) {
                return true
            }
        }
        
        return false
    }

    private func isManaDork() -> Bool {
        guard let oracleText = oracleText, 
              let typeLine = typeLine,
              typeLine.contains("Creature") else {
            return false
        }
        
        // Check for known mana dork names
        if let name = name {
            for dorkName in ScryfallCard.knownManaDorks{
                if name == dorkName || name.contains(dorkName) {
                    return true
                }
            }
        }
        
        // Check for mana production patterns in oracle text
        for pattern in ScryfallCard.manaPatterns {
            if oracleText.contains(pattern) {
                return true
            }
        }
        
        return false
    }
    
    /// Checks if a mana rock can produce a specific color of mana
    private func hasManaAbility(color: String) -> Bool {
        guard let oracleText = oracleText else {
            return false
        }
        
        // Check for any color mana production
        if oracleText.contains("Add one mana of any color") || 
           oracleText.contains("Add mana of any color") ||
           oracleText.contains("of any one color") {
            return true
        }
        
        // Check for specific color mana production
        let colorSymbol = "{\(color)}"
        if oracleText.contains(colorSymbol) {
            return true
        }
        
        // Check for reference to color by name
        let colorNames = [
            "W": ["white", "White"],
            "U": ["blue", "Blue"],
            "B": ["black", "Black"],
            "R": ["red", "Red"],
            "G": ["green", "Green"]
        ]
        
        if let colorNames = colorNames[color] {
            for colorName in colorNames {
                if oracleText.contains("Add \(colorName)") || 
                   oracleText.contains("\(colorName) mana") {
                    return true
                }
            }
        }
        
        return false
    }
    
    /// Gets the land category for this card
    public func getLandCategory() -> LandCategory {
        guard let typeLine = typeLine, typeLine.contains("Land") else { return .none }
        
        let textToAnalyze = oracleText ?? ""
        
        // Handle MDFC lands
        if isModalDoubleFaced() {
            return .mdfc
        }
        
        // Basic lands
        if typeLine.contains("Basic Land") {
            return .basic
        }
        
        // Analyze oracle text for land subtypes
        if textToAnalyze.contains("enters the battlefield, you may pay 2 life.") {
            return .shock
        } else if textToAnalyze.contains("enters the battlefield tapped.") ||
                  textToAnalyze.contains("comes into the play tapped with") ||
                  textToAnalyze.contains("enters the battlefield tapped with") ||
                  textToAnalyze.contains("enters tapped") {
            return .tap
        } else if textToAnalyze.contains("enters the battlefield tapped unless you control a") {
            return .check
        } else if textToAnalyze.contains("enters the battlefield tapped unless you control two or more basic lands.") {
            return .battle
        }
        
        // Check for utility lands based on name patterns
        if isUtilityLand() {
            return .utility
        }
        
        // Check for fetch lands
        if isFetchLand() {
            return .fetch
        }
        
        return .other
    }
    
    /// Determines if this is a utility land based on common patterns
    private func isUtilityLand() -> Bool {
        guard let name = name else { return false }
        
        let utilityPatterns = [
            "Ancient Tomb", "Strip Mine", "Wasteland", "Cabal Coffers", "Urborg",
            "Shizo", "Eiganjo", "Okina", "Thespian's Stage", "Dark Depths",
            "Inkmoth Nexus", "Boseiju", "Cavern of Souls", "Rishadan Port",
            "Mutavault", "Maze of Ith", "Academy Ruins", "Buried Ruin",
            "Inventors' Fair", "Tower of the Magistrate", "Dust Bowl",
            "Ghost Quarter", "Tectonic Edge", "Field of Ruin"
        ]
        
        return utilityPatterns.contains { pattern in
            name.contains(pattern)
        }
    }
    
    /// Determines if this is a fetch land
    private func isFetchLand() -> Bool {
        guard let name = name, let oracleText = oracleText else { return false }
        
        let fetchNames = [
            "Arid Mesa", "Bloodstained Mire", "Flooded Strand", "Marsh Flats",
            "Misty Rainforest", "Polluted Delta", "Scalding Tarn", "Verdant Catacombs",
            "Windswept Heath", "Wooded Foothills", "Fabled Passage", "Evolving Wilds",
            "Terramorphic Expanse", "Prismatic Vista"
        ]
        
        // Check by name first
        if fetchNames.contains(name) {
            return true
        }
        
        // Check for fetch patterns in oracle text
        return oracleText.contains("Search your library for a") && 
               oracleText.contains("land") &&
               oracleText.contains("put it onto the battlefield")
    }
}

extension ScryfallCard: Codable {
    enum CodingKeys: String, CodingKey {
        case object
        case id
        case oracleId = "oracle_id"
        case multiverseIds = "multiverse_ids"
        case name
        case lang
        case releasedAt = "released_at"
        case uri
        case scryfallUri = "scryfall_uri"
        case layout
        case highresImage = "highres_image"
        case cmc
        case oracleText = "oracle_text"
        case manaCost = "mana_cost"
        case typeLine = "type_line"
        case colorIdentity = "color_identity"
        case keywords
        case imageUris = "image_uris"
        case cardFaces = "card_faces"
        case legalities
        case games
        case reserved
        case foil
        case nonfoil
        case oversized
        case promo
        case reprint
        case variation
        case set
        case setName = "set_name"
        case setType = "set_type"
        case setUri = "set_uri"
        case setSearchUri = "set_search_uri"
        case scryfallSetUri = "scryfall_set_uri"
        case rulingsUri = "rulings_uri"
        case printsSearchUri = "prints_search_uri"
        case collectorNumber = "collector_number"
        case digital
        case rarity
        case cardBackId = "card_back_id"
        case artist
        case artistIds = "artist_ids"
        case arenaId = "arena_id"
        case borderColor = "border_color"
        case frame
        case fullArt = "full_art"
        case textless
        case booster
        case storySpotlight = "story_spotlight"
        case prices
        case relatedUris = "related_uris"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(object, forKey: .object)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(oracleId, forKey: .oracleId)
        
        try container.encodeIfPresent(multiverseIds, forKey: .multiverseIds)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(lang, forKey: .lang)
        try container.encodeIfPresent(releasedAt, forKey: .releasedAt)
        try container.encodeIfPresent(uri, forKey: .uri)
        try container.encodeIfPresent(scryfallUri, forKey: .scryfallUri)
        try container.encodeIfPresent(layout, forKey: .layout)
        try container.encodeIfPresent(highresImage, forKey: .highresImage)
        try container.encodeIfPresent(cmc, forKey: .cmc)
        try container.encodeIfPresent(oracleText, forKey: .oracleText)
        try container.encodeIfPresent(manaCost, forKey: .manaCost)
        try container.encodeIfPresent(typeLine, forKey: .typeLine)
        try container.encodeIfPresent(colorIdentity, forKey: .colorIdentity)
        
        try container.encodeIfPresent([String](), forKey: .keywords)
        try container.encodeIfPresent(imageUris, forKey: .imageUris)
        try container.encodeIfPresent(cardFaces, forKey: .cardFaces)
        try container.encodeIfPresent(legalities, forKey: .legalities)
        
        try container.encodeIfPresent([String](), forKey: .games)
        try container.encodeIfPresent(reserved, forKey: .reserved)
        try container.encodeIfPresent(foil, forKey: .foil)
        try container.encodeIfPresent(nonfoil, forKey: .nonfoil)
        try container.encodeIfPresent(oversized, forKey: .oversized)
        try container.encodeIfPresent(promo, forKey: .promo)
        try container.encodeIfPresent(reprint, forKey: .reprint)
        try container.encodeIfPresent(variation, forKey: .variation)
        try container.encodeIfPresent(set, forKey: .set)
        try container.encodeIfPresent(setName, forKey: .setName)
        try container.encodeIfPresent(setType, forKey: .setType)
        try container.encodeIfPresent(setUri, forKey: .setUri)
        try container.encodeIfPresent(setSearchUri, forKey: .setSearchUri)
        try container.encodeIfPresent(scryfallSetUri, forKey: .scryfallSetUri)
        try container.encodeIfPresent(rulingsUri, forKey: .rulingsUri)
        try container.encodeIfPresent(printsSearchUri, forKey: .printsSearchUri)
        try container.encodeIfPresent(collectorNumber, forKey: .collectorNumber)
        try container.encodeIfPresent(digital, forKey: .digital)
        try container.encodeIfPresent(rarity, forKey: .rarity)
        try container.encodeIfPresent(cardBackId, forKey: .cardBackId)
        try container.encodeIfPresent(artist, forKey: .artist)
        try container.encodeIfPresent(artistIds, forKey: .artistIds)
        try container.encodeIfPresent(arenaId, forKey: .arenaId)
        try container.encodeIfPresent(borderColor, forKey: .borderColor)
        try container.encodeIfPresent(frame, forKey: .frame)
        try container.encodeIfPresent(fullArt, forKey: .fullArt)
        try container.encodeIfPresent(textless, forKey: .textless)
        try container.encodeIfPresent(booster, forKey: .booster)
        try container.encodeIfPresent(storySpotlight, forKey: .storySpotlight)
        try container.encodeIfPresent(prices, forKey: .prices)
        try container.encodeIfPresent(relatedUris, forKey: .relatedUris)
    } 

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode properties, all as optional
        object = try container.decodeIfPresent(String.self, forKey: .object)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        oracleId = try container.decodeIfPresent(String.self, forKey: .oracleId)

        multiverseIds = try container.decodeIfPresent([Int].self, forKey: .multiverseIds)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        lang = try container.decodeIfPresent(String.self, forKey: .lang)
        releasedAt = try container.decodeIfPresent(String.self, forKey: .releasedAt)
        uri = try container.decodeIfPresent(String.self, forKey: .uri)
        scryfallUri = try container.decodeIfPresent(String.self, forKey: .scryfallUri)
        layout = try container.decodeIfPresent(String.self, forKey: .layout)
        highresImage = try container.decodeIfPresent(Bool.self, forKey: .highresImage)
        cmc = try container.decodeIfPresent(Double.self, forKey: .cmc)
        oracleText = try container.decodeIfPresent(String.self, forKey: .oracleText)
        manaCost = try container.decodeIfPresent(String.self, forKey: .manaCost)
        typeLine = try container.decodeIfPresent(String.self, forKey: .typeLine)
        colorIdentity = try container.decodeIfPresent([String].self, forKey: .colorIdentity)

        keywords = try container.decodeIfPresent([String].self, forKey: .keywords)
        imageUris = try container.decodeIfPresent(ImageUris.self, forKey: .imageUris)
        cardFaces = try container.decodeIfPresent([ScryfallCard].self, forKey: .cardFaces)
        legalities = try container.decodeIfPresent(Legalities.self, forKey: .legalities)

        games = try container.decodeIfPresent([String].self, forKey: .games)
        reserved = try container.decodeIfPresent(Bool.self, forKey: .reserved)
        foil = try container.decodeIfPresent(Bool.self, forKey: .foil)
        nonfoil = try container.decodeIfPresent(Bool.self, forKey: .nonfoil)
        oversized = try container.decodeIfPresent(Bool.self, forKey: .oversized)
        promo = try container.decodeIfPresent(Bool.self, forKey: .promo)
        reprint = try container.decodeIfPresent(Bool.self, forKey: .reprint)
        variation = try container.decodeIfPresent(Bool.self, forKey: .variation)
        set = try container.decodeIfPresent(String.self, forKey: .set)
        setName = try container.decodeIfPresent(String.self, forKey: .setName)
        setType = try container.decodeIfPresent(String.self, forKey: .setType)
        setUri = try container.decodeIfPresent(String.self, forKey: .setUri)
        setSearchUri = try container.decodeIfPresent(String.self, forKey: .setSearchUri)
        scryfallSetUri = try container.decodeIfPresent(String.self, forKey: .scryfallSetUri)
        rulingsUri = try container.decodeIfPresent(String.self, forKey: .rulingsUri)
        printsSearchUri = try container.decodeIfPresent(String.self, forKey: .printsSearchUri)
        collectorNumber = try container.decodeIfPresent(String.self, forKey: .collectorNumber)
        digital = try container.decodeIfPresent(Bool.self, forKey: .digital)
        rarity = try container.decodeIfPresent(String.self, forKey: .rarity)
        cardBackId = try container.decodeIfPresent(String.self, forKey: .cardBackId)
        artist = try container.decodeIfPresent(String.self, forKey: .artist)
        artistIds = try container.decodeIfPresent([String].self, forKey: .artistIds)
        arenaId = try container.decodeIfPresent(Int64.self, forKey: .arenaId)
        borderColor = try container.decodeIfPresent(String.self, forKey: .borderColor)
        frame = try container.decodeIfPresent(String.self, forKey: .frame)
        fullArt = try container.decodeIfPresent(Bool.self, forKey: .fullArt)
        textless = try container.decodeIfPresent(Bool.self, forKey: .textless)
        booster = try container.decodeIfPresent(Bool.self, forKey: .booster)
        storySpotlight = try container.decodeIfPresent(Bool.self, forKey: .storySpotlight)
        prices = try container.decodeIfPresent(Prices.self, forKey: .prices)
        relatedUris = try container.decodeIfPresent(RelatedUris.self, forKey: .relatedUris)
    }
}

// Utility function
func stringInSlice(a: String, list: [String]) -> Bool {
    return list.contains(a)
}

/// Land categories for classification
public enum LandCategory {
    case none
    case basic
    case shock
    case fetch
    case check
    case battle
    case tap
    case utility
    case mdfc
    case other
}
