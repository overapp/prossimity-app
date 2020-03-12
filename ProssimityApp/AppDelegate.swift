//
//  AppDelegate.swift
//  ProssimityApp
//
//  Created by Lavinia Bertuzzi on 04/03/2020.
//  Copyright © 2020 OverApp. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Disable idle timer
        UIApplication.shared.isIdleTimerDisabled = true
    }
}

