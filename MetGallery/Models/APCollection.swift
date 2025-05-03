import SwiftData

@Model
class APCollection {
    @Attribute(.unique) var name: String
    @Relationship(inverse: \Artpiece.collections)
    var apList: [Artpiece]
    
    init(name: String, apList: [Artpiece] = []) {
        self.name = name
        self.apList = apList
    }
}

