import Foundation

protocol Storage {
    var documentsDirectory: URL { get }
    func fileExists(at url: URL) -> Bool
    func contents(at url: URL) -> Data?
    @discardableResult
    func createFile(at url: URL, contents data: Data?) -> Bool
    @discardableResult
    func createDirectory(at url: URL) -> Bool
    @discardableResult
    func removeFile(at url: URL) -> Bool
}

extension FileManager: Storage {
    var documentsDirectory: URL {
        return urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    func fileExists(at url: URL) -> Bool {
        return fileExists(atPath: url.path)
    }

    func contents(at url: URL) -> Data? {
        contents(atPath: url.path)
    }

    @discardableResult
    func createFile(at url: URL, contents data: Data?) -> Bool {
        return createFile(atPath: url.path, contents: data, attributes: nil)
    }

    @discardableResult
    func createDirectory(at url: URL) -> Bool {
        do {
            try createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }

    @discardableResult
    func removeFile(at url: URL) -> Bool {
        do {
            try removeItem(atPath: url.path)
            return true
        } catch {
            return false
        }
    }
}
