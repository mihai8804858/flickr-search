import FlickrSearchAPI

typealias ImageProvider = (URL, @escaping (Result<IdentifiableImage, ImageLoadingError>) -> Void) -> Void

protocol SearchInteractorOutput: class {
    var lastPageNumber: Int { get }
    var itemsPerRow: Int { get }
    var totalItems: Int { get }
    var canLoadNextPage: Bool { get }

    func viewDidLoad()
    func viewModel(at index: Int, imageProvider: @escaping ImageProvider) -> ImageViewModel?
    func didSelectItem(at index: Int, imageProvider: @escaping ImageProvider)
    func removeAllPhotos()
    func present(photos: Photos, append: Bool)
    func present(error: APIError)
    func presentLoadingState()
}

final class SearchInteractor: SearchViewOutput {
    private let presenter: SearchInteractorOutput
    private let api: FlickrSearchAPIType
    private let imageLoader: ImageLoading
    private let debouncer: Debouncing

    private var currentQuery: String?
    private var currentTask: Task?

    var itemsPerRow: Int {
        return presenter.itemsPerRow
    }

    var totalItems: Int {
        return presenter.totalItems
    }

    init(presenter: SearchInteractorOutput, api: FlickrSearchAPIType, imageLoader: ImageLoading, debouncer: Debouncing) {
        self.presenter = presenter
        self.api = api
        self.imageLoader = imageLoader
        self.debouncer = debouncer
    }

    func viewDidLoad() {
        presenter.viewDidLoad()
    }

    func searchTextDidChange(_ searchText: String) {
        if searchText.isEmpty {
            debouncer.cancel()
            currentTask?.cancel()
            currentTask = nil
            currentQuery = nil
            presenter.removeAllPhotos()
        } else {
            debouncer.debounce { [weak self] in
                self?.currentQuery = searchText
                self?.search(with: searchText, append: false)
            }
        }
    }

    func didScrollToBottom() {
        guard let query = currentQuery, presenter.canLoadNextPage else { return }
        search(with: query, append: true)
    }

    func viewModel(at index: Int) -> ImageViewModel? {
        return presenter.viewModel(at: index) { [weak self] url, callback in
            guard let self = self else { return }
            self.imageLoader.getImage(from: url, callback: .init(queue: .main, callback: callback))
        }
    }

    func didSelectItem(at index: Int) {
        presenter.didSelectItem(at: index) { [weak self] url, callback in
           guard let self = self else { return }
           self.imageLoader.getImage(from: url, callback: .init(queue: .main, callback: callback))
       }
    }
}

private extension SearchInteractor {
    func searchParameters(with query: String, append: Bool) -> SearchParameters {
        let pageNumber = append ? presenter.lastPageNumber + 1 : 1
        let pageSize = Int(100 / presenter.itemsPerRow) * presenter.itemsPerRow
        return SearchParameters(query: query, page: UInt(pageNumber), pageSize: UInt(pageSize))
    }

    func search(with query: String, append: Bool) {
        let parameters = searchParameters(with: query, append: append)
        currentTask?.cancel()
        presenter.presentLoadingState()
        currentTask = api.search(with: parameters, callback: .init(queue: .main) { [weak self] result in
            guard let self = self else { return }
            self.currentTask = nil
            switch result {
            case .success(let photos):
                self.presenter.present(photos: photos, append: append)
            case .failure(let error):
                self.presenter.present(error: error)
            }
        })
        currentTask?.resume()
    }
}
