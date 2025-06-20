import Foundation

/// Represents a Magic: The Gathering card type
public typealias CardType = Bool

/// Represents a Magic: The Gathering land type
public typealias LandType = Bool

/// Represents the types of a Magic: The Gathering card
/// It is a superset of the [official card types](https://mtg.gamepedia.com/Card_type)
public struct CardKind: Equatable, Hashable, CustomStringConvertible, Sendable {
    // MARK: - Special Card Designations
    
    /// Commander card (used in Commander format)
    public var isCommander: CardType = false
    
    /// Companion card (used as a companion)
    public var isCompanion: CardType = false
    // MARK: - Land Subtypes
    
    /// Basic lands (Plains, Island, Swamp, Mountain, Forest)
    public var isBasicLand: LandType = false
    
    /// Battle lands ("tango" lands that can enter untapped if you have two or more basic lands)
    public var isBattleLand: LandType = false
    
    /// Tap lands (enter tapped)
    public var isTapLand: LandType = false
    
    /// Check lands (enter untapped if you control a land of specified types)
    public var isCheckLand: LandType = false
    
    /// Shock lands (can enter untapped by paying 2 life)
    public var isShockLand: LandType = false
    
    /// Other land types not categorized
    public var isOtherLand: LandType = false
    
    /// Lands that are required to be included in a deck (e.g., companion requirements)
    public var isForcedLand: LandType = false
    
    // MARK: - Main Card Types
    
    /// Land card type
    public var isLand: CardType = false
    
    /// Creature card type
    public var isCreature: CardType = false
    
    /// Spell card type (generic)
    public var isSpell: CardType = false
    
    /// Enchantment card type
    public var isEnchantment: CardType = false
    
    /// Instant card type
    public var isInstant: CardType = false
    
    /// Planeswalker card type
    public var isPlaneswalker: CardType = false
    
    /// Sorcery card type
    public var isSorcery: CardType = false
    
    /// Artifact card type
    public var isArtifact: CardType = false
    
    /// Mana dork (creature that produces mana)
    public var isManaDork: CardType = false
    
    /// Mana rock (artifact that produces mana)
    public var isManaRock: CardType = false

    /// Unknown card type
    public var isUnknown: CardType = false
    
    /// Whether this card has a land on the back face (for modal double-faced cards)
    public var hasLandBackface: CardType = false

    public var description: String {
        let types = typeList()
        if types.isEmpty {
            return "Unknown"
        }
        return types.joined(separator: " ")
    }
    
    // MARK: - Initialization
    
    /// Creates a new CardKind with default values (all false)
    public init() {}
    
    /// Creates a CardKind with specified main card types
    public init(
        isLand: CardType = false,
        isBasicLand: CardType = false,
        isCreature: CardType = false,
        isSpell: CardType = false,
        isEnchantment: CardType = false,
        isInstant: CardType = false,
        isPlaneswalker: CardType = false,
        isSorcery: CardType = false,
        isArtifact: CardType = false,
        isManaRock: CardType = false,
        isManaDork: CardType = false,
        isUnknown: CardType = false,
        isCommander: CardType = false,
        isCompanion: CardType = false,
        hasLandBackface: CardType = false
    ) {
        self.isLand = isLand
        self.isBasicLand = isBasicLand
        self.isCreature = isCreature
        self.isSpell = isSpell
        self.isEnchantment = isEnchantment
        self.isInstant = isInstant
        self.isPlaneswalker = isPlaneswalker
        self.isSorcery = isSorcery
        self.isArtifact = isArtifact
        self.isManaDork = isManaDork
        self.isManaRock = isManaRock
        self.isUnknown = isUnknown
        self.isCommander = isCommander
        self.isCompanion = isCompanion
        self.hasLandBackface = hasLandBackface
    }
    
    /// Creates a CardKind with specified land types
    public init(
        isBasicLand: LandType = false,
        isBattleLand: LandType = false,
        isTapLand: LandType = false,
        isCheckLand: LandType = false,
        isShockLand: LandType = false,
        isOtherLand: LandType = false,
        isForcedLand: LandType = false
    ) {
        self.isLand = true
        self.isBasicLand = isBasicLand
        self.isBattleLand = isBattleLand
        self.isTapLand = isTapLand
        self.isCheckLand = isCheckLand
        self.isShockLand = isShockLand
        self.isOtherLand = isOtherLand
        self.isForcedLand = isForcedLand
    }

    /// Creates a CardKind for a mana rock
    public init(manaDork: Bool) {
        self.isArtifact = true
        self.isManaDork = manaDork
    }
    
    
    /// Creates a CardKind for a mana rock
    public init(manaRock: Bool) {
        self.isArtifact = true
        self.isManaRock = manaRock
    }
    
    // MARK: - Methods
    
    /// Sets this card kind to unknown, resetting all other types
    public mutating func setUnknown() {
        isLand = false
        isBasicLand = false
        isCreature = false
        isSpell = false
        isEnchantment = false
        isInstant = false
        isPlaneswalker = false
        isSorcery = false
        isArtifact = false
        isManaDork = false
        isManaRock = false
        isCommander = false
        isCompanion = false
        hasLandBackface = false
        isUnknown = true
    }
    
    /// Checks if this card is a land based on its type
    public func isLandCard() -> Bool {
        return isLand
    }
    
    /// Checks if this card is a nonland card (a shorthand)
    public func isNonland() -> Bool {
        return !isLand
    }
    
    /// Checks if this card is a nonland permanent
    public func isNonlandPermanent() -> Bool {
        return !isLand && (isCreature || isEnchantment || isArtifact || isPlaneswalker)
    }
    
    /// Checks if this card is an instant or sorcery
    public func isInstantOrSorcery() -> Bool {
        return isInstant || isSorcery
    }
    
    /// Checks if this card is a mana producer
    public func isManaProducer() -> Bool {
        return isLand || isManaRock || isManaDork
    }
    
    /// Returns true if this card has any land type set
    public func hasLandType() -> Bool {
        return isBasicLand || isBattleLand || isTapLand || isCheckLand || 
               isShockLand || isOtherLand || isForcedLand
    }
    
    /// Returns the land category of this card, if it's a land
    public func landCategory() -> String? {
        guard isLand else { return nil }
        
        if isBasicLand { return "Basic Land" }
        if isBattleLand { return "Battle Land" }
        if isTapLand { return "Tap Land" }
        if isCheckLand { return "Check Land" }
        if isShockLand { return "Shock Land" }
        if isForcedLand { return "Forced Land" }
        if isOtherLand { return "Other Land" }
        
        return "Unspecified Land"
    }
    
    /// Returns a list of the card types as strings
    public func typeList() -> [String] {
        var types: [String] = []
        
        if isLand { types.append("Land") }
        if isCreature { types.append("Creature") }
        if isEnchantment { types.append("Enchantment") }
        if isInstant { types.append("Instant") }
        if isPlaneswalker { types.append("Planeswalker") }
        if isSorcery { types.append("Sorcery") }
        if isArtifact { types.append("Artifact") }
        if isManaDork { types.append("Mana Dork") }
        if isManaRock { types.append("Mana Rock") }
        if isSpell { types.append("Spell") }
        if isCommander { types.append("Commander") }
        if isCompanion { types.append("Companion") }
        if isUnknown { types.append("Unknown") }
        
        return types
    }

    /// Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }

    /// Equatable conformance - cards are equal if they have the same name
    public static func == (lhs: CardKind, rhs: CardKind) -> Bool {
        return lhs.description == rhs.description
    }

}

extension CardKind: Codable {
    private enum CodingKeys: String, CodingKey {
        case isBasicLand
        case isBattleLand
        case isTapLand
        case isCheckLand
        case isShockLand
        case isOtherLand
        case isForcedLand
        case isLand
        case isCreature
        case isSpell
        case isEnchantment
        case isInstant
        case isPlaneswalker
        case isSorcery
        case isArtifact
        case isManaDork
        case isManaRock
        case isUnknown
        case isCommander
        case isCompanion
        case hasLandBackface
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(isBasicLand, forKey: .isBasicLand)
        try container.encode(isBattleLand, forKey: .isBattleLand)
        try container.encode(isTapLand, forKey: .isTapLand)
        try container.encode(isCheckLand, forKey: .isCheckLand)
        try container.encode(isShockLand, forKey: .isShockLand)
        try container.encode(isOtherLand, forKey: .isOtherLand)
        try container.encode(isForcedLand, forKey: .isForcedLand)
        try container.encode(isLand, forKey: .isLand)
        try container.encode(isCreature, forKey: .isCreature)
        try container.encode(isSpell, forKey: .isSpell)
        try container.encode(isEnchantment, forKey: .isEnchantment)
        try container.encode(isInstant, forKey: .isInstant)
        try container.encode(isPlaneswalker, forKey: .isPlaneswalker)
        try container.encode(isSorcery, forKey: .isSorcery)
        try container.encode(isArtifact, forKey: .isArtifact)
        try container.encode(isManaDork, forKey: .isManaDork)
        try container.encode(isManaRock, forKey: .isManaRock)
        try container.encode(isUnknown, forKey: .isUnknown)
        try container.encode(isCommander, forKey: .isCommander)
        try container.encode(isCompanion, forKey: .isCompanion)
        try container.encode(hasLandBackface, forKey: .hasLandBackface)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.init()
        
        isBasicLand = try container.decodeIfPresent(Bool.self, forKey: .isBasicLand) ?? false
        isBattleLand = try container.decodeIfPresent(Bool.self, forKey: .isBattleLand) ?? false
        isTapLand = try container.decodeIfPresent(Bool.self, forKey: .isTapLand) ?? false
        isCheckLand = try container.decodeIfPresent(Bool.self, forKey: .isCheckLand) ?? false
        isShockLand = try container.decodeIfPresent(Bool.self, forKey: .isShockLand) ?? false
        isOtherLand = try container.decodeIfPresent(Bool.self, forKey: .isOtherLand) ?? false
        isForcedLand = try container.decodeIfPresent(Bool.self, forKey: .isForcedLand) ?? false
        isLand = try container.decodeIfPresent(Bool.self, forKey: .isLand) ?? false
        isCreature = try container.decodeIfPresent(Bool.self, forKey: .isCreature) ?? false
        isSpell = try container.decodeIfPresent(Bool.self, forKey: .isSpell) ?? false
        isEnchantment = try container.decodeIfPresent(Bool.self, forKey: .isEnchantment) ?? false
        isInstant = try container.decodeIfPresent(Bool.self, forKey: .isInstant) ?? false
        isPlaneswalker = try container.decodeIfPresent(Bool.self, forKey: .isPlaneswalker) ?? false
        isSorcery = try container.decodeIfPresent(Bool.self, forKey: .isSorcery) ?? false
        isArtifact = try container.decodeIfPresent(Bool.self, forKey: .isArtifact) ?? false
        isManaDork = try container.decodeIfPresent(Bool.self, forKey: .isManaDork) ?? false
        isManaRock = try container.decodeIfPresent(Bool.self, forKey: .isManaRock) ?? false
        isUnknown = try container.decodeIfPresent(Bool.self, forKey: .isUnknown) ?? false
        isCommander = try container.decodeIfPresent(Bool.self, forKey: .isCommander) ?? false
        isCompanion = try container.decodeIfPresent(Bool.self, forKey: .isCompanion) ?? false
        hasLandBackface = try container.decodeIfPresent(Bool.self, forKey: .hasLandBackface) ?? false
    }
}
