import Foundation
import FlickrSearchAPI

protocol ImageLoading {
    func getImage(from url: URL, callback: Callback<Result<IdentifiableImage, ImageLoadingError>>)
}
