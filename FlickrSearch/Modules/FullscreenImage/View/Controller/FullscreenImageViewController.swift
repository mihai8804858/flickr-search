import UIKit

protocol FullscreenImageViewOutput: class {
    func viewDidLoad()
}

final class FullscreenImageViewController: UIViewController, StoryboardInstantiable {
    static let storyboardName = "FullscreenImage"
    static let identifier = "FullscreenImageViewController"

    @IBOutlet private weak var imageView: UIImageView!

    var interactor: FullscreenImageViewOutput!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSwipeToDismissIfNeeded()
        interactor.viewDidLoad()
    }
}

extension FullscreenImageViewController: FullscreenImagePresenterOutput {
    func setPlaceholderImage() {
        set(image: #imageLiteral(resourceName: "placeholder"))
    }

    func set(image: UIImage) {
        onMain { [weak self] in
            self?.imageView.image = image
        }
    }
}

private extension FullscreenImageViewController {
    func configureSwipeToDismissIfNeeded() {
        if #available(iOS 13, *) { return }
        let recognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(handleSwipe))
        recognizer.direction = .down
        view.addGestureRecognizer(recognizer)
    }

    @objc func handleSwipe() {
        dismiss(animated: true)
    }
}
