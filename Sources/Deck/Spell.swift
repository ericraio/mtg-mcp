import Card

/// A class representing a spell with a specified number of uses and an associated `Card`.
public class Spell {
    /// The card that this spell references.
    public let card: Card

    /// The number of times this spell can be used.
    public let count: Int

    /// Initializes a new `Spell` with the given card and count.
    ///
    /// - Parameters:
    ///   - card: The card associated with this spell.
    ///   - count: The number of times this spell can be used.
    public init(card: Card, count: Int) {
        self.card = card
        self.count = count
    }
}
