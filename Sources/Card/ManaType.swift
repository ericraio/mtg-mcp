/// Represents the five colors of mana plus colorless
public enum ManaType: String, CaseIterable {
    case red = "R"
    case green = "G"
    case black = "B"
    case blue = "U"
    case white = "W"
    case colorless = "C"

    /// Whether this mana type is considered a color
    var isColor: Bool {
        self != .colorless
    }
}
