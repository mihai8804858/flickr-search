import XCTest
@testable import FlickrSearchAPI

final class URLRequestTests: XCTestCase {
    func testURLRequestCanAddHeaders() {
        let urlRequest = URLRequest(url: URL(string: "https://google.com")!)
        let headers = ["key1": "value1", "key2": "value2"]
        XCTAssertEqual(urlRequest.addingHeaders(headers).allHTTPHeaderFields, headers)
    }

    func testURLRequestCanAddMethod() {
        let urlRequest = URLRequest(url: URL(string: "https://google.com")!)
        let method = HTTPMethod.get
        XCTAssertEqual(urlRequest.addingMethod(method).httpMethod, method.rawValue)
    }
}
