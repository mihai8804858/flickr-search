import Foundation

public enum APIError: Error, Equatable, CustomDebugStringConvertible {
    case response(error: ResponseError)
    case decoding(error: DecodingError)
    case statusCode(code: Int)
    case nonHTTPResponse(urlResponse: URLResponse?)
    case badRequest
    case noResponse
    case cancelled
    case other(error: Error)

    init(error: Error) {
        if let apiError = error as? APIError {
            self = apiError
        } else if let responseError = error as? ResponseError {
            self = .response(error: responseError)
        } else if let decodingError = error as? DecodingError {
            self = .decoding(error:decodingError)
        } else if (error as NSError).code == NSURLErrorCancelled {
            self = .cancelled
        } else {
            self = .other(error: error)
        }
    }

    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.response(let lhsError), .response(let rhsError)):
            return lhsError == rhsError
        case (.decoding(let lhsError), .decoding(let rhsError)):
            return lhsError == rhsError
        case (.statusCode(let lhsCode), .statusCode(let rhsCode)):
            return lhsCode == rhsCode
        case (.nonHTTPResponse(let lhsResponse), .nonHTTPResponse(let rhsResponse)):
            return lhsResponse == rhsResponse
        case (.badRequest, .badRequest):
            return true
        case (.noResponse, .noResponse):
            return true
        case (.cancelled, .cancelled):
            return true
        case (.other(let lhsError), .other(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }

    public var debugDescription: String {
        switch self {
        case .response(let error):
            return error.debugDescription
        case .decoding(let error):
            return error.localizedDescription
        case .statusCode(let code):
            return "Status Code (\(code))"
        case .nonHTTPResponse(let response):
            return "Non HTTP Response (\(response?.description ?? "nil"))"
        case .badRequest:
            return "Bad Request"
        case .noResponse:
            return "No Response"
        case .cancelled:
            return "Cancelled"
        case .other(let error):
            return error.localizedDescription
        }
    }
}

extension DecodingError.Context: Equatable {
    public static func == (lhs: DecodingError.Context, rhs: DecodingError.Context) -> Bool {
        return lhs.codingPath.map { $0.stringValue } == rhs.codingPath.map { $0.stringValue }
    }
}

extension DecodingError: Equatable {
    public static func == (lhs: DecodingError, rhs: DecodingError) -> Bool {
        switch (lhs, rhs) {
        case (.typeMismatch(_, let context1), .typeMismatch(_, let context2)):
            return context1 == context2
        case (.valueNotFound(_, let context1), .valueNotFound(_, let context2)):
            return context1 == context2
        case (.keyNotFound(let key1, let context1), .keyNotFound(let key2, let context2)):
            return key1.stringValue == key2.stringValue && context1 == context2
        case (.dataCorrupted(let context1), .dataCorrupted(let context2)):
            return context1 == context2
        default: return false
        }
    }
}
