struct DataRequest: RequestType, Equatable {
    let host: String
    let pathComponents: [String] = []
    let method = HTTPMethod.get
    let queries: [String: String]

    init?(url: String) {
        guard var components = URLComponents(string: url) else { return nil }
        let queries = components.queryItems ?? []
        components.queryItems = nil
        guard let absoluteString = components.url?.absoluteString else { return nil }
        self.host = absoluteString
        self.queries = Dictionary(uniqueKeysWithValues: queries.map { ($0.name, $0.value ?? "") })
    }

    init?(url: URL) {
        self.init(url: url.absoluteString)
    }
}
