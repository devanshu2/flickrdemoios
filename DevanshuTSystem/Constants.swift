//
//  Constants.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 15/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Flickr {
        static let key = "cb638d196804da10f5d0686884705dab"
        static let secret = "bd9122702faa8716"
        static let oauthBaseURLString = "https://www.flickr.com/services/oauth/request_token"
        static let restAPI = "https://api.flickr.com/services/rest/"
    }
    
    struct Storyboards {
        static let Main = "Main"
    }
    
    struct ViewControllerIdentifiers {
        static let PhotoZoomViewController = "PhotoZoomViewController"
    }
    
    struct Segue {
        static let HomeToAuth = "SegueToAuth"
    }
    
    struct EndPoints {
        
    }
    
    struct CellIdentifier {
        static let ImageCollectionViewCell = "ImageCollectionViewCell"
    }
    
    struct General {
        static let Documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        static let Tmp = NSTemporaryDirectory()
        static let AnimationDuration = 0.3
    }
    
    struct Notifications {
        static let ImageFetchNotification = Notification.Name("ImageFetchNotification")
        static let UserAuthCallbackNotification = Notification.Name("UserAuthCallbackNotification")
    }
}

