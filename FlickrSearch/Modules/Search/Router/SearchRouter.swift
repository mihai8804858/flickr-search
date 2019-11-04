import UIKit
import FlickrSearchAPI

protocol SearchRouting {
    func presentFullscreenImage(for photo: Photo, imageProvider: @escaping ImageProvider)
}

struct SearchRouter: SearchRouting {
    private let source: UIViewController

    init(source: UIViewController) {
        self.source = source
    }

    func presentFullscreenImage(for photo: Photo, imageProvider: @escaping ImageProvider) {
        let view = FullscreenImageBuilder().buildModule(for: photo, imageProvider: imageProvider)
        source.present(view, animated: true)
    }
}
