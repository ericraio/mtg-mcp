import Foundation
import Card
import Database

class DeckBuilder {
    var invalid: Bool = false
    var invalidMessage: String = ""
    var cards: [Card] = []
    
    // Special card markers in deck code
    private let commanderMarker: String = "CMDR:"
    private let companionMarker: String = "COMP:"

    // Regex pattern for Arena deck format
    // Note: Swift regex is slightly different from Go's regex
    static let arenaLineRegex: NSRegularExpression = try! NSRegularExpression(
        pattern: "^\\s*(?<amount>\\d+)\\s+(?<name>[^\\(#\\n\\r]+)(?:\\s*\\((?<set>\\w+)\\)\\s+(?<setnum>\\d+))?\\s*#?(?:\\s*[Xx]\\s*=\\s*(?<X>\\d+))?(?:\\s*[Tt]\\s*=\\s*(?<T>\\d+))?(?:\\s*[Mm]\\s*=\\s*(?<M>[RGWUB\\d{}]+))?",
        options: []
    )

    init() {}

    func loadCardsFromList(code: String) -> DeckData {
        var deckData: DeckData = DeckData()
        let cardData: CardData = CardData.shared
        var nextIsCommander: Bool = false

        // Split the input string into rows
        let rows: [String] = code.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "|")

        // If using another format, adapt this part accordingly
        for row: String in rows {
            // Skip the first entry which is the deck name
            if row.contains("Custom Deck:") {
                continue
            }
            
            let trimmedRow: String = row.trimmingCharacters(in: .whitespaces)
            
            // Section headers for commander/deck
            if trimmedRow.lowercased() == "commander" {
                nextIsCommander = true
                continue
            }
            if trimmedRow.lowercased() == "deck" {
                nextIsCommander = false
                continue
            }
            
            // Check if this is a commander or companion card
            if trimmedRow.hasPrefix(commanderMarker) {
                let commanderName: String = trimmedRow.dropFirst(commanderMarker.count).trimmingCharacters(in: .whitespaces)
                if let commanderCard: Card = cardData.findByName(name: commanderName) {
                    // Create a new card with commander properties
                    var commanderKind = commanderCard.kind
                    commanderKind.isCommander = true
                    let updatedCommanderCard = Card(
                        id: commanderCard.id,
                        name: commanderCard.name,
                        oracleID: commanderCard.oracleID,
                        manaCostString: commanderCard.manaCostString,
                        imageURI: commanderCard.imageURI,
                        kind: commanderKind,
                        turn: commanderCard.turn,
                        arenaID: commanderCard.arenaID,
                        rarity: commanderCard.rarity,
                        set: commanderCard.set,
                        isFace: commanderCard.isFace
                    )
                    deckData.commander = updatedCommanderCard
                    // Also add it to the deck
                    deckData.cards.append(updatedCommanderCard)
                } else {
                    invalid = true
                    invalidMessage = "Unable to find commander card \(commanderName)"
                }
                continue
            }
            
            if trimmedRow.hasPrefix(companionMarker) {
                let companionName: String = trimmedRow.dropFirst(companionMarker.count).trimmingCharacters(in: .whitespaces)
                if let companionCard: Card = cardData.findByName(name: companionName) {
                    // Create a new card with companion properties
                    var companionKind = companionCard.kind
                    companionKind.isCompanion = true
                    let updatedCompanionCard = Card(
                        id: companionCard.id,
                        name: companionCard.name,
                        oracleID: companionCard.oracleID,
                        manaCostString: companionCard.manaCostString,
                        imageURI: companionCard.imageURI,
                        kind: companionKind,
                        turn: companionCard.turn,
                        arenaID: companionCard.arenaID,
                        rarity: companionCard.rarity,
                        set: companionCard.set,
                        isFace: companionCard.isFace
                    )
                    deckData.companion = updatedCompanionCard
                    // Don't add companion to the deck as it starts outside
                } else {
                    invalid = true
                    invalidMessage = "Unable to find companion card \(companionName)"
                }
                continue
            }

            // Handle commander from header
            if nextIsCommander {
                let components: [String] = trimmedRow.components(separatedBy: " ")
                guard components.count >= 2, let quantity: Int = Int(components[0]), quantity > 0 else {
                    print("Failed to parse commander row: \(trimmedRow)")
                    nextIsCommander = false
                    continue
                }
                let cardName: String = components.dropFirst().joined(separator: " ")
                if let commanderCard: Card = cardData.findByName(name: cardName) {
                    // Create a new card with commander properties
                    var commanderKind = commanderCard.kind
                    commanderKind.isCommander = true
                    let updatedCommanderCard = Card(
                        id: commanderCard.id,
                        name: commanderCard.name,
                        oracleID: commanderCard.oracleID,
                        manaCostString: commanderCard.manaCostString,
                        imageURI: commanderCard.imageURI,
                        kind: commanderKind,
                        turn: commanderCard.turn,
                        arenaID: commanderCard.arenaID,
                        rarity: commanderCard.rarity,
                        set: commanderCard.set,
                        isFace: commanderCard.isFace
                    )
                    deckData.commander = updatedCommanderCard
                    for _ in 1...quantity {
                        deckData.cards.append(updatedCommanderCard)
                    }
                } else {
                    invalid = true
                    invalidMessage = "Unable to find commander card \(cardName)"
                }
                nextIsCommander = false
                continue
            }
            // Parse the card entry (e.g., "1 Sol Ring")
            let components: [String] = trimmedRow.components(separatedBy: " ")

            guard components.count >= 2,
                let quantity: Int = Int(components[0]),
                quantity > 0 else {
                print("Failed to parse row: \(trimmedRow)")
                continue
            }

            let cardName: String = components.dropFirst().joined(separator: " ")

            // Find the card in the database
            guard let card: Card = cardData.findByName(name: cardName) else {
                invalid = true
                invalidMessage = "Unable to find card \(cardName)"
                continue
            }

            // Add multiple copies of the card
            for _ in 1...quantity {
                deckData.cards.append(card)
            }
        }

        print("Finished loading \(deckData.cards.count) cards")
        if let commander: Card = deckData.commander {
            print("Commander: \(commander.name)")
        }
        if let companion: Card = deckData.companion {
            print("Companion: \(companion.name)")
        }
        
        return deckData
    }
}
