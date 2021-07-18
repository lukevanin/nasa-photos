//
//  SceneDelegate.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/12.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        // Set up the UI theme
        Theme.current = CustomTheme()
        // Create and present the initial view controller.
        let builder = AppBuilder()
        let viewController = builder.makeViewController()
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}
