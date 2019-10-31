import Foundation

protocol URLSessionType {
    func task(with request: URLRequest, callbackQueue: DispatchQueue?, callback: @escaping (Data?, URLResponse?, Error?) -> Void) -> Task
}

extension URLSession: URLSessionType {
    func task(with request: URLRequest, callbackQueue: DispatchQueue?, callback: @escaping (Data?, URLResponse?, Error?) -> Void) -> Task {
        return dataTask(with: request) { data, response, error in
            if let queue = callbackQueue {
                queue.async { callback(data, response, error) }
            } else {
                callback(data, response, error)
            }
        }
    }
}

protocol RequesterType {
    func requestData(with request: RequestType, callbackQueue: DispatchQueue?, callback: @escaping (Result<Data, APIError>) -> Void) -> Task
    func requestModel<Model: Decodable>(with request: RequestType, callbackQueue: DispatchQueue?, callback: @escaping (Result<Model, APIError>) -> Void) -> Task
}

extension RequesterType {
    func requestModel<Model: Decodable>(with request: RequestType, callbackQueue: DispatchQueue?, callback: @escaping (Result<Model, APIError>) -> Void) -> Task {
        return requestData(with: request, callbackQueue: callbackQueue) { callback($0.decode()) }
    }

    func requestData(with request: RequestType, callback: @escaping (Result<Data, APIError>) -> Void) -> Task {
        return requestData(with: request, callbackQueue: nil, callback: callback)
    }

    func requestModel<Model: Decodable>(with request: RequestType, callback: @escaping (Result<Model, APIError>) -> Void) -> Task {
        return requestModel(with: request, callbackQueue: nil, callback: callback)
    }
}

struct Requester: RequesterType {
    private let session: URLSessionType

    init(session: URLSessionType = URLSession.shared) {
        self.session = session
    }

    func requestData(with request: RequestType, callbackQueue: DispatchQueue?, callback: @escaping (Result<Data, APIError>) -> Void) -> Task {
        guard let urlRequest = request.toURLRequest else {
            if let queue = callbackQueue {
                queue.async { callback(.failure(.badRequest)) }
            } else {
                callback(.failure(.badRequest))
            }
            return EmptyTask()
        }
        return session.task(with: urlRequest, callbackQueue: callbackQueue) { data, response, error in
            if let data = data {
                guard let httpResponse = response as? HTTPURLResponse else {
                    return callback(.failure(.nonHTTPResponse(urlResponse: response)))
                }
                guard 200..<300 ~= httpResponse.statusCode else {
                    return callback(.failure(.statusCode(code: httpResponse.statusCode)))
                }
                callback(.success(data))
            } else if let error = error {
                callback(.failure(APIError(error: error)))
            } else {
                callback(.failure(.noResponse))
            }
        }
    }
}
