import XCTest
@testable import FlickrSearchAPI

final class StatusTests: XCTestCase {
    func testStatusDecodingWhenIsOkDoesntThrowsError() {
        let data = "{ \"stat\": \"ok\" }".data(using: .utf8)!
        let decode = {
            try JSONDecoder().decode([String: Status].self, from: data)
        }
        XCTAssertNoThrow(decode)
        XCTAssertEqual(try decode()["stat"], .ok)
    }

    func testStatusDecodingWhenIsFailDoesntThrowsError() {
        let data = "{ \"stat\": \"fail\" }".data(using: .utf8)!
        let decode = {
            try JSONDecoder().decode([String: Status].self, from: data)
        }
        XCTAssertNoThrow(decode)
        XCTAssertEqual(try decode()["stat"], .fail)
    }

    func testStatusDecodingWhenHasWrongValueThrowsError() {
        let data = "{ \"stat\": \"wrong_status\" }".data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode([String: Status].self, from: data))
    }
}
