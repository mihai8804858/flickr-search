public struct ResponseError: Equatable, Decodable, Error {
    public let code: Int
    public let message: String
}
