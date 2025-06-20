import Foundation

/// Represents different mulligan strategy types
public enum Strategy: String {
    case never = "NEVER"
    case london = "LONDON"

    /// Validates if a string represents a valid Strategy
    public static func validate(_ value: String) -> Bool {
        return Strategy(rawValue: value) != nil
    }
    
    /// Attempts to set a Strategy from a string
    /// Returns true if successful, false if the string is not a valid strategy
    public static func set(value: String) -> (success: Bool, strategy: Strategy?) {
        guard let strategy = Strategy(rawValue: value) else {
            return (false, nil)
        }
        return (true, strategy)
    }
    
    /// Creates a new Strategy from a string
    /// Returns nil if the string is not a valid strategy
    public static func new(_ value: String) -> Strategy? {
        return Strategy(rawValue: value)
    }
}
