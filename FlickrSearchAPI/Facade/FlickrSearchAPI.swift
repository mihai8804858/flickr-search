public protocol FlickrSearchAPIType {
    func search(with parameters: SearchParameters, callback: Callback<Result<Photos, APIError>>) -> Task
    func data(from url: URL, callback: Callback<Result<Data, APIError>>) -> Task
}

public struct FlickrSearchAPI: FlickrSearchAPIType {
    private let requester: RequesterType
    private let apiKey: String

    init(requester: RequesterType, apiKey: String) {
        self.requester = requester
        self.apiKey = apiKey
    }

    public init(apiKey: String) {
        self.init(requester: Requester(), apiKey: apiKey)
    }

    public func search(with parameters: SearchParameters, callback: Callback<Result<Photos, APIError>>) -> Task {
        let request = SearchRequest(apiKey: apiKey, parameters: parameters)
        return requester.requestModel(with: request, callback: callback)
    }

    public func data(from url: URL, callback: Callback<Result<Data, APIError>>) -> Task {
        guard let request = DataRequest(url: url) else {
            callback.execute(with: .failure(.badRequest))
            return EmptyTask()
        }
        return requester.requestData(with: request, callback: callback)
    }
}
