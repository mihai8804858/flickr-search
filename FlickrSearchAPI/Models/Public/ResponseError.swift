public struct ResponseError: Equatable, Decodable, Error, CustomDebugStringConvertible {
    public let code: Int
    public let message: String

    public var debugDescription: String {
        return "Code - \(code), Message - \(message)"
    }
}
