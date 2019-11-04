@testable import FlickrSearchAPI

final class MockURLSession: URLSessionType {
    var dataTaskStub: (Data?, URLResponse?, Error?)!
    var sessionDataTaskStub: Task!
    let taskFuncCheck = FuncCheck<(URLRequest, Callback<(Data?, URLResponse?, Error?)>)>()
    func task(with request: URLRequest, callback: Callback<(Data?, URLResponse?, Error?)>) -> Task {
        taskFuncCheck.call((request, callback))
        callback.execute(with: (dataTaskStub.0, dataTaskStub.1, dataTaskStub.2))
        return sessionDataTaskStub
    }
}
