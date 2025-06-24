import Foundation

/// We use Scryfall's color_identity attribute to determine the color sources
/// of a land card. In some cases, this is incorrect. Rather than parse the
/// the oracle text, we simply keep a map of land cards and the mana cost
/// we wish them to represent.
extension Card {
    public static let SPECIAL_LANDS: [String: ManaCost] = [
        // Utility Lands
        "Slayers' Stronghold": ManaCost.fromColorCounts(colorless: 1),
        "Alchemist's Refuge": ManaCost.fromColorCounts(colorless: 1),
        "Desolate Lighthouse": ManaCost.fromColorCounts(colorless: 1),

        // Fetch Lands
        "Arid Mesa": ManaCost.fromColorCounts(white: 1, red: 1),
        "Bloodstained Mire": ManaCost.fromColorCounts(black: 1, red: 1),
        "Flooded Strand": ManaCost.fromColorCounts(white: 1, blue: 1),
        "Marsh Flats": ManaCost.fromColorCounts(white: 1, black: 1),
        "Misty Rainforest": ManaCost.fromColorCounts(blue: 1, green: 1),
        "Polluted Delta": ManaCost.fromColorCounts(blue: 1, black: 1),
        "Scalding Tarn": ManaCost.fromColorCounts(blue: 1, red: 1),
        "Verdant Catacombs": ManaCost.fromColorCounts(black: 1, green: 1),
        "Windswept Heath": ManaCost.fromColorCounts(white: 1, green: 1),
        "Wooded Foothills": ManaCost.fromColorCounts(red: 1, green: 1),
        "Fabled Passage": ManaCost.fromColorCounts(white: 1, blue: 1, black: 1, red: 1, green: 1),
        "Evolving Wilds": ManaCost.fromColorCounts(white: 1, blue: 1, black: 1, red: 1, green: 1),
    ]
}
