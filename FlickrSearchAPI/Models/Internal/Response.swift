struct Response<Model: Decodable>: Decodable {
    let result: Result<Model, ResponseError>
    let status: Status

    enum CodingKeys: String, CodingKey {
        case status = "stat"
    }

    init(status: Status, result: Result<Model, ResponseError>) {
        self.status = status
        self.result = result
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Status.self, forKey: .status)
        switch status {
        case .ok: result = .success(try Model(from: decoder))
        case .fail: result = .failure(try ResponseError(from: decoder))
        }
    }
}

extension Response: Equatable where Model: Equatable {}
