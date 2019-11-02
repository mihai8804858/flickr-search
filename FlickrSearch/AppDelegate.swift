import UIKit
import FlickrSearchAPI

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let api = FlickrSearchAPI(apiKey: "3e7cc266ae2b0e0d78e279ce8e361736")
        let imageCacher = ImageCacher(storage: FileManager.default)
        let imageLoader = ImageLoader(api: api, cacher: imageCacher)
        window?.rootViewController = SearchBuilder().buildModule(api: api, imageLoader: imageLoader)

        return true
    }
}
