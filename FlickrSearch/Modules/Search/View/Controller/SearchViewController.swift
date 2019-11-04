import UIKit

protocol SearchViewOutput: class {
    var itemsPerRow: Int { get }
    var totalItems: Int { get }
    func viewDidLoad()
    func viewModel(at index: Int) -> ImageViewModel?
    func didSelectItem(at index: Int)
    func searchTextDidChange(_ searchText: String)
    func didScrollToBottom()
}

final class SearchViewController: UIViewController, StoryboardInstantiable {
    static let storyboardName = "Search"
    static let identifier = "SearchViewController"

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noResultsLabel: UILabel!
    @IBOutlet private weak var startTypingLabel: UILabel!

    var interactor: SearchViewOutput!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureKeyboard()
        configureCollectionView()
        configureSearchBar()
        interactor.viewDidLoad()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        })
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        interactor.searchTextDidChange(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interactor.totalItems
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(ImageCell.self, at: indexPath)
        guard let model = interactor.viewModel(at: indexPath.row) else { return cell }
        cell.configure(with: model)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter else { return UICollectionReusableView() }
        return collectionView.dequeue(LoadingFooter.self, at: indexPath, for: .footer)
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        interactor.didSelectItem(at: indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interitemSpacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
        let leftInsets = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset.left ?? 0
        let rightInsets = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset.right ?? 0
        let itemsPerRow = interactor.itemsPerRow
        let spacing = (leftInsets + rightInsets) + interitemSpacing * CGFloat(itemsPerRow - 1)
        let width = (collectionView.bounds.width - spacing) / CGFloat(itemsPerRow)

        return CGSize(width: Int(width), height: 150)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomOffset = collectionView.contentSize.height - collectionView.bounds.size.height
        if scrollView.contentOffset.y == bottomOffset {
            interactor.didScrollToBottom()
        }
    }
}

extension SearchViewController: SearchPresenterOutput {
    func set(state: SearchViewState) {
        onMain { [weak self] in
            switch state {
            case .empty:
                self?.setEmptyState()
            case .noResults:
                self?.setNoResultsState()
            case .loading(let resultsEmpty):
                self?.setLoadingState(resultsEmpty: resultsEmpty)
            case .loaded(let type):
                self?.setLoadedState(type: type)
            case .failed(let reasonTitle, let reasonMessage):
                self?.setFailedState(title: reasonTitle, message: reasonMessage)
            }
        }
    }
}

private extension SearchViewController {
    func setEmptyState() {
        noResultsLabel.isHidden = true
        startTypingLabel.isHidden = false
        hideMainActivityIndicator()
        hideFooterActivityIndicator()
        collectionView.reloadData()
    }

    func setNoResultsState() {
        noResultsLabel.isHidden = false
        startTypingLabel.isHidden = true
        hideMainActivityIndicator()
        hideFooterActivityIndicator()
        collectionView.reloadData()
    }

    func setLoadingState(resultsEmpty: Bool) {
        noResultsLabel.isHidden = true
        startTypingLabel.isHidden = true
        showActivityIndicator(resultsEmpty: resultsEmpty)
    }

    func setLoadedState(type: ReloadType) {
        noResultsLabel.isHidden = true
        startTypingLabel.isHidden = true
        hideMainActivityIndicator()
        hideFooterActivityIndicator()
        switch type {
        case .reloadData:
            collectionView.reloadData()
            collectionView.scrollToItem(at: [0, 0], at: .top, animated: false)
        case .insert(let indices):
            indices.isEmpty ? collectionView.reloadData() : collectionView.insertItems(at: indices)
        }
    }

    func setFailedState(title: String, message: String) {
        setLoadedState(type: .reloadData)
        showAlert(title: title, message: message)
    }

    func showActivityIndicator(resultsEmpty: Bool) {
        if resultsEmpty {
            showMainActivityIndicator()
            hideFooterActivityIndicator()
        } else {
            hideMainActivityIndicator()
            showFooterActivityIndicator()
        }
    }

    func showMainActivityIndicator() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }

    func hideMainActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }

    func showFooterActivityIndicator() {
        getLoadingFooter()?.show()
    }

    func hideFooterActivityIndicator() {
        getLoadingFooter()?.hide()
    }

    func getLoadingFooter() -> LoadingFooter? {
        return collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionFooter,
            at: [0, 0]
        ) as? LoadingFooter
    }

    func showAlert(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel)
        controller.addAction(ok)
        present(controller, animated: true)
    }

    func configureSearchBar() {
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
    }

    func configureCollectionView() {
        collectionView.register(ImageCell.self)
        collectionView.register(LoadingFooter.self, for: .footer)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func configureKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}
