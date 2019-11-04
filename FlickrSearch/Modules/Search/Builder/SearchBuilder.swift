import UIKit
import FlickrSearchAPI

struct SearchBuilder {
    func buildModule() -> UIViewController {
        let api = FlickrSearchAPI(apiKey: "3e7cc266ae2b0e0d78e279ce8e361736")
        let imageLoader = ImageLoader(api: api, cacher: ImageCacher(storage: FileManager.default))
        let view = SearchViewController.instantiate()
        let presenter = SearchPresenter(view: view)
        let debouncer = Debouncer(interval: 0.5)
        let interactor = SearchInteractor(presenter: presenter, api: api, imageLoader: imageLoader, debouncer: debouncer)
        view.interactor = interactor

        return view
    }
}
