@testable import FlickrSearchAPI

final class MockRequester: RequesterType {
    var requestDataStubTask: Task!
    var requestDataStub: Result<Data, APIError>!
    let requestDataFuncCheck = FuncCheck<(RequestType, Callback<Result<Data, APIError>>)>()
    func requestData(with request: RequestType, callback: Callback<Result<Data, APIError>>) -> Task {
        requestDataFuncCheck.call((request, callback))
        callback.execute(with: requestDataStub)
        return requestDataStubTask
    }
}
