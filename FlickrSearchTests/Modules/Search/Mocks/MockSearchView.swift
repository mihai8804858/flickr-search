@testable import FlickrSearch

final class MockSearchView: SearchPresenterOutput {
    let setStateFuncCheck = FuncCheck<SearchViewState>()
    func set(state: SearchViewState) {
        setStateFuncCheck.call(state)
    }
}
