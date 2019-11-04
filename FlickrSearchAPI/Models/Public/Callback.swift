import Foundation

public struct Callback<T> {
    public let queue: DispatchQueue?
    public let callback: (T) -> Void

    public init(queue: DispatchQueue?, callback: @escaping (T) -> Void) {
        self.queue = queue
        self.callback = callback
    }

    public func execute(with input: T) {
        if let queue = queue {
            queue.async { self.callback(input) }
        } else {
            callback(input)
        }
    }

    public func map<U>(_ transform: @escaping (U) -> T) -> Callback<U> {
        return Callback<U>(queue: queue) { self.callback(transform($0)) }
    }

    public func chain<U>(_ callback: @escaping (U, Callback<T>) -> Void) -> Callback<U> {
        return Callback<U>(queue: queue) { callback($0, self) }
    }
}
