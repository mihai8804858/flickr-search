public struct SearchParameters: Equatable {
    public let query: String
    public let page: UInt
    public let pageSize: UInt

    public init(query: String, page: UInt, pageSize: UInt) {
        self.query = query
        self.page = page
        self.pageSize = pageSize
    }
}

struct SearchRequest: RequestType, Equatable {
    let host = "https://api.flickr.com"
    let pathComponents = ["services", "rest"]
    let method = HTTPMethod.get
    let queries: [String: String]

    init(apiKey: String, parameters: SearchParameters) {
        queries = [
            "method": "flickr.photos.search",
            "api_key": apiKey,
            "format": "json",
            "nojsoncallback": "1",
            "safe_search": "1",
            "page": String(parameters.page),
            "per_page": String(parameters.pageSize),
            "text": parameters.query
        ]
    }
}
