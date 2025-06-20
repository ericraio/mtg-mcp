import Card

/// Represents a simulated card with kind, hash, and mana cost
public class SimCard {
    public var kind: CardKind
    public var hash: UInt64
    public var manaCost: ManaCost
    
    /// Whether this card is a commander
    public var isCommander: Bool {
        get { return kind.isCommander }
        set { kind.isCommander = newValue }
    }
    
    /// Whether this card is a companion
    public var isCompanion: Bool {
        get { return kind.isCompanion }
        set { kind.isCompanion = newValue }
    }
    
    public init(kind: CardKind, hash: UInt64, manaCost: ManaCost) {
        self.kind = kind
        self.hash = hash
        self.manaCost = manaCost
    }
    
    /// Creates a new SimCard with default values
    public static func new() -> SimCard {
        var kind = CardKind()
        kind.setUnknown()
        
        return SimCard(
            kind: kind,
            hash: 0,
            manaCost: ManaCost()
        )
    }
}
