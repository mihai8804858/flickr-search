@testable import FlickrSearchAPI

final class MockRequester: RequesterType {
    var requestDataCallParameters: [(RequestType, Callback<Result<Data, APIError>>)] = []
    var requestDataStubTask: Task!
    var requestDataStub: Result<Data, APIError>!

    func requestData(with request: RequestType, callback: Callback<Result<Data, APIError>>) -> Task {
        requestDataCallParameters.append((request, callback))
        callback.execute(with: requestDataStub)
        return requestDataStubTask
    }
}
