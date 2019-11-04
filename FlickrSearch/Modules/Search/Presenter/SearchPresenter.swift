import FlickrSearchAPI

protocol SearchPresenterOutput: class {
    func set(state: SearchViewState)
}

final class SearchPresenter: SearchInteractorOutput {
    private weak var view: SearchPresenterOutput?
    private var pages: [PhotosPage] = []

    private var allPhotos: [Photo] {
        return pages.reduce([]) { $0 + $1.photos }
    }

    let itemsPerRow = 3

    var totalItems: Int {
        return allPhotos.count
    }

    var canLoadNextPage: Bool {
        guard let currentPage = pages.last else { return true }
        return currentPage.pageNumber < currentPage.totalPagesCount
    }

    init(view: SearchPresenterOutput?) {
        self.view = view
    }

    var lastPageNumber: Int {
        return Int(pages.last?.pageNumber ?? 0)
    }

    func viewDidLoad() {
        view?.set(state: .empty)
    }

    func viewModel(at index: Int, imageProvider: @escaping ImageProvider) -> ImageViewModel? {
        guard 0..<totalItems ~= index else { return nil }
        let photo = allPhotos[index]
        return ImageViewModel(photoID: photo.id) { callback in
            guard let url = photo.sourceURL else { return }
            imageProvider(url) { result in
                switch result {
                case .success(let image):
                    callback(photo.id, image.image)
                case .failure(let error):
                    debugPrint(error.debugDescription)
                }
            }
        }
    }

    func removeAllPhotos() {
        pages.removeAll()
        view?.set(state: .empty)
    }

    func present(photos: Photos, append: Bool) {
        let type: ReloadType = {
            if append {
                let indices = indicesToAppend(count: photos.page.photos.count)
                pages.append(photos.page)
                return .insert(indices: indices)
            } else {
                pages.removeAll()
                pages = [photos.page]
                return .reloadData
            }
        }()
        view?.set(state: allPhotos.isEmpty ? .noResults : .loaded(type: type))
    }

    func present(error: APIError) {
        if error == .cancelled { return }
        view?.set(state: .failed(reasonTitle: "Ooops!", reasonMessage: error.debugDescription))
    }

    func presentLoadingState() {
        view?.set(state: .loading(resultsEmpty: allPhotos.isEmpty))
    }
}

private extension SearchPresenter {
    func indicesToAppend(count: Int) -> [IndexPath] {
        let startIndex = totalItems
        let endIndex = startIndex + count
        return (startIndex..<endIndex).map { [0, $0] }
    }
}
