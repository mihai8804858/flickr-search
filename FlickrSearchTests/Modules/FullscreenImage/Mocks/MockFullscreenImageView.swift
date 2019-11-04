@testable import FlickrSearch
import UIKit

final class MockFullscreenImageView: FullscreenImagePresenterOutput {
    let setPlaceholderImageFuncCheck = ZeroArgumentsFuncCheck()
    func setPlaceholderImage() {
        setPlaceholderImageFuncCheck.call()
    }

    let setImageFuncCheck = FuncCheck<UIImage>()
    func set(image: UIImage) {
        setImageFuncCheck.call(image)
    }
}
