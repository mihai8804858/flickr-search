import Foundation

extension URLRequest {
    func addingHeaders(_ headers: [String: String]) -> URLRequest {
        var request = self
        headers.forEach { key, value in request.addValue(value, forHTTPHeaderField: key) }

        return request
    }

    func addingMethod(_ method: HTTPMethod) -> URLRequest {
        var request = self
        request.httpMethod = method.rawValue

        return request
    }
}
