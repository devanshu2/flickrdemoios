//
//  FlickrPhotoFetchResponse.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 17/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import Foundation
import Gloss

class FlickrPhotoFetchResponse: JSONDecodable {
    var photoResponse: FlickrPhotoResponse?
    var stat: FlickrPhotoFetchStatus?
    var code: Int?
    var message: String?
    
    required init?(json: JSON) {
        self.photoResponse = "photos" <~~ json
        self.stat = "stat" <~~ json
        self.code = "code" <~~ json
        self.message = "message" <~~ json
    }
}
