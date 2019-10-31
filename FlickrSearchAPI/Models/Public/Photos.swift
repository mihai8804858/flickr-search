public struct Photos: Equatable, Decodable {
    public let page: PhotosPage

    enum CodingKeys: String, CodingKey {
        case page = "photos"
    }

    public init(page: PhotosPage) {
        self.page = page
    }
}
