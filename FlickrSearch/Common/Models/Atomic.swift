import Foundation

final class Atomic<T> {
    private let lock = NSLock()
    private var _value: T

    var value: T {
        get {
            lock.lock()
            let result = _value
            lock.unlock()
            return result
        }
        set {
            lock.lock()
            _value = newValue
            lock.unlock()
        }
    }

    init(_ value: T) {
        self._value = value
    }

    func mutate(_ mutator: (inout T) -> Void) {
        lock.lock()
        var mutableValue = _value
        mutator(&mutableValue)
        _value = mutableValue
        lock.unlock()
    }

    @discardableResult
    func execute<R>(_ action: (T) -> R) -> R {
        lock.lock()
        let result = action(_value)
        lock.unlock()
        return result
    }
}
