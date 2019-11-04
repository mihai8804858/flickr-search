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
