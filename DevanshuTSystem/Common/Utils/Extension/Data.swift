//
//  Data.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 16/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import Foundation

extension Data {
    var stringValue:String? {
        get {
            return String(data:self, encoding:.utf8)
        }
    }
}
