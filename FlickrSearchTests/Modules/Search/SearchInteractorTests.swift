@testable import FlickrSearch
import XCTest
import FlickrSearchAPI

final class SearchInteractorTests: XCTestCase {
    func testInteractorReturnsItemsPerRow() {
        let presenter = MockSearchPresenter()
        let interactor = SearchInteractor(
            presenter: presenter,
            api: MockFlickrSearchAPI(),
            imageLoader: MockImageLoading(),
            debouncer: MockDebouncer()
        )
        presenter.itemsPerRow = 3
        XCTAssertEqual(interactor.itemsPerRow, 3)
    }

    func testInteractorReturnsTotalItems() {
        let presenter = MockSearchPresenter()
        let interactor = SearchInteractor(
            presenter: presenter,
            api: MockFlickrSearchAPI(),
            imageLoader: MockImageLoading(),
            debouncer: MockDebouncer()
        )
        presenter.totalItems = 1000
        XCTAssertEqual(interactor.totalItems, 1000)
    }

    func testInteractorOnViewDidLoadCallsPresenter() {
        let presenter = MockSearchPresenter()
        let interactor = SearchInteractor(
            presenter: presenter,
            api: MockFlickrSearchAPI(),
            imageLoader: MockImageLoading(),
            debouncer: MockDebouncer()
        )
        interactor.viewDidLoad()
        XCTAssertTrue(presenter.viewDidLoadFuncCheck.wasCalled)
    }

    func testInteractorReturnsViewModelFromPresenter() {
        let presenter = MockSearchPresenter()
        presenter.viewModelStub = ImageViewModel(photoID: "id") { _ in }
        let interactor = SearchInteractor(
            presenter: presenter,
            api: MockFlickrSearchAPI(),
            imageLoader: MockImageLoading(),
            debouncer: MockDebouncer()
        )
        let viewModel = interactor.viewModel(at: 0)
        XCTAssertEqual(viewModel?.photoID, "id")
        XCTAssertTrue(presenter.viewModelFuncCheck.wasCalled(with: { $0.0 == 0 }))
    }

    func testInteractorLoadsImageForViewModel() {
        let presenter = MockSearchPresenter()
        let loader = MockImageLoading()
        let imageURL = URL(string: "https://image.url")!
        presenter.viewModelStub = ImageViewModel(photoID: "id") { _ in }
        presenter.viewModelImageURL = imageURL
        let interactor = SearchInteractor(
            presenter: presenter,
            api: MockFlickrSearchAPI(),
            imageLoader: loader,
            debouncer: MockDebouncer()
        )
        let viewModel = interactor.viewModel(at: 0)
        viewModel?.imageProvider { _, _ in }
        XCTAssertTrue(loader.getImageFuncCheck.wasCalled(with: { $0.0 == imageURL }))
    }

    func testInteractorCallsPresenterWhenDidSelectItem() {
        let presenter = MockSearchPresenter()
        let interactor = SearchInteractor(
            presenter: presenter,
            api: MockFlickrSearchAPI(),
            imageLoader: MockImageLoading(),
            debouncer: MockDebouncer()
        )
        interactor.didSelectItem(at: 0)
        XCTAssertTrue(presenter.didSelectItemFuncCheck.wasCalled(with: { $0.0 == 0 }))
    }

    func testInteractorLoadsImageWhenDidSelectItem() {
        let presenter = MockSearchPresenter()
        let loader = MockImageLoading()
        let imageURL = URL(string: "https://image.url")!
        presenter.viewModelImageURL = imageURL
        let interactor = SearchInteractor(
            presenter: presenter,
            api: MockFlickrSearchAPI(),
            imageLoader: loader,
            debouncer: MockDebouncer()
        )
        interactor.didSelectItem(at: 0)
        XCTAssertTrue(loader.getImageFuncCheck.wasCalled(with: { $0.0 == imageURL }))
    }

    func testInteractorWhenSearchWithEmptyQueryRemovesAllPhotos() {
        let presenter = MockSearchPresenter()
        let debouncer = MockDebouncer()
        let interactor = SearchInteractor(
            presenter: presenter,
            api: MockFlickrSearchAPI(),
            imageLoader: MockImageLoading(),
            debouncer: debouncer
        )
        interactor.searchTextDidChange("")
        XCTAssertTrue(debouncer.cancelFuncCheck.wasCalled)
        XCTAssertTrue(presenter.removeAllPhotosFuncCheck.wasCalled)
    }

    func testInteractorWhenSearchWithNonEmptyQueryLoadsPhotosFromAPI() {
        let debouncer = MockDebouncer()
        let presenter = MockSearchPresenter()
        let api = MockFlickrSearchAPI()
        let photos = Photos(page: PhotosPage(
            pageNumber: 1,
            totalPagesCount: 1,
            perPageCount: 0,
            totalPhotosCount: 0,
            photos: []
        ))
        api.searchStub = .success(photos)
        presenter.lastPageNumber = 0
        presenter.itemsPerRow = 3
        let interactor = SearchInteractor(
            presenter: presenter,
            api: api,
            imageLoader: MockImageLoading(),
            debouncer: debouncer
        )
        let parameters = SearchParameters(query: "a", page: 1, pageSize: 99)
        interactor.searchTextDidChange("a")
        XCTAssertTrue(debouncer.debounceFuncCheck.wasCalled)
        XCTAssertTrue(api.searchFuncCheck.wasCalled(with: { $0.0 == parameters }))
    }

    func testInteractorWhenSearchWithNonEmptyQueryPresentsLoadingState() {
        let presenter = MockSearchPresenter()
        let api = MockFlickrSearchAPI()
        let photos = Photos(page: PhotosPage(
            pageNumber: 1,
            totalPagesCount: 1,
            perPageCount: 0,
            totalPhotosCount: 0,
            photos: []
        ))
        api.searchStub = .success(photos)
        presenter.lastPageNumber = 0
        presenter.itemsPerRow = 3
        let interactor = SearchInteractor(
            presenter: presenter,
            api: api,
            imageLoader: MockImageLoading(),
            debouncer: MockDebouncer()
        )
        interactor.searchTextDidChange("a")
        XCTAssertTrue(presenter.presentLoadingStateFuncCheck.wasCalled)
    }

    func testInteractorWhenSearchWithNonEmptyQueryAndRequestFailedPresentsError() {
        let presenter = MockSearchPresenter()
        let api = MockFlickrSearchAPI()
        let error = APIError.badRequest
        api.searchStub = .failure(error)
        presenter.lastPageNumber = 0
        presenter.itemsPerRow = 3
        let interactor = SearchInteractor(
            presenter: presenter,
            api: api,
            imageLoader: MockImageLoading(),
            debouncer: MockDebouncer()
        )
        interactor.searchTextDidChange("a")
        wait(for: [presenter.presentErrorFuncCheck.wasCalledExpectation(with: { $0 == error })], timeout: 1)
    }

    func testInteractorWhenSearchWithNonEmptyQueryAndRequestSucceededPresentsPhotos() {
        let presenter = MockSearchPresenter()
        let api = MockFlickrSearchAPI()
        let photos = Photos(page: PhotosPage(
            pageNumber: 1,
            totalPagesCount: 1,
            perPageCount: 0,
            totalPhotosCount: 0,
            photos: []
        ))
        api.searchStub = .success(photos)
        presenter.lastPageNumber = 0
        presenter.itemsPerRow = 3
        let interactor = SearchInteractor(
            presenter: presenter,
            api: api,
            imageLoader: MockImageLoading(),
            debouncer: MockDebouncer()
        )
        interactor.searchTextDidChange("a")
        wait(for: [presenter.presentPhotosFuncCheck.wasCalledExpectation(with: { $0.0 == photos })], timeout: 1)
    }

    func testInteractorWhenDidScrollToBottomAndThereIsNoPreviousQueryShouldNotLoadMorePhotos() {
        let presenter = MockSearchPresenter()
        let api = MockFlickrSearchAPI()
        let photos = Photos(page: PhotosPage(
            pageNumber: 1,
            totalPagesCount: 1,
            perPageCount: 0,
            totalPhotosCount: 0,
            photos: []
        ))
        api.searchStub = .success(photos)
        presenter.lastPageNumber = 0
        presenter.itemsPerRow = 3
        presenter.canLoadNextPage = true
        let interactor = SearchInteractor(
            presenter: presenter,
            api: api,
            imageLoader: MockImageLoading(),
            debouncer: MockDebouncer()
        )
        interactor.didScrollToBottom()
        XCTAssertFalse(api.searchFuncCheck.wasCalled)
        XCTAssertFalse(presenter.presentPhotosFuncCheck.wasCalled(with: { $0.0 == photos }))
    }

    func testInteractorWhenDidScrollToBottomAndCantLoadMorePhotosShouldNotLoadMorePhotos() {
        let presenter = MockSearchPresenter()
        let api = MockFlickrSearchAPI()
        let photos = Photos(page: PhotosPage(
            pageNumber: 1,
            totalPagesCount: 1,
            perPageCount: 0,
            totalPhotosCount: 0,
            photos: []
        ))
        api.searchStub = .success(photos)
        presenter.lastPageNumber = 0
        presenter.itemsPerRow = 3
        presenter.canLoadNextPage = false
        let interactor = SearchInteractor(
            presenter: presenter,
            api: api,
            imageLoader: MockImageLoading(),
            debouncer: MockDebouncer()
        )
        interactor.didScrollToBottom()
        XCTAssertFalse(api.searchFuncCheck.wasCalled)
        XCTAssertFalse(presenter.presentPhotosFuncCheck.wasCalled(with: { $0.0 == photos }))
    }

    func testInteractorWhenDidScrollToBottomAndCanLoadMorePhotosShouldLoadMorePhotos() {
        let presenter = MockSearchPresenter()
        let api = MockFlickrSearchAPI()
        let photos = Photos(page: PhotosPage(
            pageNumber: 1,
            totalPagesCount: 3,
            perPageCount: 0,
            totalPhotosCount: 0,
            photos: []
        ))
        api.searchStub = .success(photos)
        presenter.lastPageNumber = 0
        presenter.itemsPerRow = 3
        presenter.canLoadNextPage = true
        let interactor = SearchInteractor(
            presenter: presenter,
            api: api,
            imageLoader: MockImageLoading(),
            debouncer: MockDebouncer()
        )
        interactor.searchTextDidChange("a")
        let morePhotos = Photos(page: PhotosPage(
            pageNumber: 2,
            totalPagesCount: 3,
            perPageCount: 0,
            totalPhotosCount: 0,
            photos: []
        ))
        api.searchStub = .success(morePhotos)
        presenter.lastPageNumber = 1
        interactor.didScrollToBottom()
        let parameters = SearchParameters(query: "a", page: 2, pageSize: 99)
        wait(for: [
            api.searchFuncCheck.wasCalledExpectation(with: { $0.0 == parameters }),
            presenter.presentPhotosFuncCheck.wasCalledExpectation(with: { $0.0 == morePhotos })
        ], timeout: 1)
    }
}
