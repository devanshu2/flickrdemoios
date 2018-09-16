//
//  PublicEnums.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 17/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import UIKit

enum FlickrPhotoFetchStatus: String {
    case ok = "ok"
    case fail = "fail"
}


enum GridState: Int {
    case dual = 2
    case triple = 3
    case quad = 4
    
    func getImage() -> UIImage {
        switch self {
        case .dual:
            return #imageLiteral(resourceName: "grid-2")
        case .triple:
            return #imageLiteral(resourceName: "grid-3")
        default:
            return #imageLiteral(resourceName: "grid-4")
        }
    }
}


enum FlickrPermission: String {
    case read = "read"
    case write = "write"
    case delete = "delete"
}


enum FlickrPhotoSize: String {
    case unknown = ""
    case collectionIconLarge = "collectionIconLarge"
    case buddyIcon = "buddyIcon"
    case smallSquare75 = "s"
    case largeSquare150 = "q"
    case thumbnail100 = "t"
    case small240 = "m"
    case small320 = "n"
    case medium640 = "z"
    case medium800 = "c"
    case large1024 = "b"
    case large1600 = "h"
    case large2048 = "k"
    case original = "o"
}

enum FlickrHttpMethod: String {
    case get = "GET"
    case post = "POST"
}
