import Foundation

extension Result where Success == Data, Failure == APIError {
    func decode<Model: Decodable>() -> Result<Model, APIError> {
        return flatMap { data in
            Result<Response<Model>, Error> {
                try JSONDecoder().decode(Response<Model>.self, from: data)
            }.mapError(APIError.init)
        }.flatMap { response -> Result<Model, APIError> in
            switch response.result {
            case .success(let model):
                return .success(model)
            case .failure(let error):
                return .failure(.response(error: error))
            }
        }
    }
}
