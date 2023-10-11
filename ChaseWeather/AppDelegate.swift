//
//  AppDelegate.swift
//  ChaseWeather
//
//  Created by Ronald Jones on 10/10/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {

    var window: UIWindow?
    let navigationController = UINavigationController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow( frame: UIScreen.main.bounds)
        
        let start = HomeViewController()
        
        navigationController.viewControllers = [start]
        self.window!.rootViewController = UINavigationController(rootViewController: start)
        
        self.window!.makeKeyAndVisible()
        
        return true
    }
    
}

