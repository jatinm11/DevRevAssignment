//
//  AppDelegate.swift
//  DevRevAssignment
//
//  Created by Jatin Menghani on 09/02/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.overrideUserInterfaceStyle = .light
        window?.rootViewController = MoviesListViewController.controller()
        window?.makeKeyAndVisible()
        
        return true
    }
}

