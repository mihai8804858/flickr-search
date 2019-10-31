import XCTest
@testable import FlickrSearchAPI

private struct TestModel: Equatable, Decodable {
    let id: String
    let value: Int

    enum CodingKeys: String, CodingKey {
        case id
        case value
    }
}

final class ResponseTests: XCTestCase {
    func testResponseDecodingWhenStatusIsOkDoesntThrowsErrorAndDecodesModel() {
        let data =
        """
        {
            "stat": "ok",
            "id": "id",
            "value": 123
        }
        """.data(using: .utf8)!
        let decode = {
            try JSONDecoder().decode(Response<TestModel>.self, from: data)
        }
        let expectedResult = Result<TestModel, ResponseError>.success(TestModel(id: "id", value: 123))
        XCTAssertNoThrow(decode)
        XCTAssertEqual(try decode(), Response<TestModel>(status: .ok, result: expectedResult))
    }

    func testResponseDecodingWhenStatusIsFailDoesntThrowsErrorAndDecodesResponseError() {
        let data =
        """
        {
            "stat": "fail",
            "code": 123,
            "message": "message"
        }
        """.data(using: .utf8)!
        let decode = {
            try JSONDecoder().decode(Response<TestModel>.self, from: data)
        }
        let expectedResult = Result<TestModel, ResponseError>.failure(ResponseError(code: 123, message: "message"))
        XCTAssertNoThrow(decode)
        XCTAssertEqual(try decode(), Response<TestModel>(status: .fail, result: expectedResult))
    }
}
