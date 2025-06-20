import Foundation

/// Represents a section of the MTG Comprehensive Rules
public struct RuleSection {
    public let number: String
    public let title: String
    public let subsections: [String]

    public init(number: String, title: String, subsections: [String] = []) {
        self.number = number
        self.title = title
        self.subsections = subsections
    }
}