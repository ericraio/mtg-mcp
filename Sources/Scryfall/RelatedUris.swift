import Foundation

public struct RelatedUris: Codable {
    let tcgplayerInfiniteDecks: String?
    let tcgplayerInfiniteArticles: String?
    let edhrec: String?
    let gatherer: String?
    
    enum CodingKeys: String, CodingKey {
        case tcgplayerInfiniteDecks = "tcgplayer_infinite_decks"
        case tcgplayerInfiniteArticles = "tcgplayer_infinite_articles"
        case edhrec
        case gatherer
    }
}
