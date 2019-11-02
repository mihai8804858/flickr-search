import UIKit
import FlickrSearchAPI

enum ImageLoadingError: Error, CustomDebugStringConvertible {
    case api(APIError)
    case badData(Data)

    var debugDescription: String {
        switch self {
        case .api(let error):
            return error.debugDescription
        case .badData:
            return "Bad data"
        }
    }
}

protocol ImageLoading {
    func getImage(from url: URL, callbackQueue: DispatchQueue?, callback: @escaping (Result<Image, ImageLoadingError>) -> Void)
}

final class ImageLoader: ImageLoading {
    let api: FlickrSearchAPIType
    let cacher: ImageCacher

    init(api: FlickrSearchAPIType, cacher: ImageCacher) {
        self.api = api
        self.cacher = cacher
    }

    func getImage(from url: URL, callbackQueue: DispatchQueue?, callback: @escaping (Result<Image, ImageLoadingError>) -> Void) {
        getCachedImage(for: url, callbackQueue: callbackQueue) { [weak self] image in
            guard let self = self else { return }
            if let cachedImage = image {
                callback(.success(cachedImage))
            } else {
                self.loadAndSaveImage(from: url, callbackQueue: callbackQueue, callback: callback)
            }
        }
    }

    private func getCachedImage(for url: URL, callbackQueue: DispatchQueue?, callback: @escaping (Image?) -> Void) {
        let id = imageID(for: url)
        cacher.contains(forID: id, callbackQueue: callbackQueue) { [weak self] exists in
            guard let self = self else { return }
            guard exists else { return callback(nil) }
            self.cacher.get(forID: id, callbackQueue: callbackQueue, callback: callback)
        }
    }

    private func loadAndSaveImage(from url: URL, callbackQueue: DispatchQueue?, callback: @escaping (Result<Image, ImageLoadingError>) -> Void) {
        loadImage(from: url, callbackQueue: callbackQueue) { [weak self] result in
            guard let self = self else { return }
            if let image = try? result.get() {
                self.cacher.set(model: image)
            }
            callback(result)
        }
    }

    private func loadImage(from url: URL, callbackQueue: DispatchQueue?, callback: @escaping (Result<Image, ImageLoadingError>) -> Void) {
        api.data(from: url, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let data):
                guard let image = Image(id: String(url.absoluteString.hashValue), data: data) else {
                    return callback(.failure(.badData(data)))
                }
                callback(.success(image))
            case .failure(let error):
                callback(.failure(.api(error)))
            }
        }.resume()
    }

    private func imageID(for url: URL) -> String {
        return String(url.absoluteString.hashValue)
    }
}
