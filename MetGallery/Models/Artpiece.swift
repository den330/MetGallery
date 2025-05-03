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
    var cachedThumbnail: Data?
    var department: String
    var collections: [APCollection] = []
    
    init(id: Int, imageUrl: URL?, imageUrlSmall: URL?, artist: String, title: String, year: String, department: String) {
        self.id = id
        self.imageUrl = imageUrl
        self.imageUrlSmall = imageUrlSmall
        self.artist = artist
        self.title = title
        self.year = year
        self.department = department
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
            year: dto.objectDate == "" ? "Unknown" : dto.objectDate,
            department: dto.department
        )
    }
}

struct ArtpieceDTO: Decodable, Equatable {
    var objectID: Int
    var objectDate: String
    var title: String
    var artistDisplayName: String
    var primaryImage: String
    var primaryImageSmall: String
    var isFav: Bool? = false
    var department: String
    static func == (lhs: ArtpieceDTO, rhs: ArtpieceDTO) -> Bool {
        lhs.objectID == rhs.objectID
    }
}

struct IDList: Decodable {
    var total: Int
    var objectIDs: [Int]
}
