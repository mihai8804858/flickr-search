import XCTest
@testable import FlickrSearchAPI

final class SearchRequestTests: XCTestCase {
    func testSearchRequestCanSuccessfullyBuildURLRequest() {
        let parameters = SearchParameters(query: "query", page: 1, pageSize: 100)
        let request = SearchRequest(apiKey: "api_key", parameters: parameters).toURLRequest!
        let queries = [
            "method": "flickr.photos.search",
            "api_key": "api_key",
            "format": "json",
            "nojsoncallback": "1",
            "safe_search": "1",
            "page": "1",
            "per_page": "100",
            "text": "query"
        ].map { URLQueryItem(name: $0.key, value: $0.value) }
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
        var componentsWithoutQueries = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
        componentsWithoutQueries?.queryItems = nil
        XCTAssertEqual(componentsWithoutQueries?.url?.absoluteString, "https://api.flickr.com/services/rest")
        XCTAssertEqual(Set(components?.queryItems ?? []), Set(queries))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
    }
}

