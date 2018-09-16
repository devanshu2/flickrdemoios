//
//  URL.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 16/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import Foundation

extension URL {
    var queryParamsUserInfo: [String:String]? {
        get {
            return self.query?.queryParamsUserInfo
        }
    }
}
