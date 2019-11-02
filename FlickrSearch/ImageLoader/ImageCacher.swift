import UIKit

protocol Caching {
    associatedtype Model: Cacheable
    func contains(forID id: String, callbackQueue: DispatchQueue?, callback: @escaping (Bool) -> Void)
    func get(forID id: String, callbackQueue: DispatchQueue?, callback: @escaping (Model?) -> Void)
    func set(model: Model)
}

final class ImageCacher: Caching {
    private let storage: Storage
    private let cache = NSCache<NSString, NSData>()
    private let workQueue = DispatchQueue(label: "IMAGE_CACHER_WORK_QUEUE", qos: .utility)
    private let cacheWorkQueue = DispatchQueue(label: "IMAGE_CACHER_CACHE_WORK_QUEUE", qos: .utility)
    private let storageWorkQueue = DispatchQueue(label: "IMAGE_CACHER_STORAGE_WORK_QUEUE", qos: .utility)

    init(storage: Storage) {
        self.storage = storage
        createImagesDirectoryIfNeeded()
    }

    func contains(forID id: String, callbackQueue: DispatchQueue?, callback: @escaping (Bool) -> Void) {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            let existsInCache = self.executeCacheWork { $0.object(forKey: id as NSString) != nil }
            let existsOnDisk = self.executeStorageWork { $0.fileExists(at: self.diskURL(for: id)) }
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
                if let fromCache = self.executeCacheWork({ $0.object(forKey: id as NSString) }) {
                    return Image(id: id, data: fromCache as Data)
                } else if let fromDisk = self.executeStorageWork({ $0.contents(at: self.diskURL(for: id)) }) {
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
            self.executeCacheWork { $0.setObject(data as NSData, forKey: model.id as NSString) }
            _ = self.executeStorageWork { $0.createFile(at: self.diskURL(for: model.id), contents: data) }
        }
    }

    private func executeCacheWork<T>(_ work: (NSCache<NSString, NSData>) -> T) -> T {
        return cacheWorkQueue.sync { work(self.cache) }
    }

    private func executeStorageWork<T>(_ work: (Storage) -> T) -> T {
        return storageWorkQueue.sync { work(self.storage) }
    }

    private func diskURL(for id: String) -> URL {
        return imagesDirectoryURL.appendingPathComponent(id + ".jpg")
    }

    private var imagesDirectoryURL: URL {
        return storage.documentsDirectory.appendingPathComponent("Images")
    }

    private func createImagesDirectoryIfNeeded() {
        let url = imagesDirectoryURL
        executeStorageWork { storage in
            if storage.fileExists(at: url) { return }
            storage.createDirectory(at: url)
        }
    }
}
