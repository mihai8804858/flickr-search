@testable import FlickrSearch
import XCTest

final class DebouncerTests: XCTestCase {
    func testDebouncerCallsAction() {
        let debouncer = Debouncer(interval: 0.1)
        let expectation = XCTestExpectation(description: "Expected to be called")
        debouncer.debounce {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testDebouncerCancelsAction() {
        let debouncer = Debouncer(interval: 0.1)
        let expectation = XCTestExpectation(description: "Expected to be called")
        expectation.isInverted = true
        debouncer.debounce {
            expectation.fulfill()
        }
        debouncer.cancel()
        wait(for: [expectation], timeout: 1)
    }

    func testDebouncerCallsLatestAction() {
        let debouncer = Debouncer(interval: 0.1)
        let expectation = XCTestExpectation(description: "Expected to be called")
        expectation.expectedFulfillmentCount = 1
        for _ in 0..<5 {
            debouncer.debounce {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }
}
