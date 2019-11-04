import FlickrSearchAPI

final class MockFlickrSearchAPI: FlickrSearchAPIType {
    let searchFuncCheck = FuncCheck<(SearchParameters, Callback<Result<Photos, APIError>>)>()
    var searchStub: Result<Photos, APIError> = .failure(.badRequest)
    var searchTaskStub: Task = MockTask(id: "search")
    func search(with parameters: SearchParameters, callback: Callback<Result<Photos, APIError>>) -> Task {
        searchFuncCheck.call((parameters, callback))
        callback.execute(with: searchStub)
        return searchTaskStub
    }

    let dataFuncCheck = FuncCheck<(URL, Callback<Result<Data, APIError>>)>()
    var dataStub: Result<Data, APIError> = .failure(.badRequest)
    var dataTaskStub: Task = MockTask(id: "data")
    func data(from url: URL, callback: Callback<Result<Data, APIError>>) -> Task {
        dataFuncCheck.call((url, callback))
        callback.execute(with: dataStub)
        return dataTaskStub
    }
}
