@testable import FlickrSearch
import FlickrSearchAPI

final class MockSearchPresenter: SearchInteractorOutput {
    var lastPageNumber = 0
    var itemsPerRow = 0
    var totalItems = 0
    var canLoadNextPage = false

    var viewModelImageURL = URL(string: "https://image.url")!
    var viewModelImagCallback: (Result<IdentifiableImage, ImageLoadingError>) -> Void = { _ in }

    let viewDidLoadFuncCheck = ZeroArgumentsFuncCheck()
    func viewDidLoad() {
        viewDidLoadFuncCheck.call()
    }

    let viewModelFuncCheck = FuncCheck<(Int, ImageProvider)>()
    var viewModelStub: ImageViewModel? = nil
    func viewModel(at index: Int, imageProvider: @escaping ImageProvider) -> ImageViewModel? {
        viewModelFuncCheck.call((index, imageProvider))
        imageProvider(viewModelImageURL, viewModelImagCallback)
        return viewModelStub
    }

    let didSelectItemFuncCheck = FuncCheck<(Int, ImageProvider)>()
    func didSelectItem(at index: Int, imageProvider: @escaping ImageProvider) {
        didSelectItemFuncCheck.call((index, imageProvider))
        imageProvider(viewModelImageURL, viewModelImagCallback)
    }

    let removeAllPhotosFuncCheck = ZeroArgumentsFuncCheck()
    func removeAllPhotos() {
        removeAllPhotosFuncCheck.call()
    }

    let presentPhotosFuncCheck = FuncCheck<(Photos, Bool)>()
    func present(photos: Photos, append: Bool) {
        presentPhotosFuncCheck.call((photos, append))
    }

    let presentErrorFuncCheck = FuncCheck<APIError>()
    func present(error: APIError) {
        presentErrorFuncCheck.call(error)
    }

    let presentLoadingStateFuncCheck = ZeroArgumentsFuncCheck()
    func presentLoadingState() {
        presentLoadingStateFuncCheck.call()
    }
}
