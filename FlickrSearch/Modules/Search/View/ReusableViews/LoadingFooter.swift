import UIKit

final class LoadingFooter: UICollectionReusableView, StaticIdentifiable {
    static let identifier = "LoadingFooter"

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        hide()
    }

    func show() {
        onMain { [weak self] in
            self?.activityIndicator.startAnimating()
            self?.activityIndicator.isHidden = false
        }
    }

    func hide() {
        onMain { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
        }
    }
}
