import Foundation

/// Represents a color of mana in Magic: The Gathering
public typealias Color = Bool

/// Represents the five colors of mana plus colorless in Magic: The Gathering
public struct ManaColor: Codable, Equatable, Hashable, CustomStringConvertible, Sendable {
    public var description: String {
        if !hasAnyColor {
            return "No Color"
        }
        
        if isColorless && colorCount == 0 {
            return "Colorless"
        }
        
        return colorIdentity
    }
    // MARK: - Properties
    
    /// Red mana color
    public var isRed: Color = false
    
    /// Green mana color
    public var isGreen: Color = false
    
    /// Black mana color
    public var isBlack: Color = false
    
    /// Blue mana color
    public var isBlue: Color = false
    
    /// White mana color
    public var isWhite: Color = false
    
    /// Colorless mana
    public var isColorless: Color = false

    // Guild color pairs (two-color combinations)
    var azorius: UInt8 = 0  // WU - White-Blue
    var orzhov: UInt8 = 0  // WB - White-Black
    var dimir: UInt8 = 0  // UB - Blue-Black
    var izzet: UInt8 = 0  // UR - Blue-Red
    var rakdos: UInt8 = 0  // BR - Black-Red
    var golgari: UInt8 = 0  // BG - Black-Green
    var gruul: UInt8 = 0  // RG - Red-Green
    var boros: UInt8 = 0  // RW - Red-White
    var selesnya: UInt8 = 0  // GW - Green-White
    var simic: UInt8 = 0  // GU - Green-Blue

    // Shards (allied three-color combinations)
    var bant: UInt8 = 0  // GWU - Green-White-Blue
    var esper: UInt8 = 0  // WUB - White-Blue-Black
    var grixis: UInt8 = 0  // UBR - Blue-Black-Red
    var jund: UInt8 = 0  // BRG - Black-Red-Green
    var naya: UInt8 = 0  // RGW - Red-Green-White

    // Wedges (enemy three-color combinations)
    var abzan: UInt8 = 0  // WBG - White-Black-Green
    var jeskai: UInt8 = 0  // URW - Blue-Red-White
    var sultai: UInt8 = 0  // BGU - Black-Green-Blue
    var mardu: UInt8 = 0  // RWB - Red-White-Black
    var temur: UInt8 = 0  // GUR - Green-Blue-Red
    
    // MARK: - Initialization
    
    /// Creates a new ManaColor with all colors set to false
    public init() {}
    
    /// Creates a ManaColor with specific color values
    public init(
        isWhite: Color = false,
        isBlue: Color = false,
        isBlack: Color = false,
        isRed: Color = false,
        isGreen: Color = false,
        isColorless: Color = false
    ) {
        self.isWhite = isWhite
        self.isBlue = isBlue
        self.isBlack = isBlack
        self.isRed = isRed
        self.isGreen = isGreen
        self.isColorless = isColorless
    }
    
    // MARK: - WUBRG-ordered initializer
    
    /// Creates a ManaColor with specific color values in WUBRG order
    public static func wubrg(
        white: Color = false,
        blue: Color = false,
        black: Color = false,
        red: Color = false,
        green: Color = false,
        colorless: Color = false
    ) -> ManaColor {
        ManaColor(
            isWhite: white,
            isBlue: blue,
            isBlack: black,
            isRed: red,
            isGreen: green,
            isColorless: colorless
        )
    }
    
    // MARK: - Methods
    
    /// Sets the color values based on a string representation
    public mutating func set(from colorString: String) {
        for char in colorString {
            switch String(char) {
            case "R":
                isRed = true
            case "G":
                isGreen = true
            case "B":
                isBlack = true
            case "U":
                isBlue = true
            case "W":
                isWhite = true
            case "/", "//", "{", "}", "X", "0":
                continue
            default:
                isColorless = true
            }
        }
    }
    
    /// Whether this mana color has any colors set
    public var hasAnyColor: Bool {
        isRed || isGreen || isBlack || isBlue || isWhite || isColorless
    }
    
    /// The number of colors present
    public var colorCount: Int {
        var count = 0
        if isWhite { count += 1 }
        if isBlue { count += 1 }
        if isBlack { count += 1 }
        if isRed { count += 1 }
        if isGreen { count += 1 }
        return count
    }
    
    /// Gets a color identity string (e.g., "WUB" for Esper) following MTG conventions
    public var colorIdentity: String {
        // First, build the identity in WUBRG order (standard order)
        var identity = ""
        if isWhite { identity += "W" }
        if isBlue { identity += "U" }
        if isBlack { identity += "B" }
        if isRed { identity += "R" }
        if isGreen { identity += "G" }
        
        // Handle colorless case
        if identity.isEmpty && isColorless {
            return "C"
        }
        
        // Handle special cases for guilds, shards, and wedges
        switch identity {
        // Guild special cases (two-color combinations)
        case "GU": return "GU" // Simic
        
        // Shard special cases (allied three-color combinations)
        case "WUB": return "WUB" // Esper
        case "UBR": return "UBR" // Grixis
        case "BRG": return "BRG" // Jund
        case "RGW": return "RGW" // Naya
        case "GWU": return "GWU" // Bant
        
        // Wedge special cases (enemy three-color combinations)
        case "WBG": return "WBG" // Abzan
        case "WUR": return "URW" // Jeskai
        case "UBG": return "BGU" // Sultai
        case "WBR": return "RWB" // Mardu
        case "URG": return "GUR" // Temur
        
        // Default: return the standard WUBRG order
        default: return identity
        }
    } 
    /// Whether this is a multicolored mana color
    public var isMulticolored: Bool {
        colorCount > 1
    }
    
    /// Whether this is a monocolored mana color
    public var isMonocolored: Bool {
        colorCount == 1
    }
}
