import UIKit

enum SupplementaryViewKind {
    case header
    case footer

    var identifier: String {
        switch self {
        case .header: return UICollectionView.elementKindSectionHeader
        case .footer: return UICollectionView.elementKindSectionFooter
        }
    }
}

extension UICollectionView {
    func dequeue<T: UICollectionViewCell & StaticIdentifiable>(_ type: T.Type, at indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: type.identifier, for: indexPath) as? T else {
            fatalError("Type mismatch for cell with identifier \(type.identifier)")
        }
        return cell
    }

    func dequeue<T: UICollectionReusableView & StaticIdentifiable>(_ type: T.Type, at indexPath: IndexPath, for kind: SupplementaryViewKind) -> T {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: kind.identifier,
            withReuseIdentifier: type.identifier,
            for: indexPath
        ) as? T else {
            fatalError("Type mismatch for reusable view with identifier \(type.identifier)")
        }
        return view
    }

    func register<T: UICollectionViewCell & StaticIdentifiable>(_ type: T.Type) {
        register(
            UINib(nibName: type.identifier, bundle: nil),
            forCellWithReuseIdentifier: type.identifier
        )
    }

    func register<T: UICollectionReusableView & StaticIdentifiable>(_ type: T.Type, for kind: SupplementaryViewKind) {
        register(
            UINib(nibName: type.identifier, bundle: nil),
            forSupplementaryViewOfKind: kind.identifier,
            withReuseIdentifier: type.identifier
        )
    }
}
