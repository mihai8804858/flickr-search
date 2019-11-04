import FlickrSearchAPI

protocol FullscreenImageInteractorOutput: class {
    func presentImage(for photo: Photo, imageProvider: @escaping ImageProvider)
}

final class FullscreenImageInteractor: FullscreenImageViewOutput {
    private let presenter: FullscreenImageInteractorOutput
    private let photo: Photo
    private let imageProvider: ImageProvider

    init(presenter: FullscreenImageInteractorOutput, photo: Photo, imageProvider: @escaping ImageProvider) {
        self.presenter = presenter
        self.photo = photo
        self.imageProvider = imageProvider
    }

    func viewDidLoad() {
        presenter.presentImage(for: photo, imageProvider: imageProvider)
    }
}
