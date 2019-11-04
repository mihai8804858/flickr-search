import UIKit

struct IdentifiableImage: Identifiable {
    let id: String
    let image: UIImage

    init(id: String, image: UIImage) {
        self.id = id
        self.image = image
    }

    init(url: URL, image: UIImage) {
        self.id = IdentifiableImage.imageID(for: url)
        self.image = image
    }

    static func imageID(for url: URL) -> String {
        return String(url.absoluteString.hashValue)
    }
}

extension IdentifiableImage: Cacheable {
    init?(id: String, data: Data) {
        guard let image = UIImage(data: data) else { return nil }
        self.init(id: id, image: image)
    }

    init?(url: URL, data: Data) {
        guard let image = UIImage(data: data) else { return nil }
        self.init(url: url, image: image)
    }

    func toData() -> Data? {
        return image.pngData()
    }
}
