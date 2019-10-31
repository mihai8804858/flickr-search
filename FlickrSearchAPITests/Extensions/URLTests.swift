import XCTest
@testable import FlickrSearchAPI

final class URLTests: XCTestCase {
    func testURLCanConvertToURLRequest() {
        let url = URL(string: "https://google.com")!
        XCTAssertEqual(url.toURLRequest, URLRequest(url: url))
    }

    func testURLCanAddPathComponents() {
        let url = URL(string: "https://google.com")!
        let components = ["path1", "path2"]
        XCTAssertEqual(url.addingPathComponents(components), URL(string: "https://google.com/path1/path2")!)
    }

    func testURLCanAddQueries() {
        let url = URL(string: "https://google.com")!
        let queries = ["key1": "value1", "key2": "value2"]
        let expectedQueries = queries.map { URLQueryItem(name: $0.key, value: $0.value) }
        let components = URLComponents(url: url.addingQueries(queries)!, resolvingAgainstBaseURL: false)
        XCTAssertEqual(Set(components?.queryItems ?? []), Set(expectedQueries))
    }
}
