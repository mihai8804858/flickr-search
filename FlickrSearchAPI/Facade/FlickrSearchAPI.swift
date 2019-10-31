public protocol FlickrSearchAPIType {
    func search(with parameters: SearchParameters, callbackQueue: DispatchQueue?, callback: @escaping (Result<Photos, APIError>) -> Void) -> Task
    func data(from url: URL, callbackQueue: DispatchQueue?, callback: @escaping (Result<Data, APIError>) -> Void) -> Task
}

extension FlickrSearchAPIType {
    func search(with parameters: SearchParameters, callback: @escaping (Result<Photos, APIError>) -> Void) -> Task {
        search(with: parameters, callbackQueue: nil, callback: callback)
    }

    func data(from url: URL, callback: @escaping (Result<Data, APIError>) -> Void) -> Task {
        data(from: url, callbackQueue: nil, callback: callback)
    }
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

    public func search(with parameters: SearchParameters, callbackQueue: DispatchQueue?, callback: @escaping (Result<Photos, APIError>) -> Void) -> Task {
        let request = SearchRequest(apiKey: apiKey, parameters: parameters)
        return requester.requestModel(with: request, callbackQueue: callbackQueue, callback: callback)
    }

    public func data(from url: URL, callbackQueue: DispatchQueue?, callback: @escaping (Result<Data, APIError>) -> Void) -> Task {
        guard let request = DataRequest(url: url) else {
            if let queue = callbackQueue {
                queue.async { callback(.failure(.badRequest)) }
            } else {
                callback(.failure(.badRequest))
            }
            return EmptyTask()
        }
        return requester.requestData(with: request, callbackQueue: callbackQueue, callback: callback)
    }
}
