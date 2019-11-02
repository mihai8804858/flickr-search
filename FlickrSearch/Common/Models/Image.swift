import UIKit

struct Image {
    let id: String
    let image: UIImage

    init(id: String, image: UIImage) {
        self.id = id
        self.image = image
    }
}

extension Image: Cacheable {
    init?(id: String, data: Data) {
        guard let image = UIImage(data: data) else { return nil }
        self.init(id: id, image: image)
    }

    func toData() -> Data? {
        return image.pngData()
    }
}
