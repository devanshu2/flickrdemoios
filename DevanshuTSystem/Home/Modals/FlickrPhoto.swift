//
//  FlickrPhoto.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 16/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import Foundation
import Gloss

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


