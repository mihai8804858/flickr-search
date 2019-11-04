@testable import FlickrSearch
import FlickrSearchAPI

final class MockFullscreenImagePresenter: FullscreenImageInteractorOutput {
    let presentImageFuncCheck = FuncCheck<(Photo, ImageProvider)>()
    func presentImage(for photo: Photo, imageProvider: @escaping ImageProvider) {
        presentImageFuncCheck.call((photo, imageProvider))
    }
}
