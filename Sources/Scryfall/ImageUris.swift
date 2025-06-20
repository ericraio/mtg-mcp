import Foundation

public struct ImageUris: Codable {
    let small: String
    let normal: String
    let large: String
    let png: String
    let artCrop: String
    let borderCrop: String
    
    enum CodingKeys: String, CodingKey {
        case small
        case normal
        case large
        case png
        case artCrop = "art_crop"
        case borderCrop = "border_crop"
    }
}
