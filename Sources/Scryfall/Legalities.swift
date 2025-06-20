import Foundation

public struct Legalities: Codable {
    let standard: String
    let future: String
    let historic: String
    let pioneer: String
    let modern: String
    let legacy: String
    let pauper: String
    let vintage: String
    let penny: String
    let commander: String
    let brawl: String
    let duel: String
    let oldschool: String
    
    enum CodingKeys: String, CodingKey {
        case standard
        case future
        case historic
        case pioneer
        case modern
        case legacy
        case pauper
        case vintage
        case penny
        case commander
        case brawl
        case duel
        case oldschool
    }
    
    public func isLegal() -> Bool {
        return !notLegal()
    }
    
    public func notLegal() -> Bool {
        // Swift doesn't have the same reflection capabilities as Go
        // but we can use Mirror to achieve a similar result
        let mirror = Mirror(reflecting: self)
        let totalFields = mirror.children.count
        var notLegalCount = 0
        
        for child in mirror.children {
            if let value = child.value as? String, value == "not_legal" {
                notLegalCount += 1
            }
        }
        
        return notLegalCount == totalFields
    }
}
