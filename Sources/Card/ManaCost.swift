import Foundation

/// Represents a mana cost in Magic: The Gathering
public struct ManaCost: Codable, Equatable, Hashable, CustomStringConvertible, Sendable {
    // MARK: - Properties
    
    /// Hybrid mana colors in the cost (stored as strings for simplicity)
    public var splitColors: [String] = []
    
    /// Bitfield representing which colors are present (for efficient operations)
    public var bits: UInt8 = 0
    
    /// Red mana in the cost
    public var red: UInt8 = 0
    
    /// Green mana in the cost
    public var green: UInt8 = 0
    
    /// Black mana in the cost
    public var black: UInt8 = 0
    
    /// Blue mana in the cost
    public var blue: UInt8 = 0
    
    /// White mana in the cost
    public var white: UInt8 = 0
    
    /// Colorless mana in the cost
    public var colorless: UInt8 = 0

    /// Number of distinct colors in the mana cost
    public var colorCount: UInt8 {
        var count: UInt8 = 0
        if white > 0 { count += 1 }
        if blue > 0 { count += 1 }
        if black > 0 { count += 1 }
        if red > 0 { count += 1 }
        if green > 0 { count += 1 }
        return count
    }
    
    /// Whether this mana cost contains exactly one color
    public var isMonoColored: Bool {
        colorCount == 1
    }
    
    /// Whether this mana cost contains multiple colors
    public var isMultiColored: Bool {
        colorCount > 1
    }
    
    /// Whether this mana cost is colorless
    public var isColorless: Bool {
        colorCount == 0
    }
    
    // MARK: - Initialization
    
    /// Creates a new empty mana cost
    public init() {
        updateBits()
    }
    
    /// Creates a mana cost from a string representation
    public init(from costString: String) {
        self.init()
        set(from: costString)
    }
    
    // MARK: - Methods
    
    /// Returns the converted mana cost (total mana required)
    public func cmc() -> Int {
        return Int(red + green + black + blue + white + colorless)
    }
    
    /// Sets the mana cost from a string representation like "{2}{R}{R}"
    public mutating func set(from costString: String) {
        // Reset all values
        red = 0
        green = 0
        black = 0
        blue = 0
        white = 0
        colorless = 0
        splitColors = []
        
        // Parse the string
        let components = parseManaCost(costString)
        for component in components {
            switch component.uppercased() {
            case "R":
                red += 1
            case "G":
                green += 1
            case "B":
                black += 1
            case "U":
                blue += 1
            case "W":
                white += 1
            case "C":
                colorless += 1
            default:
                // Try to parse as a number for generic mana
                if let value = UInt8(component) {
                    colorless += value
                }
                // Handle hybrid mana like "R/G"
                else if component.contains("/") {
                    splitColors.append(component)
                }
            }
        }
        
        updateBits()
    }
    
    /// Creates a mana cost from individual color counts
    public static func fromColorCounts(
        white: UInt8 = 0,
        blue: UInt8 = 0,
        black: UInt8 = 0,
        red: UInt8 = 0,
        green: UInt8 = 0,
        colorless: UInt8 = 0
    ) -> ManaCost {
        var cost = ManaCost()
        cost.white = white
        cost.blue = blue
        cost.black = black
        cost.red = red
        cost.green = green
        cost.colorless = colorless
        cost.updateBits()
        return cost
    }
    
    /// Updates the bits field based on current mana values
    public mutating func updateBits() {
        bits = 0
        if white > 0 { bits |= 1 << 0 }
        if blue > 0 { bits |= 1 << 1 }
        if black > 0 { bits |= 1 << 2 }
        if red > 0 { bits |= 1 << 3 }
        if green > 0 { bits |= 1 << 4 }
    }
    
    /// Parses a mana cost string into individual components
    private func parseManaCost(_ costString: String) -> [String] {
        var components: [String] = []
        var currentComponent = ""
        var inBraces = false
        
        for char in costString {
            if char == "{" {
                inBraces = true
                currentComponent = ""
            } else if char == "}" {
                inBraces = false
                if !currentComponent.isEmpty {
                    components.append(currentComponent)
                }
                currentComponent = ""
            } else if inBraces {
                currentComponent += String(char)
            }
        }
        
        return components
    }
    
    /// Returns whether this mana cost contains the specified color (simplified)
    public func hasColor(_ colorString: String) -> Bool {
        switch colorString.uppercased() {
        case "W": return white > 0
        case "U": return blue > 0
        case "B": return black > 0
        case "R": return red > 0
        case "G": return green > 0
        case "C": return colorless > 0
        default: return false
        }
    }
    
    /// Returns the mana cost as a string representation
    public var description: String {
        var result = ""
        
        // Add colorless mana first
        if colorless > 0 {
            result += "{\(colorless)}"
        }
        
        // Add colored mana
        for _ in 0..<white { result += "{W}" }
        for _ in 0..<blue { result += "{U}" }
        for _ in 0..<black { result += "{B}" }
        for _ in 0..<red { result += "{R}" }
        for _ in 0..<green { result += "{G}" }
        
        // Add hybrid mana
        for splitColor in splitColors {
            result += "{\(splitColor)}"
        }
        
        return result.isEmpty ? "{0}" : result
    }
    
    // MARK: - Protocol Conformance
    
    public static func == (lhs: ManaCost, rhs: ManaCost) -> Bool {
        return lhs.red == rhs.red &&
               lhs.green == rhs.green &&
               lhs.black == rhs.black &&
               lhs.blue == rhs.blue &&
               lhs.white == rhs.white &&
               lhs.colorless == rhs.colorless &&
               lhs.splitColors == rhs.splitColors
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(red)
        hasher.combine(green)
        hasher.combine(black)
        hasher.combine(blue)
        hasher.combine(white)
        hasher.combine(colorless)
        hasher.combine(splitColors)
    }
}