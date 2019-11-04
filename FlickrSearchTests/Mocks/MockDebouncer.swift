@testable import FlickrSearch

final class MockDebouncer: Debouncing {
    let debounceFuncCheck = FuncCheck<() -> Void>()
    func debounce(_ action: @escaping () -> Void) {
        debounceFuncCheck.call(action)
        action()
    }

    let cancelFuncCheck = ZeroArgumentsFuncCheck()
    func cancel() {
        cancelFuncCheck.call()
    }
}
