@testable import FlickrSearch
import XCTest
import FlickrSearchAPI

final class ImageLoaderTests: XCTestCase {
    func testImageLoaderWhenImageExistsInCacheShouldReturnCachedImage() {
        let api = MockFlickrSearchAPI()
        let cache = MockImageCaching()
        let url = URL(string: "https://image.url")!
        let image = IdentifiableImage(url: url, image: mockedImage(size: .init(width: 50, height: 50)))
        cache.containsStub = true
        cache.getStub = image
        let loader = ImageLoader(api: api, cache: cache)
        let expectation = XCTestExpectation(description: "Expect to return image")
        let callback = Callback<Result<IdentifiableImage, ImageLoadingError>>(queue: nil) { result in
            switch result {
            case .success(let resultImage) where resultImage == image:
                expectation.fulfill()
            default:
                return
            }
        }
        loader.getImage(from: url, callback: callback)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(cache.containsFuncCheck.wasCalled(with: { $0.0 == image.id }))
        XCTAssertTrue(cache.getFuncCheck.wasCalled(with: { $0.0 == image.id }))
        XCTAssertFalse(api.dataFuncCheck.wasCalled)
    }

    func testImageLoaderWhenImageDoesntExistInCacheShouldRequestImageAndCacheIt() {
        let api = MockFlickrSearchAPI()
        let cache = MockImageCaching()
        let url = URL(string: "https://image.url")!
        let image = mockedImage(size: .init(width: 50, height: 50))
        let imageData = image.pngData()!
        let identifiableImage = IdentifiableImage(url: url, image: image)
        cache.containsStub = false
        cache.getStub = nil
        api.dataStub = .success(imageData)
        let loader = ImageLoader(api: api, cache: cache)
        let expectation = XCTestExpectation(description: "Expect to return image")
        let callback = Callback<Result<IdentifiableImage, ImageLoadingError>>(queue: nil) { result in
            switch result {
            case .success(let resultImage) where resultImage == identifiableImage:
                expectation.fulfill()
            default:
                return
            }
        }
        loader.getImage(from: url, callback: callback)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(cache.containsFuncCheck.wasCalled(with: { $0.0 == identifiableImage.id }))
        XCTAssertFalse(cache.getFuncCheck.wasCalled(with: { $0.0 == identifiableImage.id }))
        XCTAssertTrue(cache.setFuncCheck.wasCalled(with: identifiableImage))
        XCTAssertTrue(api.dataFuncCheck.wasCalled(with: { $0.0 == url }))
    }

    func testImageLoaderWhenImageDoesntExistInCacheAndRequestFailedShouldNotCacheImageAndReturnError() {
        let api = MockFlickrSearchAPI()
        let cache = MockImageCaching()
        let url = URL(string: "https://image.url")!
        let id = IdentifiableImage.imageID(for: url)
        cache.containsStub = false
        cache.getStub = nil
        let apiError = APIError.badRequest
        api.dataStub = .failure(apiError)
        let loader = ImageLoader(api: api, cache: cache)
        let expectation = XCTestExpectation(description: "Expect to fail")
        let callback = Callback<Result<IdentifiableImage, ImageLoadingError>>(queue: nil) { result in
            switch result {
            case .failure(let error) where error == .api(apiError):
                expectation.fulfill()
            default:
                return
            }
        }
        loader.getImage(from: url, callback: callback)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(cache.containsFuncCheck.wasCalled(with: { $0.0 == id }))
        XCTAssertFalse(cache.getFuncCheck.wasCalled(with: { $0.0 == id }))
        XCTAssertFalse(cache.setFuncCheck.wasCalled)
        XCTAssertTrue(api.dataFuncCheck.wasCalled(with: { $0.0 == url }))
    }

    func testImageLoaderWhenImageDoesntExistInCacheAndRequestSucceededWithBadDataShouldNotCacheImageAndReturnError() {
        let api = MockFlickrSearchAPI()
        let cache = MockImageCaching()
        let url = URL(string: "https://image.url")!
        let id = IdentifiableImage.imageID(for: url)
        cache.containsStub = false
        cache.getStub = nil
        let data = Data()
        api.dataStub = .success(data)
        let loader = ImageLoader(api: api, cache: cache)
        let expectation = XCTestExpectation(description: "Expect to fail")
        let callback = Callback<Result<IdentifiableImage, ImageLoadingError>>(queue: nil) { result in
            switch result {
            case .failure(let error) where error == .badData(data):
                expectation.fulfill()
            default:
                return
            }
        }
        loader.getImage(from: url, callback: callback)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(cache.containsFuncCheck.wasCalled(with: { $0.0 == id }))
        XCTAssertFalse(cache.getFuncCheck.wasCalled(with: { $0.0 == id }))
        XCTAssertFalse(cache.setFuncCheck.wasCalled)
        XCTAssertTrue(api.dataFuncCheck.wasCalled(with: { $0.0 == url }))
    }
}
