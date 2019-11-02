import UIKit

typealias PhotoID = String

struct ImageViewModel {
    let photoID: PhotoID
    let imageProvider: (@escaping (PhotoID, UIImage) -> Void) -> Void
}
