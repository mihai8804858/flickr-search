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

final class ResultDecodingTests: XCTestCase {
    func testResultCanSuccessfullyDecodeModel() {
        let data =
        """
        {
            "stat": "ok",
            "id": "id",
            "value": 123
        }
        """.data(using: .utf8)!
        let result = Result<Data, APIError>.success(data)
        let modelResult: Result<TestModel, APIError> = result.decode()
        XCTAssertEqual(modelResult, .success(TestModel(id: "id", value: 123)))
    }

    func testResultReturnsErrorIfDecodingFails() {
        let data =
        """
        {
            "stat": "ok",
            "id": "id"
        }
        """.data(using: .utf8)!
        let result = Result<Data, APIError>.success(data)
        let modelResult: Result<TestModel, APIError> = result.decode()
        let expectedError = DecodingError.keyNotFound(
            TestModel.CodingKeys.value,
            DecodingError.Context(
                codingPath: [],
                debugDescription: "No value associated with key \(TestModel.CodingKeys.value)."
            )
        )
        XCTAssertEqual(modelResult, .failure(.decoding(error: expectedError)))
    }

    func testResultReturnsErrorIfStatusIsFail() {
        let data =
        """
        {
            "stat": "fail",
            "code": 123,
            "message": "message"
        }
        """.data(using: .utf8)!
        let result = Result<Data, APIError>.success(data)
        let modelResult: Result<TestModel, APIError> = result.decode()
        XCTAssertEqual(modelResult, .failure(.response(error: ResponseError(code: 123, message: "message"))))
    }

    func testResultReturnsErrorIfItsFailed() {
        let result = Result<Data, APIError>.failure(.statusCode(code: 404))
        let modelResult: Result<TestModel, APIError> = result.decode()
        XCTAssertEqual(modelResult, .failure(.statusCode(code: 404)))
    }
}
