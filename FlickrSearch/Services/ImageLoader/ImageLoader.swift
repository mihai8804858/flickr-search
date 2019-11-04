import UIKit
import FlickrSearchAPI

final class ImageLoader: ImageLoading {
    let api: FlickrSearchAPIType
    let cacher: ImageCacher

    init(api: FlickrSearchAPIType, cacher: ImageCacher) {
        self.api = api
        self.cacher = cacher
    }

    func getImage(from url: URL, callback: Callback<Result<IdentifiableImage, ImageLoadingError>>) {
        getCachedImage(for: url, callback: callback.chain { [weak self] image, callback in
            guard let self = self else { return }
            if let cachedImage = image {
                return callback.execute(with: .success(cachedImage))
            } else {
                self.loadAndSaveImage(from: url, callback: callback)
            }
        })
    }

    private func getCachedImage(for url: URL, callback: Callback<IdentifiableImage?>) {
        let id = IdentifiableImage.imageID(for: url)
        cacher.contains(forID: id, callback: callback.chain { [weak self] exists, callback in
            guard let self = self else { return }
            guard exists else { return callback.execute(with: nil) }
            self.cacher.get(forID: id, callback: callback)
        })
    }

    private func loadAndSaveImage(from url: URL, callback: Callback<Result<IdentifiableImage, ImageLoadingError>>) {
        loadImage(from: url, callback: callback.map { [weak self] result in
            guard let self = self else { return result }
            if let image = try? result.get() {
                self.cacher.set(model: image)
            }
            return result
        })
    }

    private func loadImage(from url: URL, callback: Callback<Result<IdentifiableImage, ImageLoadingError>>) {
        api.data(from: url, callback: callback.map { result in
            switch result {
            case .success(let data):
                guard let image = IdentifiableImage(url: url, data: data) else {
                    return .failure(.badData(data))
                }
                return .success(image)
            case .failure(let error):
                return .failure(.api(error))
            }
        }).resume()
    }
}
