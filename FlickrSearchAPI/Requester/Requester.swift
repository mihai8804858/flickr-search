import Foundation

protocol URLSessionType {
    func task(with request: URLRequest, callback: Callback<(Data?, URLResponse?, Error?)>) -> Task
}

extension URLSession: URLSessionType {
    func task(with request: URLRequest, callback: Callback<(Data?, URLResponse?, Error?)>) -> Task {
        return dataTask(with: request) { data, response, error in
            callback.execute(with: (data, response, error))
        }
    }
}

protocol RequesterType {
    func requestData(with request: RequestType, callback: Callback<Result<Data, APIError>>) -> Task
    func requestModel<Model: Decodable>(with request: RequestType, callback: Callback<Result<Model, APIError>>) -> Task
}

extension RequesterType {
    func requestModel<Model: Decodable>(with request: RequestType, callback: Callback<Result<Model, APIError>>) -> Task {
        return requestData(with: request, callback: callback.map { $0.decode() })
    }
}

struct Requester: RequesterType {
    private let session: URLSessionType

    init(session: URLSessionType = URLSession.shared) {
        self.session = session
    }

    func requestData(with request: RequestType, callback: Callback<Result<Data, APIError>>) -> Task {
        guard let urlRequest = request.toURLRequest else {
            callback.execute(with: .failure(.badRequest))
            return EmptyTask()
        }
        return session.task(with: urlRequest, callback: callback.map { data, response, error in
            if let data = data {
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .failure(.nonHTTPResponse(urlResponse: response))
                }
                guard 200..<300 ~= httpResponse.statusCode else {
                    return .failure(.statusCode(code: httpResponse.statusCode))
                }
                return .success(data)
            } else if let error = error {
                return .failure(APIError(error: error))
            } else {
                return .failure(.noResponse)
            }
        })
    }
}
