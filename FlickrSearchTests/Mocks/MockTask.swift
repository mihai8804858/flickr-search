import FlickrSearchAPI

final class MockTask: Task {
    let id: String

    init(id: String) {
        self.id = id
    }

    let resumeFuncCheck = ZeroArgumentsFuncCheck()
    func resume() {
        resumeFuncCheck.call()
    }

    let cancelFuncCheck = ZeroArgumentsFuncCheck()
    func cancel() {
        cancelFuncCheck.call()
    }
}
