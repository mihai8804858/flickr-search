import XCTest
@testable import FlickrSearchAPI

final class FlickrSearchAPITests: XCTestCase {
    func testSearchSucceeded() {
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
        let requester = MockRequester()
        let api = FlickrSearchAPI(requester: requester, apiKey: "api_key")
        let expectedResult: Result<Photos, APIError> = .success(Photos(page: PhotosPage(
            pageNumber: 1,
            totalPagesCount: 1695,
            perPageCount: 100,
            totalPhotosCount: 169480,
            photos: []
        )))
        let searchParameters = SearchParameters(query: "query", page: 1, pageSize: 100)
        requester.requestDataStubTask = EmptyTask()
        requester.requestDataStub = .success(data)
        _ = api.search(with: searchParameters, callback: .init(queue: nil, callback: { result in
            XCTAssertEqual(result, expectedResult)
        }))
        XCTAssertTrue(requester.requestDataCallParameters.contains(where: { parameters in
            guard let searchRequest = parameters.0 as? SearchRequest else { return false }
            return searchRequest == SearchRequest(apiKey: "api_key", parameters: searchParameters)
        }))
    }

    func testSearchFailed() {
        let requester = MockRequester()
        let api = FlickrSearchAPI(requester: requester, apiKey: "api_key")
        let expectedResult: Result<Data, APIError> = .failure(.statusCode(code: 404))
        let searchParameters = SearchParameters(query: "query", page: 1, pageSize: 100)
        requester.requestDataStubTask = EmptyTask()
        requester.requestDataStub = expectedResult
        _ = api.search(with: searchParameters, callback: .init(queue: nil, callback: { result in
            switch result {
            case .success: XCTFail("Expected to fail")
            case .failure(let error): XCTAssertEqual(error, .statusCode(code: 404))
            }
        }))
        XCTAssertTrue(requester.requestDataCallParameters.contains(where: { parameters in
            guard let searchRequest = parameters.0 as? SearchRequest else { return false }
            return searchRequest == SearchRequest(apiKey: "api_key", parameters: searchParameters)
        }))
    }

    func testRawDataSucceeded() {
        let url = URL(string: "https://google.com")!
        let requester = MockRequester()
        let api = FlickrSearchAPI(requester: requester, apiKey: "api_key")
        let expectedResult: Result<Data, APIError> = .success(Data())
        requester.requestDataStubTask = EmptyTask()
        requester.requestDataStub = expectedResult
        _ = api.data(from: url, callback: .init(queue: nil, callback: { result in
            XCTAssertEqual(result, expectedResult)
        }))
        XCTAssertTrue(requester.requestDataCallParameters.contains(where: { parameters in
            guard let dataRequest = parameters.0 as? DataRequest else { return false }
            return dataRequest == DataRequest(url: url)!
        }))
    }

    func testRawDataFailed() {
        let url = URL(string: "https://google.com")!
        let requester = MockRequester()
        let api = FlickrSearchAPI(requester: requester, apiKey: "api_key")
        let expectedResult: Result<Data, APIError> = .failure(.statusCode(code: 404))
        requester.requestDataStubTask = EmptyTask()
        requester.requestDataStub = expectedResult
        _ = api.data(from: url, callback: .init(queue: nil, callback: { result in
            XCTAssertEqual(result, expectedResult)
        }))
        XCTAssertTrue(requester.requestDataCallParameters.contains(where: { parameters in
            guard let dataRequest = parameters.0 as? DataRequest else { return false }
            return dataRequest == DataRequest(url: url)!
        }))
    }
}

