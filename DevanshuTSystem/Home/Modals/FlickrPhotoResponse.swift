//
//  FlickrPhotoResponse.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 17/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import Foundation
import Gloss

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
