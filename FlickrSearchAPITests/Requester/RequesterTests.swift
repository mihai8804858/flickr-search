import XCTest
@testable import FlickrSearchAPI

private struct TestRequest: RequestType {
    let host: String
    let pathComponents: [String]
    let method: HTTPMethod
    let queries: [String: String]
    let headers: [String: String]
}

final class RequesterTests: XCTestCase {
    func testBadRequest() {
        let request = TestRequest(
            host: "",
            pathComponents: [],
            method: .get,
            queries: [:],
            headers: [:]
        )
        let session = MockURLSession()
        let requester = Requester(session: session)
        _ = requester.requestData(with: request) { result in
            XCTAssertEqual(result, .failure(.badRequest))
        }
    }

    func testReturnsError() {
        let request = TestRequest(
            host: "https://google.com",
            pathComponents: [],
            method: .get,
            queries: [:],
            headers: [:]
        )
        let error = NSError(domain: "Domain", code: 123, userInfo: nil)

        let session = MockURLSession()
        session.sessionDataTaskStub = EmptyTask()
        session.dataTaskStub = (nil, nil, error)
        let requester = Requester(session: session)
        _ = requester.requestData(with: request) { result in
            XCTAssertEqual(result, .failure(.other(error: error)))
        }
    }

    func testReturnsNoResponse() {
        let request = TestRequest(
            host: "https://google.com",
            pathComponents: [],
            method: .get,
            queries: [:],
            headers: [:]
        )

        let session = MockURLSession()
        session.sessionDataTaskStub = EmptyTask()
        session.dataTaskStub = (nil, nil, nil)
        let requester = Requester(session: session)
        _ = requester.requestData(with: request) { result in
            XCTAssertEqual(result, .failure(.noResponse))
        }
    }

    func testNonHTTPResponse() {
        let request = TestRequest(
            host: "https://google.com",
            pathComponents: [],
            method: .get,
            queries: [:],
            headers: [:]
        )
        let response = URLResponse(
            url: request.toURLRequest!.url!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )

        let session = MockURLSession()
        session.sessionDataTaskStub = EmptyTask()
        session.dataTaskStub = (Data(), response, nil)
        let requester = Requester(session: session)
        _ = requester.requestData(with: request) { result in
            XCTAssertEqual(result, .failure(.nonHTTPResponse(urlResponse: response)))
        }
    }

    func testBadStatusCode() {
        let request = TestRequest(
            host: "https://google.com",
            pathComponents: [],
            method: .get,
            queries: [:],
            headers: [:]
        )
        let response = HTTPURLResponse(
            url: request.toURLRequest!.url!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )

        let session = MockURLSession()
        session.sessionDataTaskStub = EmptyTask()
        session.dataTaskStub = (Data(), response, nil)
        let requester = Requester(session: session)
        _ = requester.requestData(with: request) { result in
            XCTAssertEqual(result, .failure(.statusCode(code: 404)))
        }
    }

    func testRequestModel() {
        let request = TestRequest(
            host: "https://google.com",
            pathComponents: [],
            method: .get,
            queries: [:],
            headers: [:]
        )
        let data =
        """
        {
          "photos": {
            "page": 1,
            "pages": 1695,
            "perpage": 100,
            "total": "169480",
            "photo": []
          },
          "stat": "ok"
        }
        """.data(using: .utf8)!
        let model = Photos(page: PhotosPage(
            pageNumber: 1,
            totalPagesCount: 1695,
            perPageCount: 100,
            totalPhotosCount: 169480,
            photos: []
        ))
        let response = HTTPURLResponse(
            url: request.toURLRequest!.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let session = MockURLSession()
        session.sessionDataTaskStub = EmptyTask()
        session.dataTaskStub = (data, response, nil)
        let requester = Requester(session: session)
        _ = requester.requestModel(with: request) { result in
            XCTAssertEqual(result, .success(model))
        }
    }
}


