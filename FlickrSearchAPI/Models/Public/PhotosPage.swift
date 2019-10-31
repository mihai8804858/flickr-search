public struct PhotosPage: Equatable, Decodable {
    public let pageNumber: UInt
    public let totalPagesCount: UInt
    public let perPageCount: UInt
    public let totalPhotosCount: UInt
    public let photos: [Photo]

    enum CodingKeys: String, CodingKey {
        case pageNumber = "page"
        case totalPagesCount = "pages"
        case perPageCount = "perpage"
        case totalPhotosCount = "total"
        case photos = "photo"
    }

    public init(pageNumber: UInt, totalPagesCount: UInt, perPageCount: UInt, totalPhotosCount: UInt, photos: [Photo]) {
        self.pageNumber = pageNumber
        self.totalPagesCount = totalPagesCount
        self.perPageCount = perPageCount
        self.totalPhotosCount = totalPhotosCount
        self.photos = photos
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pageNumber = try container.decode(UInt.self, forKey: .pageNumber)
        totalPagesCount = try container.decode(UInt.self, forKey: .totalPagesCount)
        perPageCount = try container.decode(UInt.self, forKey: .perPageCount)
        photos = try container.decode([Photo].self, forKey: .photos)
        totalPhotosCount = try {
            do {
                return try container.decode(UInt.self, forKey: .totalPhotosCount)
            } catch let error as DecodingError {
                guard case .typeMismatch = error else { throw error }
                let stringValue = try container.decode(String.self, forKey: .totalPhotosCount)
                guard let uIntValue = UInt(stringValue) else {
                    let key = CodingKeys.totalPhotosCount.stringValue
                    let description = "Expecting to decode UInt or String for key \"\(key)\", got \"\(stringValue)\"."
                    throw DecodingError.dataCorruptedError(
                        forKey: CodingKeys.totalPhotosCount,
                        in: container,
                        debugDescription: description
                    )
                }

                return uIntValue
            }
        }()
    }
}
