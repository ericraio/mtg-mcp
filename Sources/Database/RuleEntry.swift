import Foundation

/// Represents a single MTG rule entry
public struct RuleEntry: Codable {
    /// The rule number (e.g., "100", "601.2a", "703.4d")
    public let ruleNumber: String
    
    /// The rule title/description
    public let title: String
    
    /// The full markdown content of the rule
    public let content: String
    
    /// The original filename for reference
    public let filename: String
    
    /// The main section number (e.g., "100" for rule "100.1a")
    public let section: String
    
    public init(ruleNumber: String, title: String, content: String, filename: String) {
        self.ruleNumber = ruleNumber
        self.title = title
        self.content = content
        self.filename = filename
        
        // Extract main section from rule number
        if ruleNumber.contains(".") {
            self.section = String(ruleNumber.prefix(3))
        } else {
            self.section = ruleNumber.padding(toLength: 3, withPad: "0", startingAt: 0)
        }
    }
}

/// Container for all MTG comprehensive rules
public struct ComprehensiveRules: Codable {
    /// All rule entries
    public let rules: [RuleEntry]
    
    /// When the rules were last updated
    public let lastUpdated: Date
    
    /// Total number of rules
    public let totalRules: Int
    
    /// Rules version/date string
    public let version: String
    
    public init(rules: [RuleEntry], version: String = "Latest") {
        self.rules = rules
        self.totalRules = rules.count
        self.lastUpdated = Date()
        self.version = version
    }
    
    /// Find a rule by exact rule number
    public func findRule(by ruleNumber: String) -> RuleEntry? {
        return rules.first { $0.ruleNumber == ruleNumber }
    }
    
    /// Find all rules in a specific section (e.g., all 100-series rules)
    public func findRules(inSection section: String) -> [RuleEntry] {
        let normalizedSection = section.padding(toLength: 3, withPad: "0", startingAt: 0)
        return rules.filter { $0.section == normalizedSection }
    }
    
    /// Search rules by keywords in title or content
    public func searchRules(containing keywords: [String]) -> [RuleEntry] {
        return rules.filter { rule in
            let searchText = "\(rule.title) \(rule.content)".lowercased()
            return keywords.allSatisfy { keyword in
                searchText.contains(keyword.lowercased())
            }
        }
    }
}