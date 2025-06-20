/// Union type for different response content types
public enum ResponseContent: Codable {
    case cardSearch(CardSearchContent)
    case comboLookup(ComboLookupContent)
    case gameAction(GameActionContent)
    case edhrecAnalysis(EDHRecAnalysisContent)
    case deckAnalysis(DeckAnalysisContent)
    case ruleValidation(RuleValidationContent)
    case simulation(SimulationContent)

    private enum CodingKeys: String, CodingKey {
        case type, data
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .cardSearch(let content):
            try container.encode("card_search", forKey: .type)
            try container.encode(content, forKey: .data)
        case .comboLookup(let content):
            try container.encode("combo_lookup", forKey: .type)
            try container.encode(content, forKey: .data)
        case .gameAction(let content):
            try container.encode("game_action", forKey: .type)
            try container.encode(content, forKey: .data)
        case .edhrecAnalysis(let content):
            try container.encode("edhrec_analysis", forKey: .type)
            try container.encode(content, forKey: .data)
        case .deckAnalysis(let content):
            try container.encode("deck_analysis", forKey: .type)
            try container.encode(content, forKey: .data)
        case .ruleValidation(let content):
            try container.encode("rule_validation", forKey: .type)
            try container.encode(content, forKey: .data)
        case .simulation(let content):
            try container.encode("simulation", forKey: .type)
            try container.encode(content, forKey: .data)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "card_search":
            let content = try container.decode(CardSearchContent.self, forKey: .data)
            self = .cardSearch(content)
        case "combo_lookup":
            let content = try container.decode(ComboLookupContent.self, forKey: .data)
            self = .comboLookup(content)
        case "game_action":
            let content = try container.decode(GameActionContent.self, forKey: .data)
            self = .gameAction(content)
        case "edhrec_analysis":
            let content = try container.decode(EDHRecAnalysisContent.self, forKey: .data)
            self = .edhrecAnalysis(content)
        case "deck_analysis":
            let content = try container.decode(DeckAnalysisContent.self, forKey: .data)
            self = .deckAnalysis(content)
        case "rule_validation":
            let content = try container.decode(RuleValidationContent.self, forKey: .data)
            self = .ruleValidation(content)
        case "simulation":
            let content = try container.decode(SimulationContent.self, forKey: .data)
            self = .simulation(content)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container, debugDescription: "Unknown response type: \(type)")
        }
    }
}
