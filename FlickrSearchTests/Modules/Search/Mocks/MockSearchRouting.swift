@testable import FlickrSearch
import FlickrSearchAPI

final class MockSearchRouter: SearchRouting {
    let presentFullscreenImageFuncCheck = FuncCheck<(Photo, ImageProvider)>()
    func presentFullscreenImage(for photo: Photo, imageProvider: @escaping ImageProvider) {
        presentFullscreenImageFuncCheck.call((photo, imageProvider))
    }
}
