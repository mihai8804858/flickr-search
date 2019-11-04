import FlickrSearchAPI

enum ImageLoadingError: Error, CustomDebugStringConvertible, Equatable {
    case api(APIError)
    case badData(Data)

    var debugDescription: String {
        switch self {
        case .api(let error):
            return error.debugDescription
        case .badData:
            return "Bad data"
        }
    }
}
