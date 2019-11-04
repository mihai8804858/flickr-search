@testable import FlickrSearch
import XCTest
import FlickrSearchAPI

final class FullscreenImageInteractorTests: XCTestCase {
    func testInteractorOnViewDidLoadCallsPresenter() {
        let presenter = MockFullscreenImagePresenter()
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
        let provider: ImageProvider = { url, callback in
            providerFuncCheck.call((url, callback))
        }
        let interactor = FullscreenImageInteractor(presenter: presenter, photo: photo, imageProvider: provider)
        interactor.viewDidLoad()
        XCTAssertTrue(presenter.presentImageFuncCheck.wasCalled(with: { $0.0 == photo }))
        XCTAssertFalse(providerFuncCheck.wasCalled)
    }
}
