import XCTest
@testable import FlickrSearchAPI

private struct TestRequest: RequestType {
    let host: String
    let pathComponents: [String]
    let method: HTTPMethod
    let queries: [String: String]
    let headers: [String: String]
}

final class RequestTypeTests: XCTestCase {
    func testRequestTypeCanSuccessfullyBuildURLRequest() {
        let request = TestRequest(
            host: "https://google.com",
            pathComponents: ["path1", "path2"],
            method: .post,
            queries: ["query_key_1": "query_value_1", "query_key_2": "query_value_2"],
            headers: ["header_key_1": "header_value_1", "header_key_2": "header_value_2"]
        )
        let expectedURLRequest: URLRequest = {
            var components = URLComponents(
                url: URL(string: "https://google.com/path1/path2")!,
                resolvingAgainstBaseURL: false
            )!
            components.queryItems = request.queries.map { URLQueryItem(name: $0.key, value: $0.value) }
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            request.headers.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
            return urlRequest
        }()
        XCTAssertEqual(request.toURLRequest, expectedURLRequest)
    }
}

