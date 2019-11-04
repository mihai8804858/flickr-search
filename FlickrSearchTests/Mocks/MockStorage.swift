@testable import FlickrSearch
import Foundation

final class MockStorage: Storage {
    var documentsDirectory = URL(string: "file://documents/directory")!

    let fileExistsFuncCheck = FuncCheck<URL>()
    var fileExistsStub = false
    func fileExists(at url: URL) -> Bool {
        fileExistsFuncCheck.call(url)
        return fileExistsStub
    }

    let contentsFuncCheck = FuncCheck<URL>()
    var contentsStub: Data? = nil
    func contents(at url: URL) -> Data? {
        contentsFuncCheck.call(url)
        return contentsStub
    }

    let createFileFuncCheck = FuncCheck<(URL, Data?)>()
    var createFileStub = false
    @discardableResult
    func createFile(at url: URL, contents data: Data?) -> Bool {
        createFileFuncCheck.call((url, data))
        return createFileStub
    }

    let createDirectoryFuncCheck = FuncCheck<URL>()
    var createDirectoryStub = false
    @discardableResult
    func createDirectory(at url: URL) -> Bool {
        createDirectoryFuncCheck.call(url)
        return createDirectoryStub
    }

    let removeFileFuncCheck = FuncCheck<URL>()
    var removeFileStub = false
    @discardableResult
    func removeFile(at url: URL) -> Bool {
        removeFileFuncCheck.call(url)
        return removeFileStub
    }
}
