import SwiftData
import Foundation

@Model
final class Artpiece: Identifiable {
    @Attribute(.unique) var id: Int
    var imageUrl: URL?
    var imageUrlSmall: URL?
    var artist: String
    var title: String
    var year: String
    @Transient var cachedThumbnail: Data?
    
    init(id: Int, imageUrl: URL?, imageUrlSmall: URL?, artist: String, title: String, year: String) {
        self.id = id
        self.imageUrl = imageUrl
        self.imageUrlSmall = imageUrlSmall
        self.artist = artist
        self.title = title
        self.year = year
    }
}

extension Artpiece {
    static func fromDTO(_ dto: ArtpieceDTO) -> Artpiece {
        Artpiece(
            id: dto.objectID,
            imageUrl: URL(string: dto.primaryImage),
            imageUrlSmall: URL(string: dto.primaryImageSmall),
            artist: dto.artistDisplayName == "" ? "Unknown" : dto.artistDisplayName,
            title: dto.title,
            year: dto.objectDate == "" ? "Unknown" : dto.objectDate
        )
    }
}

struct ArtpieceDTO: Decodable {
    var objectID: Int
    var objectDate: String
    var title: String
    var artistDisplayName: String
    var primaryImage: String
    var primaryImageSmall: String
}

struct IDList: Decodable {
    var total: Int
    var objectIDs: [Int]
}
