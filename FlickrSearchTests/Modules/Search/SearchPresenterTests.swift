@testable import FlickrSearch
import XCTest
import FlickrSearchAPI

final class SearchPresenterTests: XCTestCase {
    func testPresenterReturnsLastPageNumberWhenThereAreNoPages() {
        let presenter = SearchPresenter(view: MockSearchView(), router: MockSearchRouter())
        XCTAssertEqual(presenter.lastPageNumber, 0)
    }

    func testPresenterReturnsLastPageNumberWhenThereArePages() {
        let presenter = SearchPresenter(view: MockSearchView(), router: MockSearchRouter())
        presenter.present(photos: Photos(page: PhotosPage(
            pageNumber: 2,
            totalPagesCount: 3,
            perPageCount: 100,
            totalPhotosCount: 1000,
            photos: []
        )), append: false)
        XCTAssertEqual(presenter.lastPageNumber, 2)
    }

    func testPresenterReturnsTotalItems() {
        let presenter = SearchPresenter(view: MockSearchView(), router: MockSearchRouter())
        presenter.present(
            photos: Photos(page: PhotosPage(
                pageNumber: 2,
                totalPagesCount: 3,
                perPageCount: 100,
                totalPhotosCount: 1000,
                photos: [
                    Photo(
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
                ]
            )),
            append: false
        )
        XCTAssertEqual(presenter.totalItems, 1)
    }

    func testPresenterCanLoadNextPageWhenThereAreNoPagesLoadedYet() {
        let presenter = SearchPresenter(view: MockSearchView(), router: MockSearchRouter())
        XCTAssertTrue(presenter.canLoadNextPage)
    }

    func testPresenterCanLoadNextPageWhenLoadedPageIsNotLast() {
        let presenter = SearchPresenter(view: MockSearchView(), router: MockSearchRouter())
        presenter.present(
            photos: Photos(page: PhotosPage(
                pageNumber: 2,
                totalPagesCount: 3,
                perPageCount: 100,
                totalPhotosCount: 1000,
                photos: []
            )),
            append: false
        )
        XCTAssertTrue(presenter.canLoadNextPage)
    }

    func testPresenterCantLoadNextPageWhenLoadedPageIsLast() {
        let presenter = SearchPresenter(view: MockSearchView(), router: MockSearchRouter())
        presenter.present(
            photos: Photos(page: PhotosPage(
                pageNumber: 2,
                totalPagesCount: 2,
                perPageCount: 100,
                totalPhotosCount: 1000,
                photos: []
            )),
            append: false
        )
        XCTAssertFalse(presenter.canLoadNextPage)
    }

    func testPresenterOnViewDidLoadSetsEmptyState() {
        let view = MockSearchView()
        let presenter = SearchPresenter(view: view, router: MockSearchRouter())
        presenter.viewDidLoad()
        XCTAssertTrue(view.setStateFuncCheck.wasCalled(with: .empty))
    }

    func testPresenterWhenPhotosAreEmptySetsLoadingStateToView() {
        let view = MockSearchView()
        let presenter = SearchPresenter(view: view, router: MockSearchRouter())
        presenter.presentLoadingState()
        XCTAssertTrue(view.setStateFuncCheck.wasCalled(with: .loading(resultsEmpty: true)))
    }

    func testPresenterWhenPhotosAreNotEmptySetsLoadingStateToView() {
        let view = MockSearchView()
        let presenter = SearchPresenter(view: view, router: MockSearchRouter())
        presenter.present(
            photos: Photos(page: PhotosPage(
                pageNumber: 2,
                totalPagesCount: 2,
                perPageCount: 100,
                totalPhotosCount: 1000,
                photos: [
                    Photo(
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
                ]
            )),
            append: false
        )
        presenter.presentLoadingState()
        XCTAssertTrue(view.setStateFuncCheck.wasCalled(with: .loading(resultsEmpty: false)))
    }

    func testPresenterWhenErrorIsCancelledDoesntPresentErroor() {
        let view = MockSearchView()
        let presenter = SearchPresenter(view: view, router: MockSearchRouter())
        let error = APIError.cancelled
        presenter.present(error: error)
        XCTAssertFalse(view.setStateFuncCheck.wasCalled(with: .failed(reasonTitle: "Ooops!", reasonMessage: error.debugDescription)))
    }

    func testPresenterWhenErrorIsNotCancelledPresentsError() {
        let view = MockSearchView()
        let presenter = SearchPresenter(view: view, router: MockSearchRouter())
        let error = APIError.badRequest
        presenter.present(error: error)
        XCTAssertTrue(view.setStateFuncCheck.wasCalled(with: .failed(reasonTitle: "Ooops!", reasonMessage: error.debugDescription)))
    }

    func testPresenterWhenRemovingAllPhotosSetsEmptyState() {
        let view = MockSearchView()
        let presenter = SearchPresenter(view: view, router: MockSearchRouter())
        presenter.present(
            photos: Photos(page: PhotosPage(
                pageNumber: 2,
                totalPagesCount: 2,
                perPageCount: 100,
                totalPhotosCount: 1000,
                photos: [
                    Photo(
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
                ]
            )),
            append: false
        )
        presenter.removeAllPhotos()
        XCTAssertEqual(presenter.totalItems, 0)
        XCTAssertTrue(view.setStateFuncCheck.wasCalled(with: .empty))
    }

    func testPresenterWhenPresentingEmptyPhotosAndAppendingSetsNoResultsState() {
        let view = MockSearchView()
        let presenter = SearchPresenter(view: view, router: MockSearchRouter())
        presenter.present(
            photos: Photos(page: PhotosPage(
                pageNumber: 1,
                totalPagesCount: 2,
                perPageCount: 100,
                totalPhotosCount: 1000,
                photos: []
            )),
            append: true
        )
        XCTAssertTrue(view.setStateFuncCheck.wasCalled(with: .noResults))
    }

    func testPresenterWhenPresentingEmptyPhotosAndNotAppendingSetsNoResultsState() {
        let view = MockSearchView()
        let presenter = SearchPresenter(view: view, router: MockSearchRouter())
        presenter.present(
            photos: Photos(page: PhotosPage(
                pageNumber: 1,
                totalPagesCount: 2,
                perPageCount: 100,
                totalPhotosCount: 1000,
                photos: []
            )),
            append: false
        )
        XCTAssertTrue(view.setStateFuncCheck.wasCalled(with: .noResults))
    }

    func testPresenterWhenPresentingNonEmptyPhotosAndAppendingSetsLoadedState() {
        let view = MockSearchView()
        let presenter = SearchPresenter(view: view, router: MockSearchRouter())
        presenter.present(
            photos: Photos(page: PhotosPage(
                pageNumber: 1,
                totalPagesCount: 2,
                perPageCount: 100,
                totalPhotosCount: 1000,
                photos: [
                    Photo(
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
                ]
            )),
            append: true
        )
        XCTAssertTrue(view.setStateFuncCheck.wasCalled(with: .loaded(type: .insert(indices: [IndexPath(row: 0, section: 0)]))))
    }

    func testPresenterWhenPresentingNonEmptyPhotosAndNotAppendingSetsLoadedState() {
        let view = MockSearchView()
        let presenter = SearchPresenter(view: view, router: MockSearchRouter())
        presenter.present(
            photos: Photos(page: PhotosPage(
                pageNumber: 1,
                totalPagesCount: 2,
                perPageCount: 100,
                totalPhotosCount: 1000,
                photos: [
                    Photo(
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
                ]
            )),
            append: false
        )
        XCTAssertTrue(view.setStateFuncCheck.wasCalled(with: .loaded(type: .reloadData)))
    }

    func testPresenterWhenDidSelectItemAndThereAreNoPhotosDoesntPresentFullscreenImage() {
        let router = MockSearchRouter()
        let presenter = SearchPresenter(view: MockSearchView(), router: router)
        presenter.didSelectItem(at: 0) { _, _ in }
        XCTAssertFalse(router.presentFullscreenImageFuncCheck.wasCalled)
    }

    func testPresenterWhenDidSelectItemAndFarmIsZeroDoesntPresentFullscreenImage() {
        let router = MockSearchRouter()
        let presenter = SearchPresenter(view: MockSearchView(), router: router)
        presenter.present(
            photos: Photos(page: PhotosPage(
                pageNumber: 1,
                totalPagesCount: 2,
                perPageCount: 100,
                totalPhotosCount: 1000,
                photos: [
                    Photo(
                        id: "id",
                        owner: "owner",
                        secret: "secret",
                        server: "server",
                        farm: 0,
                        title: "title",
                        isPublic: true,
                        isFriend: true,
                        isFamily: true
                    )
                ]
            )),
            append: false
        )
        presenter.didSelectItem(at: 0) { _, _ in }
        XCTAssertFalse(router.presentFullscreenImageFuncCheck.wasCalled)
    }

    func testPresenterWhenDidSelectItemAndThereArePhotosPresentsFullscreenImage() {
        let router = MockSearchRouter()
        let presenter = SearchPresenter(view: MockSearchView(), router: router)
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
        presenter.present(
            photos: Photos(page: PhotosPage(
                pageNumber: 1,
                totalPagesCount: 2,
                perPageCount: 100,
                totalPhotosCount: 1000,
                photos: [photo]
            )),
            append: false
        )
        presenter.didSelectItem(at: 0) { _, _ in }
        XCTAssertTrue(router.presentFullscreenImageFuncCheck.wasCalled { $0.0 == photo })
    }

    func testPresenterWhenGettingViewModelAndThereAreNoPhotosReturnsNil() {
        let presenter = SearchPresenter(view: MockSearchView(), router: MockSearchRouter())
        let model = presenter.viewModel(at: 0) { _, _ in }
        XCTAssertNil(model)
    }

    func testPresenterWhenGettingViewModelAndThereArePhotosReturnsModel() {
        let presenter = SearchPresenter(view: MockSearchView(), router: MockSearchRouter())
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
        presenter.present(
            photos: Photos(page: PhotosPage(
                pageNumber: 1,
                totalPagesCount: 2,
                perPageCount: 100,
                totalPhotosCount: 1000,
                photos: [photo]
            )),
            append: false
        )
        let model = presenter.viewModel(at: 0) { _, _ in }
        XCTAssertNotNil(model)
        XCTAssertEqual(model?.photoID, photo.id)
    }
}
