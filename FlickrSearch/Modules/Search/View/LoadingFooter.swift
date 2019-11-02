import UIKit

final class LoadingFooter: UICollectionReusableView, StaticIdentifiable {
    static let identifier = "LoadingFooter"

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        hide()
    }

    func show() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }

    func hide() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}
