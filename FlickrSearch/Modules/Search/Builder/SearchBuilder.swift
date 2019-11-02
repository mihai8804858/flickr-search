import UIKit
import FlickrSearchAPI

struct SearchBuilder {
    func buildModule(api: FlickrSearchAPIType, imageLoader: ImageLoading) -> UIViewController {
        let view = SearchViewController.instantiate()
        let presenter = SearchPresenter(view: view)
        let interactor = SearchInteractor(presenter: presenter, api: api, imageLoader: imageLoader)
        view.interactor = interactor

        return view
    }
}
