import Card
import Foundation
import Scryfall
import Database

/// Advanced deck builder with enhanced parsing capabilities from swift-landlord
public struct DeckParser {

    // Special card markers in deck code
    private static let commanderMarker: String = "CMDR:"
    private static let companionMarker: String = "COMP:"

    // Regex pattern for Arena deck format
    // Matches patterns like "2 Lightning Bolt (M19) 156" or "4 Sol Ring"
    static let arenaLineRegex: NSRegularExpression = {
        do {
            return try NSRegularExpression(
                pattern:
                    "^\\s*(?<amount>\\d+)\\s+(?<name>[^\\(#\\n\\r]+?)(?:\\s*\\((?<set>\\w+)\\)\\s+(?<setnum>\\d+))?\\s*(?:#.*)?$",
                options: []
            )
        } catch {
            // Fallback simple regex if the complex one fails
            return try! NSRegularExpression(pattern: "^\\s*(\\d+)\\s+(.+?)\\s*$", options: [])
        }
    }()

    /// Parses a deck list text into structured deck data with enhanced format support
    public static func parseDeckList(_ deckText: String) -> DeckData {
        var deckData = DeckData()

        let lines = deckText.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .newlines)

        var currentSection: DeckSection = .unknown

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            // Skip empty lines and comments
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("//") || trimmedLine.hasPrefix("#") {
                continue
            }

            // Handle pipe-delimited format from swift-landlord
            if trimmedLine.contains("|") {
                return parsePipeDelimitedFormat(deckText)
            }

            // Check for section headers
            let lowerLine = trimmedLine.lowercased()
            if lowerLine == "deck" || lowerLine == "main" || lowerLine == "maindeck" {
                currentSection = .main
                continue
            } else if lowerLine == "sideboard" || lowerLine == "side" {
                currentSection = .sideboard
                continue
            } else if lowerLine == "commander" {
                currentSection = .commander
                continue
            }

            // Check for special card markers
            if trimmedLine.hasPrefix(commanderMarker) {
                let commanderName = String(trimmedLine.dropFirst(commanderMarker.count))
                    .trimmingCharacters(in: .whitespaces)
                if let commanderCard = createCard(
                    name: commanderName, quantity: 1, section: .commander)
                {
                    deckData.commander = commanderCard
                }
                continue
            }

            if trimmedLine.hasPrefix(companionMarker) {
                let companionName = String(trimmedLine.dropFirst(companionMarker.count))
                    .trimmingCharacters(in: .whitespaces)
                if let companionCard = createCard(
                    name: companionName, quantity: 1, section: .companion)
                {
                    deckData.companion = companionCard
                }
                continue
            }

            // Try to parse card entry with advanced parsing
            if let cardEntry = parseCardLineAdvanced(trimmedLine) {
                let cards = createCards(from: cardEntry, section: currentSection)

                switch currentSection {
                case .main:
                    deckData.mainDeck.append(contentsOf: cards)
                case .sideboard:
                    deckData.sideboard.append(contentsOf: cards)
                case .commander:
                    if let firstCard = cards.first {
                        var commanderCard = firstCard
                        commanderCard.kind.isCommander = true
                        deckData.commander = commanderCard
                    }
                case .companion:
                    if let firstCard = cards.first {
                        var companionCard = firstCard
                        companionCard.kind.isCompanion = true
                        deckData.companion = companionCard
                    }
                case .unknown:
                    // If no section specified, assume main deck
                    deckData.mainDeck.append(contentsOf: cards)
                }
            }
        }

        return deckData
    }

    /// Parses pipe-delimited format from swift-landlord
    private static func parsePipeDelimitedFormat(_ deckText: String) -> DeckData {
        var deckData = DeckData()
        var nextIsCommander = false

        // Split the input string into rows
        let rows = deckText.trimmingCharacters(in: .whitespacesAndNewlines).components(
            separatedBy: "|")

        for row in rows {
            // Skip the first entry which is typically the deck name
            if row.contains("Custom Deck:") {
                continue
            }

            let trimmedRow = row.trimmingCharacters(in: .whitespaces)

            // Section headers for commander/deck
            if trimmedRow.lowercased() == "commander" {
                nextIsCommander = true
                continue
            }
            if trimmedRow.lowercased() == "deck" {
                nextIsCommander = false
                continue
            }

            // Handle commander from header
            if nextIsCommander {
                let components = trimmedRow.components(separatedBy: " ")
                guard components.count >= 2, let quantity = Int(components[0]), quantity > 0 else {
                    nextIsCommander = false
                    continue
                }
                let cardName = components.dropFirst().joined(separator: " ")
                if let commanderCard = createCard(
                    name: cardName, quantity: quantity, section: .commander)
                {
                    deckData.commander = commanderCard
                    // Also add to main deck for the parsing
                    deckData.mainDeck.append(commanderCard)
                }
                nextIsCommander = false
                continue
            }

            // Parse regular card entries
            let components = trimmedRow.components(separatedBy: " ")
            guard components.count >= 2,
                let quantity = Int(components[0]),
                quantity > 0
            else {
                continue
            }

            let cardName = components.dropFirst().joined(separator: " ")
            if let card = createCard(name: cardName, quantity: 1, section: .main) {
                // Add multiple copies
                for _ in 0..<quantity {
                    deckData.mainDeck.append(card)
                }
            }
        }

        return deckData
    }

    /// Advanced card line parsing with Arena format support
    private static func parseCardLineAdvanced(_ line: String) -> CardEntry? {
        // Try Arena regex first
        let range = NSRange(location: 0, length: line.utf16.count)
        if let match = arenaLineRegex.firstMatch(in: line, options: [], range: range) {

            // Extract quantity
            let quantityRange = match.range(at: 1)
            guard quantityRange.location != NSNotFound,
                let quantityString = extractString(from: line, range: quantityRange),
                let quantity = Int(quantityString), quantity > 0
            else {
                return nil
            }

            // Extract card name
            let nameRange = match.range(at: 2)
            guard nameRange.location != NSNotFound,
                let cardName = extractString(from: line, range: nameRange)
            else {
                return nil
            }

            let cleanName = cardName.trimmingCharacters(in: .whitespaces)
            guard !cleanName.isEmpty else { return nil }

            // Extract set info if present (optional)
            var setCode: String? = nil
            var collectorNumber: String? = nil

            if match.numberOfRanges > 3 {
                let setRange = match.range(at: 3)
                if setRange.location != NSNotFound {
                    setCode = extractString(from: line, range: setRange)
                }
            }

            if match.numberOfRanges > 4 {
                let numberRange = match.range(at: 4)
                if numberRange.location != NSNotFound {
                    collectorNumber = extractString(from: line, range: numberRange)
                }
            }

            return CardEntry(
                name: cleanName,
                quantity: quantity,
                setCode: setCode,
                collectorNumber: collectorNumber
            )
        }

        // Fallback to basic parsing
        return parseCardLine(line)
    }

    /// Helper to extract strings from NSRange
    private static func extractString(from string: String, range: NSRange) -> String? {
        guard range.location != NSNotFound else { return nil }
        let start = string.index(string.startIndex, offsetBy: range.location)
        let end = string.index(start, offsetBy: range.length)
        return String(string[start..<end])
    }

    /// Original simple card line parsing (fallback)
    private static func parseCardLine(_ line: String) -> CardEntry? {
        let components = line.components(separatedBy: " ")
        guard components.count >= 2 else { return nil }

        let firstComponent = components[0]
        var quantity: Int = 0
        let nameStartIndex = 1

        // Try to parse quantity
        if firstComponent.hasSuffix("x") {
            // Format like "4x"
            let quantityString = String(firstComponent.dropLast())
            quantity = Int(quantityString) ?? 0
        } else {
            // Format like "4"
            quantity = Int(firstComponent) ?? 0
        }

        guard quantity > 0 else { return nil }

        // Extract card name (everything after quantity, before set info)
        var nameComponents = Array(components.dropFirst(nameStartIndex))

        // Remove set information if present (text in parentheses)
        if let parenIndex = nameComponents.firstIndex(where: { $0.hasPrefix("(") }) {
            nameComponents = Array(nameComponents.prefix(parenIndex))
        }

        let cardName = nameComponents.joined(separator: " ").trimmingCharacters(in: .whitespaces)

        guard !cardName.isEmpty else { return nil }

        return CardEntry(name: cardName, quantity: quantity)
    }

    /// Creates cards from a card entry with enhanced land detection
    private static func createCards(from entry: CardEntry, section: DeckSection) -> [Card] {
        var cards: [Card] = []

        for _ in 0..<entry.quantity {
            var card = Card(name: entry.name)

            // Set special designations based on section
            switch section {
            case .commander:
                card.kind.isCommander = true
            case .companion:
                card.kind.isCompanion = true
            default:
                break
            }

            // Use comprehensive land detection
            if LandDetectionService.isLand(entry.name) {
                card.kind.isLand = true

                // Set specific land subtypes
                let landCategory = LandDetectionService.getLandCategory(entry.name)
                setLandKind(card: &card, category: landCategory)
            }

            // Store set information if available
            if let setCode = entry.setCode {
                card.set.code = setCode
            }

            cards.append(card)
        }

        return cards
    }

    /// Helper to create a single card
    private static func createCard(name: String, quantity: Int, section: DeckSection) -> Card? {
        let entry = CardEntry(name: name, quantity: quantity)
        let cards = createCards(from: entry, section: section)
        return cards.first
    }

    /// Sets the appropriate land kind based on category
    private static func setLandKind(card: inout Card, category: LandCategory) {
        switch category {
        case .basic:
            card.kind.isBasicLand = true
        case .shock:
            card.kind.isShockLand = true
        case .fetch:
            card.kind.isOtherLand = true  // Fetch lands are classified as other
        case .check:
            card.kind.isCheckLand = true
        case .battle:
            card.kind.isBattleLand = true
        case .tap:
            card.kind.isTapLand = true
        case .utility:
            card.kind.isOtherLand = true
        case .mdfc:
            card.kind.hasLandBackface = true
        case .other:
            card.kind.isOtherLand = true
        case .none:
            break
        }
    }

    /// Gets appropriate type line for land based on category and name
    private static func getLandTypeLine(for cardName: String, category: LandCategory) -> String {
        switch category {
        case .basic:
            if cardName.contains("Snow-Covered") {
                return "Basic Snow Land"
            }
            return "Basic Land"
        case .shock, .fetch, .check, .battle, .tap, .utility, .other:
            return "Land"
        case .mdfc:
            return "Land"  // MDFC land faces are typically just "Land"
        case .none:
            return ""
        }
    }
}

/// Enhanced card entry with set information
private struct CardEntry {
    let name: String
    let quantity: Int
    let setCode: String?
    let collectorNumber: String?

    init(name: String, quantity: Int, setCode: String? = nil, collectorNumber: String? = nil) {
        self.name = name
        self.quantity = quantity
        self.setCode = setCode
        self.collectorNumber = collectorNumber
    }
}

/// Enhanced deck sections including companion
private enum DeckSection {
    case main
    case sideboard
    case commander
    case companion
    case unknown
}

