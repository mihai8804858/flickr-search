import XCTest
@testable import FlickrSearchAPI

final class DataRequestTests: XCTestCase {
    func testDataRequestCanSuccessfullyBuildURLRequestFromString() {
        let url = "https://api.flickr.com/services/rest?key1=value1"
        let request = DataRequest(url: url)?.toURLRequest
        XCTAssertEqual(request, URLRequest(url: URL(string: url)!))
    }

    func testDataRequestCanSuccessfullyBuildURLRequestFromURL() {
        let url = URL(string: "https://api.flickr.com/services/rest?key1=value1")!
        let request = DataRequest(url: url)?.toURLRequest
        XCTAssertEqual(request, URLRequest(url: url))
    }
}

