@testable import FlickrSearch
import XCTest
import FlickrSearchAPI

final class ImageCacherTests: XCTestCase {
    func testCacherWhenIsInitializedWhenImagesDirectoryDoesntExistShouldCreateTheDirectory() {
        let storage = MockStorage()
        let imagesDirectoryURL = storage.documentsDirectory.appendingPathComponent("Images")
        storage.fileExistsStub = false
        _ = ImageCacher(storage: storage)
        XCTAssertTrue(storage.fileExistsFuncCheck.wasCalled(with: imagesDirectoryURL))
        XCTAssertTrue(storage.createDirectoryFuncCheck.wasCalled(with: imagesDirectoryURL))
    }

    func testCacherWhenIsInitializedWhenImagesDirectoryExistsShouldntCreateTheDirectory() {
        let storage = MockStorage()
        let imagesDirectoryURL = storage.documentsDirectory.appendingPathComponent("Images")
        storage.fileExistsStub = true
        _ = ImageCacher(storage: storage)
        XCTAssertTrue(storage.fileExistsFuncCheck.wasCalled(with: imagesDirectoryURL))
        XCTAssertFalse(storage.createDirectoryFuncCheck.wasCalled(with: imagesDirectoryURL))
    }

    func testCacherWhenCheckingIfImageIsPresentWhenIsPresentShouldReturnTrue() {
        let storage = MockStorage()
        let id = "id"
        let imagesDirectoryURL = storage.documentsDirectory.appendingPathComponent("Images")
        let imageURL = imagesDirectoryURL.appendingPathComponent(id + ".jpg")
        storage.fileExistsStub = true
        let expectation = XCTestExpectation(description: "Expect to return tue")
        let callback = Callback<Bool>(queue: nil) { exists in
            if exists {
                expectation.fulfill()
            }
        }
        let cacher = ImageCacher(storage: storage)
        cacher.contains(forID: id, callback: callback)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(storage.fileExistsFuncCheck.wasCalled(with: imageURL))
    }

    func testCacherWhenCheckingIfImageIsPresentWhenIsNotPresentShouldReturnFalse() {
        let storage = MockStorage()
        let id = "id"
        let imagesDirectoryURL = storage.documentsDirectory.appendingPathComponent("Images")
        let imageURL = imagesDirectoryURL.appendingPathComponent(id + ".jpg")
        storage.fileExistsStub = false
        let expectation = XCTestExpectation(description: "Expect to return tue")
        let callback = Callback<Bool>(queue: nil) { exists in
            if !exists {
                expectation.fulfill()
            }
        }
        let cacher = ImageCacher(storage: storage)
        cacher.contains(forID: id, callback: callback)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(storage.fileExistsFuncCheck.wasCalled(with: imageURL))
    }

    func testCacherWhenSettingModelShouldCreateFile() {
        let storage = MockStorage()
        let id = "id"
        let imagesDirectoryURL = storage.documentsDirectory.appendingPathComponent("Images")
        let imageURL = imagesDirectoryURL.appendingPathComponent(id + ".jpg")
        let cacher = ImageCacher(storage: storage)
        cacher.set(model: IdentifiableImage(id: id, data: mockedImage(size: .init(width: 40, height: 40)).pngData()!)!)
        let expectation = storage.createFileFuncCheck.wasCalledExpectation(with: { $0.0 == imageURL })
        wait(for: [expectation], timeout: 1)
    }

    func testCacherWhenGettingModelWhenItExistsInStorageShouldReturnIt() {
        let storage = MockStorage()
        let id = "id"
        let imagesDirectoryURL = storage.documentsDirectory.appendingPathComponent("Images")
        let imageURL = imagesDirectoryURL.appendingPathComponent(id + ".jpg")
        let data = mockedImage(size: .init(width: 50, height: 50)).pngData()!
        storage.contentsStub = data
        let cacher = ImageCacher(storage: storage)
        let expectation = XCTestExpectation(description: "Expect to return model")
        let callback = Callback<IdentifiableImage?>(queue: nil) { image in
            if image == IdentifiableImage.init(id: id, data: data) {
                expectation.fulfill()
            }
        }
        cacher.get(forID: id, callback: callback)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(storage.contentsFuncCheck.wasCalled(with: imageURL))
    }

    func testCacherWhenGettingModelWhenItDoesntExistInStorageShouldReturnNil() {
        let storage = MockStorage()
        let id = "id"
        let imagesDirectoryURL = storage.documentsDirectory.appendingPathComponent("Images")
        let imageURL = imagesDirectoryURL.appendingPathComponent(id + ".jpg")
        storage.contentsStub = nil
        let cacher = ImageCacher(storage: storage)
        let expectation = XCTestExpectation(description: "Expect to return model")
        let callback = Callback<IdentifiableImage?>(queue: nil) { image in
            if image == nil {
                expectation.fulfill()
            }
        }
        cacher.get(forID: id, callback: callback)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(storage.contentsFuncCheck.wasCalled(with: imageURL))
    }
}
