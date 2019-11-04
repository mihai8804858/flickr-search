import Foundation
import XCTest

class FuncCheck<Args> {
    private var callArguments: [Args] = []

    var wasCalled: Bool {
        return !callArguments.isEmpty
    }

    func wasCalled(with predicate: (Args) -> Bool) -> Bool {
        return callArguments.contains(where: predicate)
    }

    func call(_ args: Args) {
        callArguments.append(args)
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
