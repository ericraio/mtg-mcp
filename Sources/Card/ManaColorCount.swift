import Foundation

/// Represents mana color combinations and their frequency counts
public struct ManaColorCount {
    // Single colors
    var total: UInt8 = 0
    var colorless: UInt8 = 0
    var white: UInt8 = 0
    var blue: UInt8 = 0
    var black: UInt8 = 0
    var red: UInt8 = 0
    var green: UInt8 = 0

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

    /// Creates a new ManaColorCount with all counts initialized to zero
    public init() {
        // All properties already initialized to zero
    }

    /// Counts mana combinations from a given mana cost
    /// - Parameter manaCost: The mana cost to analyze
    mutating func count(manaCost: ManaCost) {
        total += 1
        red += manaCost.red
        black += manaCost.black
        green += manaCost.green
        blue += manaCost.blue
        white += manaCost.white
        colorless += manaCost.colorless

        // Helper shorthand references to detect presence of colors (not exact values)
        let r = manaCost.red > 0
        let b = manaCost.black > 0
        let g = manaCost.green > 0
        let u = manaCost.blue > 0
        let w = manaCost.white > 0
        
        // Calculate color count
        let colorCount = (r ? 1 : 0) + (g ? 1 : 0) + (b ? 1 : 0) + (u ? 1 : 0) + (w ? 1 : 0)
        
        // Only check guilds if there are exactly 2 colors
        if colorCount == 2 {
            // Check for guild color pairs
            if r && g { gruul += 1 }   // RG
            if r && b { rakdos += 1 }  // BR
            if r && u { izzet += 1 }   // UR
            if r && w { boros += 1 }   // RW
            if b && g { golgari += 1 } // BG
            if g && u { simic += 1 }   // GU
            if g && w { selesnya += 1 }// GW
            if b && w { orzhov += 1 }  // WB
            if u && w { azorius += 1 } // WU
            if b && u { dimir += 1 }   // UB
        }
        
        // Only check tri-colors if there are exactly 3 colors
        if colorCount == 3 {
            // Check for shards (allied three-color combinations)
            if g && w && u { bant += 1 }   // GWU
            if w && u && b { esper += 1 }  // WUB
            if u && b && r { grixis += 1 } // UBR
            if b && r && g { jund += 1 }   // BRG
            if r && g && w { naya += 1 }   // RGW

            // Check for wedges (enemy three-color combinations)
            if w && b && g { abzan += 1 }  // WBG
            if u && r && w { jeskai += 1 } // URW
            if b && g && u { sultai += 1 } // BGU
            if r && w && b { mardu += 1 }  // RWB
            if g && u && r { temur += 1 }  // GUR
        }
    }

    /// Provides a dictionary of color pair counts with guild names as keys
    var guildCounts: [String: UInt8] {
        [
            "Azorius": azorius,
            "Orzhov": orzhov,
            "Dimir": dimir,
            "Izzet": izzet,
            "Rakdos": rakdos,
            "Golgari": golgari,
            "Gruul": gruul,
            "Boros": boros,
            "Selesnya": selesnya,
            "Simic": simic,
        ]
    }

    /// Provides a dictionary of three-color shard counts with shard names as keys
    var shardCounts: [String: UInt8] {
        [
            "Bant": bant,
            "Esper": esper,
            "Grixis": grixis,
            "Jund": jund,
            "Naya": naya,
        ]
    }

    /// Provides a dictionary of three-color wedge counts with wedge names as keys
    var wedgeCounts: [String: UInt8] {
        [
            "Abzan": abzan,
            "Jeskai": jeskai,
            "Sultai": sultai,
            "Mardu": mardu,
            "Temur": temur,
        ]
    }

    /// Provides a combined dictionary of all three-color combinations
    var tricolorCounts: [String: UInt8] {
        var combined = shardCounts
        combined.merge(wedgeCounts) { (_, new) in new }
        return combined
    }

    /// Returns the total count of cards with exactly two colors
    var totalTwoColorCards: UInt8 {
        azorius + orzhov + dimir + izzet + rakdos + golgari + gruul + boros + selesnya + simic
    }

    /// Returns the total count of cards with exactly three colors
    var totalThreeColorCards: UInt8 {
        // Sum of all shard and wedge counts
        bant + esper + grixis + jund + naya + abzan + jeskai + sultai + mardu + temur
    }

    /// Returns the most common guild color pair
    var mostCommonGuild: (name: String, count: UInt8)? {
        let guilds = guildCounts
        guard let maxPair = guilds.max(by: { $0.value < $1.value }) else {
            return nil
        }

        // Only return if there's at least one count
        return maxPair.value > 0 ? (name: maxPair.key, count: maxPair.value) : nil
    }

    /// Returns the most common three-color combination
    var mostCommonTricolor: (name: String, count: UInt8)? {
        let tricolors = tricolorCounts
        guard let maxTricolor = tricolors.max(by: { $0.value < $1.value }) else {
            return nil
        }

        // Only return if there's at least one count
        return maxTricolor.value > 0 ? (name: maxTricolor.key, count: maxTricolor.value) : nil
    }

    /// Returns color distribution statistics
    var colorDistribution: [String: UInt8] {
        [
            "Colorless": colorless,
            "White": white,
            "Blue": blue,
            "Black": black,
            "Red": red,
            "Green": green,
            "Two-color": totalTwoColorCards,
            "Three-color": totalThreeColorCards,
        ]
    }
}

// MARK: - ManaCost


// MARK: - MTG Color Combinations Reference

/// Provides reference information about Magic: The Gathering color combinations
struct MTGColorReference {
    /// Guild names and their color combinations
    static let guilds: [(name: String, colors: String)] = [
        ("Azorius", "WU"), ("Orzhov", "WB"), ("Dimir", "UB"),
        ("Izzet", "UR"), ("Rakdos", "BR"), ("Golgari", "BG"),
        ("Gruul", "RG"), ("Boros", "RW"), ("Selesnya", "GW"),
        ("Simic", "GU"),
    ]

    /// Shard names and their color combinations (allied three-color)
    static let shards: [(name: String, colors: String)] = [
        ("Bant", "GWU"), ("Esper", "WUB"), ("Grixis", "UBR"),
        ("Jund", "BRG"), ("Naya", "RGW"),
    ]

    /// Wedge names and their color combinations (enemy three-color)
    static let wedges: [(name: String, colors: String)] = [
        ("Abzan", "WBG"), ("Jeskai", "URW"), ("Sultai", "BGU"),
        ("Mardu", "RWB"), ("Temur", "GUR"),
    ]
}
