import UIKit

protocol StoryboardInstantiable: StaticIdentifiable {
    static var storyboardName: String { get }
}

extension StoryboardInstantiable {
    static func instantiate() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: identifier) as? Self else {
            fatalError("Type mismatch for view controller with identifier \(Self.identifier)")
        }

        return controller
    }
}
