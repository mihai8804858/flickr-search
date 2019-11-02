import FlickrSearchAPI

protocol Cacheable: Identifiable {
    init?(id: String, data: Data)
    func toData() -> Data?
}
