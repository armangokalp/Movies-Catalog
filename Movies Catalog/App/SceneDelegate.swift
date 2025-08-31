//
//  SceneDelegate.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 25.08.2025.
//

//  App bootstrap and dependency injection setup

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Configure all services before creating any view controllers
        setupDependencyInjection()
        
        window = UIWindow(windowScene: windowScene)
        window?.overrideUserInterfaceStyle = .dark
        
        // Set app-wide tint color
        window?.tintColor = Constants.Colors.primary
        
        // Use factory pattern to ensure proper dependency injection throughout the app
        let factory = AppViewControllerFactory()
        let rootViewController = factory.makeRootViewController()
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    private func setupDependencyInjection() {
        let container = AppDependencyContainer.shared
        
        // Register concrete implementations for protocol-based services
        // This approach allows easy testing with mock services
        container.register(MovieAPIService.self) {
            APIService()
        }
        
        container.register(ImageLoadingService.self) {
            ImageLoader()
        }
        
        container.register(CacheServiceProtocol.self) {
            CacheService()
        }
        
        container.register(ViewControllerFactory.self) {
            AppViewControllerFactory()
        }

        container.register(MoviePlayerViewModel.self) {
            MoviePlayerViewModel()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

