public struct Photo: Equatable, Decodable {
    public let id: String
    public let owner: String
    public let secret: String
    public let server: String
    public let farm: Int
    public let title: String
    public let isPublic: Bool
    public let isFriend: Bool
    public let isFamily: Bool

    public var sourceURL: URL? {
        return URL(string: "http://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg")
    }

    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }

    public init(id: String, owner: String, secret: String, server: String, farm: Int, title: String, isPublic: Bool, isFriend: Bool, isFamily: Bool) {
        self.id = id
        self.owner = owner
        self.secret = secret
        self.server = server
        self.farm = farm
        self.title = title
        self.isPublic = isPublic
        self.isFriend = isFriend
        self.isFamily = isFamily
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        owner = try container.decode(String.self, forKey: .owner)
        secret = try container.decode(String.self, forKey: .secret)
        server = try container.decode(String.self, forKey: .server)
        farm = try container.decode(Int.self, forKey: .farm)
        title = try container.decode(String.self, forKey: .title)
        isPublic = try container.decode(Int.self, forKey: .isPublic) != 0
        isFriend = try container.decode(Int.self, forKey: .isFriend) != 0
        isFamily = try container.decode(Int.self, forKey: .isFamily) != 0
    }
}
