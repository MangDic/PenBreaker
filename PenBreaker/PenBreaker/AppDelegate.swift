//
//  AppDelegate.swift
//  PenBreaker
//
//  Created by 이명직 on 2022/11/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let window = window else { return false }
        
        let vc = ViewController()
        window.backgroundColor = .white
        window.rootViewController = vc
        window.makeKeyAndVisible()
        
        return true
    }
}

