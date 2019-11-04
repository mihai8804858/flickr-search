import UIKit
import FlickrSearchAPI

struct FullscreenImageBuilder {
    func buildModule(for photo: Photo, imageProvider: @escaping ImageProvider) -> UIViewController {
        let view = FullscreenImageViewController.instantiate()
        let interactor = FullscreenImageInteractor(
            presenter: FullscreenImagePresenter(view: view),
            photo: photo,
            imageProvider: imageProvider
        )
        view.interactor = interactor

        return view
    }
}
