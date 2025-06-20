public struct AutoTapResult {
    public var paid: Bool = false
    public var cmc: Bool = false
    public var inOpeningHand: Bool = false
    public var inDrawHand: Bool = false
    
    // Commander-specific properties
    public var isCommander: Bool = false
    
    // Companion-specific properties
    public var isCompanion: Bool = false

    public init() {}
}
