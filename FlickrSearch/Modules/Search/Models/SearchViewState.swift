enum SearchViewState {
    case empty
    case noResults
    case loading(resultsEmpty: Bool)
    case loaded(type: ReloadType)
    case failed(reasonTitle: String, reasonMessage: String)
}
