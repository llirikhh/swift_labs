
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let storeVC = StoreViewController()
        let cartVC = CartViewController.shared
        
        let storeNav = UINavigationController(rootViewController: storeVC)
        let cartNav = UINavigationController(rootViewController: cartVC)
        
        storeNav.tabBarItem = UITabBarItem(
            title: "Category page",
            image: UIImage(systemName: "list.bullet"),
            selectedImage: nil
        )
        
        cartNav.tabBarItem = UITabBarItem(
            title: "Cart page",
            image: UIImage(systemName: "cart"),
            selectedImage: nil        )
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [storeNav, cartNav]
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}
