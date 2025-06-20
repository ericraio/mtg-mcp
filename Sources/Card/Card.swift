import Foundation

/// Represents a Magic: The Gathering card for MCP server usage
public struct Card: Identifiable, Equatable, Hashable, Codable, Sendable {
    // MARK: - Properties
    
    /// Unique identifier for the card
    public let id: String
    
    /// String representing the card name
    public var name: String
    
    /// Scryfall oracle ID
    public var oracleID: String
    
    /// String representing the card mana cost, in "{X}{R}{R}" style format
    public var manaCostString: String
    
    /// A URI to an image of the card
    public var imageURI: String
    
    /// The card type
    public var kind: CardKind
    
    /// A hash of the card name using FNV-1a algorithm
    public var nameHash: UInt64
    
    /// The turn to play the card, defaults to mana_cost.cmc()
    public var turn: Int
    
    /// ManaCost representation of the card mana cost
    public var manaCost: ManaCost?
    
    /// All potential mana cost combinations, for cards with split mana costs like "{R/G}"
    public var allManaCosts: [ManaCost]
    
    /// Arena ID
    public var arenaID: Int64
    
    /// Card rarity
    public var rarity: Rarity
    
    /// Card release set
    public var set: MTGSet
    
    /// True if this card is a sub face
    public var isFace: Bool
    
    /// For Modal Double-Faced Cards (MDFCs), stores the front face name
    public var frontFaceName: String?
    
    /// For Modal Double-Faced Cards (MDFCs), stores the back face name
    public var backFaceName: String?
    
    /// True if this is a Modal Double-Faced Card
    public var isMDFC: Bool
    
    // MARK: - Computed Properties
    
    /// Returns the converted mana cost of the card
    public var cmc: Int {
        return manaCost?.cmc() ?? 0
    }
    
    /// Whether this card is a land
    public var isLand: Bool {
        return kind.isLandCard()
    }
    
    /// Whether this card is an artifact
    public var isArtifact: Bool {
        return kind.isArtifact
    }

    /// Whether this card is a mana dork
    public var isManaDork: Bool {
        return kind.isManaDork
    }
    
    /// Whether this card is a mana rock
    public var isManaRock: Bool {
        return kind.isManaRock
    }
    
    /// Whether this card is a mana producer (land or mana rock)
    public var isManaProducer: Bool {
        return kind.isManaProducer()
    }
    
    /// Whether this card is legal in Standard format
    public var isStandardLegal: Bool {
        return set.isStandardLegal
    }
    
    /// For MDFCs, returns the front face name for deck building purposes. For regular cards, returns the full name.
    public var primaryName: String {
        return frontFaceName ?? name
    }
    
    /// For MDFCs, returns whether either face is a land
    public var hasLandFace: Bool {
        if !isMDFC { return isLand }
        
        // For MDFC cards, we can't easily check the back face from Card module
        // The classification should be done during parsing in DeckParser
        return isLand || kind.hasLandBackface
    }

    public static func isColorLessManaColor(_ color: String) -> Bool {
        return color == "C"
    }
    
    // MARK: - Initialization
    
    /// Creates a new card with default values
    public init() {
        self.id = UUID().uuidString
        self.name = ""
        self.oracleID = ""
        self.manaCostString = ""
        self.imageURI = ""
        self.kind = CardKind()
        self.nameHash = 0
        self.turn = 0
        self.manaCost = ManaCost()
        self.allManaCosts = []
        self.arenaID = 0
        self.rarity = .unknown
        self.set = MTGSet()
        self.isFace = false
        self.frontFaceName = nil
        self.backFaceName = nil
        self.isMDFC = false
    }
    
    /// Creates a card with specified properties
    public init(
        id: String = UUID().uuidString,
        name: String,
        oracleID: String = "",
        manaCostString: String = "",
        imageURI: String = "",
        kind: CardKind = CardKind(),
        turn: Int = 0,
        arenaID: Int64 = 0,
        rarity: Rarity = .unknown,
        set: MTGSet = MTGSet(),
        isFace: Bool = false,
        frontFaceName: String? = nil,
        backFaceName: String? = nil,
        isMDFC: Bool = false
    ) {
        self.id = id
        self.name = name
        self.oracleID = oracleID
        self.manaCostString = manaCostString
        self.imageURI = imageURI
        self.kind = kind
        self.turn = turn
        self.arenaID = arenaID
        self.rarity = rarity
        self.set = set
        self.isFace = isFace
        self.frontFaceName = frontFaceName
        self.backFaceName = backFaceName
        self.isMDFC = isMDFC
        self.allManaCosts = []
        
        // Calculate hash
        self.nameHash = Self.calculateNameHash(name)
        
        // Initialize mana cost if provided
        if !manaCostString.isEmpty {
            self.manaCost = ManaCost(from: manaCostString)
        } else {
            self.manaCost = ManaCost()
        }
    }
    
    // MARK: - Methods
    
    /// Calculates the hash value of a card name using FNV-1a algorithm
    private static func calculateNameHash(_ name: String) -> UInt64 {
        if name.isEmpty {
            return 0
        }
        
        // FNV-1a hash algorithm
        let fnvPrime: UInt64 = 1099511628211
        let fnvOffsetBasis: UInt64 = 14695981039346656037
        
        var hashValue = fnvOffsetBasis
        
        for byte in name.utf8 {
            hashValue ^= UInt64(byte)
            hashValue &*= fnvPrime
        }
        
        return hashValue
    }
    
    // MARK: - Protocol Conformance
    
    /// Equatable conformance - cards are equal if they have the same name
    public static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.name == rhs.name
    }
    
    /// Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

// MARK: - CustomStringConvertible

extension Card: CustomStringConvertible {
    public var description: String {
        var desc = "\(name)"
        
        if !manaCostString.isEmpty {
            desc += " \(manaCostString)"
        }
        
        if !kind.description.isEmpty {
            desc += " — \(kind.description)"
        }
        
        if let manaCost = manaCost, manaCost.cmc() > 0 {
            desc += " (CMC: \(manaCost.cmc()))"
        }
        
        return desc
    }
}

// MARK: - Factory Methods

extension Card {
    /// Creates a basic land card
    public static func basicLand(name: String, set: MTGSet = MTGSet()) -> Card {
        return Card(
            name: name,
            kind: CardKind(isLand: true, isBasicLand: true),
            set: set
        )
    }

    /// Creates a mana dork card
    public static func manaDork(name: String, manaCost: String, set: MTGSet = MTGSet()) -> Card {
        return Card(
            name: name,
            manaCostString: manaCost,
            kind: CardKind(isCreature: true, isManaDork: true),
            set: set
        )
    }
    
    /// Creates a mana rock card
    public static func manaRock(name: String, manaCost: String, set: MTGSet = MTGSet()) -> Card {
        return Card(
            name: name,
            manaCostString: manaCost,
            kind: CardKind(isArtifact: true, isManaRock: true),
            set: set
        )
    }
    
    /// Creates a creature card
    public static func creature(name: String, manaCost: String, set: MTGSet = MTGSet()) -> Card {
        return Card(
            name: name,
            manaCostString: manaCost,
            kind: CardKind(isCreature: true),
            set: set
        )
    }
    
    /// Creates an instant card
    public static func instant(name: String, manaCost: String, set: MTGSet = MTGSet()) -> Card {
        return Card(
            name: name,
            manaCostString: manaCost,
            kind: CardKind(isSpell: true, isInstant: true),
            set: set
        )
    }
    
    /// Creates a sorcery card
    public static func sorcery(name: String, manaCost: String, set: MTGSet = MTGSet()) -> Card {
        return Card(
            name: name,
            manaCostString: manaCost,
            kind: CardKind(isSpell: true, isSorcery: true),
            set: set
        )
    }
}