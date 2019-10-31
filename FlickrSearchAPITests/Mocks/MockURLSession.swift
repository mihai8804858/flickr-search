@testable import FlickrSearchAPI

final class MockURLSession: URLSessionType {
    var dataTaskCallParameters: [(URLRequest, DispatchQueue?, (Data?, URLResponse?, Error?) -> Void)] = []
    var dataTaskStub: (Data?, URLResponse?, Error?)!
    var sessionDataTaskStub: Task!

    func task(with request: URLRequest,
              callbackQueue: DispatchQueue?,
              callback: @escaping (Data?, URLResponse?, Error?) -> Void) -> Task {
        dataTaskCallParameters.append((request, callbackQueue, callback))
        callback(dataTaskStub.0, dataTaskStub.1, dataTaskStub.2)
        return sessionDataTaskStub
    }
}
