@testable import FlickrSearchAPI

final class MockRequester: RequesterType {
    var requestDataCallParameters: [(RequestType, DispatchQueue?, (Result<Data, APIError>) -> Void)] = []
    var requestDataStubTask: Task!
    var requestDataStub: Result<Data, APIError>!

    func requestData(
        with request: RequestType,
        callbackQueue: DispatchQueue?,
        callback: @escaping (Result<Data, APIError>) -> Void
    ) -> Task {
        requestDataCallParameters.append((request, callbackQueue, callback))
        callback(requestDataStub)
        return requestDataStubTask
    }
}
