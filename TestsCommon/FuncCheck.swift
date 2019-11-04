import Foundation
import XCTest

class FuncCheck<Args> {
    private var callArguments: [Args] = []
    private var wasCalledExpectations: [XCTestExpectation] = []
    private var wasCalledWithArgsExpectations: [(XCTestExpectation, (Args) -> Bool)] = []

    var wasCalled: Bool {
        return !callArguments.isEmpty
    }

    func wasCalled(with predicate: (Args) -> Bool) -> Bool {
        return callArguments.contains(where: predicate)
    }

    func call(_ args: Args) {
        callArguments.append(args)
        wasCalledExpectations.forEach { $0.fulfill() }
        wasCalledWithArgsExpectations.filter { $0.1(args) }.forEach { $0.0.fulfill() }
    }

    func wasCalledExpectation() -> XCTestExpectation {
        let expectation = XCTestExpectation(description: "Expected to be called")
        wasCalledExpectations.append(expectation)
        if wasCalled { expectation.fulfill() }

        return expectation
    }

    func wasCalledExpectation(with predicate: @escaping (Args) -> Bool) -> XCTestExpectation {
        let expectation = XCTestExpectation(description: "Expected to be called with args")
        wasCalledWithArgsExpectations.append((expectation, predicate))
        if wasCalled(with: predicate) { expectation.fulfill() }

        return expectation
    }
}

extension FuncCheck where Args: Equatable {
    func wasCalled(with args: Args) -> Bool {
        return callArguments.contains(args)
    }
}

class ZeroArgumentsFuncCheck: FuncCheck<Void> {
    func call() {
        call(())
    }
}
