import Foundation

final class Debouncer: Debouncing {
    private let interval: TimeInterval
    private var timer: Timer?

    init(interval: TimeInterval) {
        self.interval = interval
    }

    deinit {
        cancel()
    }

    func debounce(_ action: @escaping () -> Void) {
        cancel()
        timer = .scheduledTimer(withTimeInterval: interval, repeats: false) { _ in action() }
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
    }
}
