//
//  AppDelegate.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 15/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FlickrKit.shared.initialize(apiKey: Constants.Flickr.key, apiSecret: Constants.Flickr.secret)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "devanshutsystemflickr" {
            NotificationCenter.default.post(name: Constants.Notifications.UserAuthCallbackNotification, object: nil, userInfo:[String.kCallBackURL:url])
        }
        return true
    }
}

