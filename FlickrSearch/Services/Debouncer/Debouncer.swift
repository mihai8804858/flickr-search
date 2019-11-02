import Foundation

protocol Debouncing {
    func debounce(_ action: @escaping () -> Void)
    func cancel()
}

final class Debouncer: Debouncing {
    private let interval: TimeInterval
    private let queue: DispatchQueue?
    private var timer: Timer?

    init(interval: TimeInterval, queue: DispatchQueue? = nil) {
        self.interval = interval
        self.queue = queue
    }

    deinit {
        cancel()
    }

    func debounce(_ action: @escaping () -> Void) {
        cancel()
        execute { [weak self] in
            guard let self = self else { return }
            self.timer = .scheduledTimer(withTimeInterval: self.interval, repeats: false) { _ in action() }
        }
    }

    func cancel() {
        execute { [weak self] in
            guard let self = self else { return }
            self.timer?.invalidate()
            self.timer = nil
        }
    }
}

private extension Debouncer {
    func execute(_ action: @escaping () -> Void) {
        if let queue = queue {
            queue.async(execute: action)
        } else {
            action()
        }
    }
}
