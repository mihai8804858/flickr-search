import UIKit

protocol Cacheable: Identifiable {
    init?(id: String, data: Data)
    func toData() -> Data?
}

protocol Caching {
    associatedtype Model: Cacheable
    func contains(forID id: String, callbackQueue: DispatchQueue?, callback: @escaping (Bool) -> Void)
    func get(forID id: String, callbackQueue: DispatchQueue?, callback: @escaping (Model?) -> Void)
    func set(model: Model)
}

final class ImageCacher: Caching {
    private let storage: Atomic<Storage>
    private let cache = Atomic<NSCache<NSString, NSData>>(.init())
    private let workQueue = DispatchQueue(label: "IMAGE_CACHING_WORK_QUEUE", qos: .utility)

    init(storage: Storage) {
        self.storage = Atomic(storage)
        createImagesDirectoryIfNeeded()
    }

    func contains(forID id: String, callbackQueue: DispatchQueue?, callback: @escaping (Bool) -> Void) {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            let diskURL = self.diskURL(for: id)
            let existsInCache = self.cache.execute { $0.object(forKey: id as NSString) != nil }
            let existsOnDisk = self.storage.execute { $0.fileExists(at: diskURL) }
            let exists = existsInCache || existsOnDisk
            if let queue = callbackQueue {
                queue.async { callback(exists) }
            } else {
                callback(exists)
            }
        }
    }

    func get(forID id: String, callbackQueue: DispatchQueue?, callback: @escaping (Image?) -> Void) {
        workQueue.async { [weak self] in
            let image: Image? = {
                guard let self = self else { return nil }
                let diskURL = self.diskURL(for: id)
                if let fromCache = self.cache.execute({ $0.object(forKey: id as NSString) }) {
                    return Image(id: id, data: fromCache as Data)
                } else if let fromDisk = self.storage.execute({ $0.contents(at: diskURL) }) {
                    return Image(id: id, data: fromDisk)
                }
                return nil
            }()
            if let queue = callbackQueue {
                queue.async { callback(image) }
            } else {
                callback(image)
            }
        }
    }

    func set(model: Image) {
        workQueue.async { [weak self] in
            guard let self = self, let data = model.toData() else { return }
            let diskURL = self.diskURL(for: model.id)
            self.cache.execute { $0.setObject(data as NSData, forKey: model.id as NSString) }
            self.storage.execute { $0.createFile(at: diskURL, contents: data) }
        }
    }

    private func diskURL(for id: String) -> URL {
        return imagesDirectoryURL.appendingPathComponent(id + ".jpg")
    }

    private var imagesDirectoryURL: URL {
        return storage.value.documentsDirectory.appendingPathComponent("Images")
    }

    private func createImagesDirectoryIfNeeded() {
        let url = imagesDirectoryURL
        if storage.execute({ $0.fileExists(at: url)  }) { return }
        storage.execute { $0.createDirectory(at: url) }
    }
}
