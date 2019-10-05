//
//  AppDelegate.swift
//  AppleSignInWithKeychain
//
//  Created by Will Chen on 2019/10/3.
//  Copyright © 2019 rukurouc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let initialViewController = ViewController()
        let frame = UIScreen.main.bounds
        self.window = UIWindow(frame: frame)
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        return true
    }
}

