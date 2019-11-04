@testable import FlickrSearch
import FlickrSearchAPI
import Foundation

final class MockImageLoading: ImageLoading {
    let getImageFuncCheck = FuncCheck<(URL, Callback<Result<IdentifiableImage, ImageLoadingError>>)>()
    var getImageStub: Result<IdentifiableImage, ImageLoadingError> = .failure(.badData(Data()))
    func getImage(from url: URL, callback: Callback<Result<IdentifiableImage, ImageLoadingError>>) {
        getImageFuncCheck.call((url, callback))
        callback.execute(with: getImageStub)
    }
}
