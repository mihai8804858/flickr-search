@testable import FlickrSearchAPI

final class MockURLSession: URLSessionType {
    var dataTaskCallParameters: [(URLRequest, Callback<(Data?, URLResponse?, Error?)>)] = []
    var dataTaskStub: (Data?, URLResponse?, Error?)!
    var sessionDataTaskStub: Task!

    func task(with request: URLRequest, callback: Callback<(Data?, URLResponse?, Error?)>) -> Task {
        dataTaskCallParameters.append((request, callback))
        callback.execute(with: (dataTaskStub.0, dataTaskStub.1, dataTaskStub.2))
        return sessionDataTaskStub
    }
}
