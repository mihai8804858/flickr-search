import Foundation

protocol RequestType {
    var host: String { get }
    var pathComponents: [String] { get }
    var method: HTTPMethod { get }
    var queries: [String: String] { get }
    var headers: [String: String] { get }
}

extension RequestType {
    var headers: [String: String] {
        return [:]
    }
}

extension RequestType {
    var toURLRequest: URLRequest? {
        return URL(string: host)?
            .addingPathComponents(pathComponents)
            .addingQueries(queries)?
            .toURLRequest
            .addingMethod(method)
            .addingHeaders(headers)
    }
}
