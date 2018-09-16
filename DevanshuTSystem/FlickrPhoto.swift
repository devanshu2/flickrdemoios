//
//  FlickrPhoto.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 16/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import Foundation
import Gloss

enum FlickrPhotoFetchStatus: String {
    case ok = "ok"
    case fail = "fail"
}

class FlickrPhoto: JSONDecodable {
    var id: String?
    var owner: String?
    var secret: String?
    var server: String?
    var farm: Int?
    var title: String?
    var ispublic: Int?
    var isfriend: Int?
    var isfamily: Int?
    
    required init?(json: JSON) {
        self.id = "id" <~~ json
        if self.id == nil {
            return nil
        }
        self.owner = "owner" <~~ json
        self.secret = "secret" <~~ json
        self.server = "server" <~~ json
        self.farm = "farm" <~~ json
        self.title = "title" <~~ json
        self.ispublic = "ispublic" <~~ json
        self.isfriend = "isfriend" <~~ json
        self.isfamily = "isfamily" <~~ json
    }
}

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

class FlickrPhotoResponse: JSONDecodable {
    var page: Int?
    var pages: Int?
    var perpage: Int?
    var total: Int?
    var photos: [FlickrPhoto]?
    
    required init?(json: JSON) {
        self.page = "page" <~~ json
        self.pages = "pages" <~~ json
        self.perpage = "perpage" <~~ json
        self.total = "total" <~~ json
        if self.total == nil {
            let totalString:String? = "total" <~~ json
            if totalString != nil {
                self.total = Int(totalString!)
            }
        }
        self.photos = "photo" <~~ json
    }
}


