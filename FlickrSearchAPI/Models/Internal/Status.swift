enum Status: String, Equatable, CaseIterable, Decodable {
    case ok
    case fail

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let status = Status(rawValue: rawValue) else {
            let expectedCases = String(describing: Status.allCases)
            let description = "Expecting to decode one of \(expectedCases), got \"\(rawValue)\"."
            throw DecodingError.dataCorruptedError(in: container, debugDescription: description)
        }

        self = status
    }
}
