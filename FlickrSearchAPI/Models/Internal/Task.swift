import Foundation

public protocol Task: Identifiable {
    func resume()
    func cancel()
}

extension URLSessionTask: Task {
    public var id: String {
        return String(taskIdentifier)
    }
}

struct EmptyTask: Task {
    let id: String

    init(id: String = UUID().uuidString) {
        self.id = id
    }

    func resume() {}
    func cancel() {}
}
