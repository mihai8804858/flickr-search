import UIKit
import FlickrSearchAPI

struct SearchBuilder {
    func buildModule() -> UIViewController {
        let api = FlickrSearchAPI(apiKey: "3e7cc266ae2b0e0d78e279ce8e361736")
        let view = SearchViewController.instantiate()
        let interactor = SearchInteractor(
            presenter: SearchPresenter(view: view, router: SearchRouter(source: view)),
            api: api,
            imageLoader: ImageLoader(api: api, cacher: ImageCacher(storage: FileManager.default)),
            debouncer: Debouncer(interval: 0.5)
        )
        view.interactor = interactor

        return view
    }
}
