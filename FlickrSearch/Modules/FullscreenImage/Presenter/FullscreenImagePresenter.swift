import UIKit
import FlickrSearchAPI

protocol FullscreenImagePresenterOutput: class {
    func setPlaceholderImage()
    func set(image: UIImage)
}

final class FullscreenImagePresenter: FullscreenImageInteractorOutput {
    private weak var view: FullscreenImagePresenterOutput?

    init(view: FullscreenImagePresenterOutput?) {
        self.view = view
    }

    func presentImage(for photo: Photo, imageProvider: @escaping ImageProvider) {
        guard let url = photo.sourceURL else {
            view?.setPlaceholderImage()
            return
        }
        imageProvider(url) { [weak self] result in
            switch result {
            case .success(let image):
                self?.view?.set(image: image.image)
            case .failure(let error):
                debugPrint(error.debugDescription)
                self?.view?.setPlaceholderImage()
            }
        }
    }
}
