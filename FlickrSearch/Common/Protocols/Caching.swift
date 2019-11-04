import Dispatch
import FlickrSearchAPI

protocol Caching {
    associatedtype Model: Cacheable
    func contains(forID id: String, callback: Callback<Bool>)
    func get(forID id: String, callback: Callback<Model?>)
    func set(model: Model)
}

protocol ImageCaching: Caching where Model == IdentifiableImage {
}
