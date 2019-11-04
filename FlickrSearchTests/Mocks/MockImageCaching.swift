@testable import FlickrSearch
import FlickrSearchAPI
import Foundation

final class MockImageCaching: ImageCaching {
    let containsFuncCheck = FuncCheck<(String, Callback<Bool>)>()
    var containsStub = false
    func contains(forID id: String, callback: Callback<Bool>) {
        containsFuncCheck.call((id, callback))
        callback.execute(with: containsStub)
    }

    let getFuncCheck = FuncCheck<(String, Callback<IdentifiableImage?>)>()
    var getStub: IdentifiableImage? = nil
    func get(forID id: String, callback: Callback<IdentifiableImage?>) {
        getFuncCheck.call((id, callback))
        callback.execute(with: getStub)
    }

    let setFuncCheck = FuncCheck<IdentifiableImage>()
    func set(model: IdentifiableImage) {
        setFuncCheck.call(model)
    }
}
