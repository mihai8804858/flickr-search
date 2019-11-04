@testable import FlickrSearch
import XCTest
import FlickrSearchAPI

final class FullscreenImagePresenterTests: XCTestCase {
    func testPresenterWhenImageLoadingFailedSetsPlaceholderImage() {
        let view = MockFullscreenImageView()
        let photo = Photo(
            id: "id",
            owner: "owner",
            secret: "secret",
            server: "server",
            farm: 1,
            title: "title",
            isPublic: true,
            isFriend: true,
            isFamily: true
        )
        let providerFuncCheck = FuncCheck<(URL, (Result<IdentifiableImage, ImageLoadingError>) -> Void)>()
        let providerStub: Result<IdentifiableImage, ImageLoadingError> = .failure(.badData(Data()))
        let provider: ImageProvider = { url, callback in
            providerFuncCheck.call((url, callback))
            callback(providerStub)
        }
        let presenter = FullscreenImagePresenter(view: view)
        presenter.presentImage(for: photo, imageProvider: provider)
        XCTAssertTrue(view.setPlaceholderImageFuncCheck.wasCalled)
        XCTAssertFalse(view.setImageFuncCheck.wasCalled)
        XCTAssertTrue(providerFuncCheck.wasCalled(with: { $0.0 == photo.sourceURL }))
    }

    func testPresenterWhenImageLoadingSucceededSetsImage() {
        let view = MockFullscreenImageView()
        let photo = Photo(
            id: "id",
            owner: "owner",
            secret: "secret",
            server: "server",
            farm: 1,
            title: "title",
            isPublic: true,
            isFriend: true,
            isFamily: true
        )
        let image = UIImage()
        let providerFuncCheck = FuncCheck<(URL, (Result<IdentifiableImage, ImageLoadingError>) -> Void)>()
        let providerStub: Result<IdentifiableImage, ImageLoadingError> = .success(IdentifiableImage(id: "id", image: image))
        let provider: ImageProvider = { url, callback in
            providerFuncCheck.call((url, callback))
            callback(providerStub)
        }
        let presenter = FullscreenImagePresenter(view: view)
        presenter.presentImage(for: photo, imageProvider: provider)
        XCTAssertFalse(view.setPlaceholderImageFuncCheck.wasCalled)
        XCTAssertTrue(view.setImageFuncCheck.wasCalled(with: image))
        XCTAssertTrue(providerFuncCheck.wasCalled(with: { $0.0 == photo.sourceURL }))
    }
}
