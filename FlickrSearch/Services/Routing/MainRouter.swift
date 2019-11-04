import UIKit

protocol MainRouting {
    func navigateToRootViewController()
}

struct MainRouter {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func navigateToRootViewController() {
        window.rootViewController = SearchBuilder().buildModule()
    }
}
