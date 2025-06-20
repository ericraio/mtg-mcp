import Foundation

public struct Prices: Codable {
    let usd: AnyCodable?
    let usdFoil: AnyCodable?
    let eur: AnyCodable?
    let eurFoil: AnyCodable?
    let tix: AnyCodable?
    
    enum CodingKeys: String, CodingKey {
        case usd
        case usdFoil = "usd_foil"
        case eur
        case eurFoil = "eur_foil"
        case tix
    }
}
