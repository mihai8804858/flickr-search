import UIKit

final class ImageCell: UICollectionViewCell, StaticIdentifiable {
    static let identifier = "ImageCell"

    @IBOutlet weak var imageView: UIImageView!

    private var viewModel: ImageViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    func configure(with model: ImageViewModel) {
        viewModel = model
        loadPhoto(with: model)
    }

    private func reset() {
        viewModel = nil
        imageView.image = #imageLiteral(resourceName: "placeholder")
    }

    private func loadPhoto(with model: ImageViewModel) {
        model.imageProvider { photoID, image in
            DispatchQueue.main.async { [weak self] in
                guard let self = self, photoID == self.viewModel?.photoID else { return }
                self.imageView.image = image
            }
        }
    }
}
