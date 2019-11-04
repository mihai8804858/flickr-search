import Foundation

protocol Cacheable: Identifiable {
    init?(id: String, data: Data)
    func toData() -> Data?
}
