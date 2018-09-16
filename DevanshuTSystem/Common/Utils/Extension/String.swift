//
//  String.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 15/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import Foundation

extension String {
    static let kImageURL = "kImageURL"
    static let kImage = "kImage"
    static let kPut = "PUT"
    static let kPost = "POST"
    static let kGet = "GET"
    static let kDelete = "DELETE"
    static let kFlickrStoredTokenKey = "kFlickrStoredTokenKey"
    static let kFlickrStoredTokenSecret = "kFlickrStoredTokenSecret"
    static let kCallBackURL = "kCallBackURL"
    
    func urlQueryString() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    func saveToFile(encoding:String.Encoding = .utf8) -> String? {
        let d = String(Date().timeIntervalSince1970)
        var path = Constants.General.Documents + "/logs"
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        path = path + "/" + d + ".txt"
        do {
            try self.write(toFile: path, atomically: true, encoding: encoding)
            debugPrint("Post params logged to file: " + path)
        }
        catch {
            debugPrint(error.localizedDescription)
            return nil
        }
        return path
    }
    
    var escapedURLString: String? {
        get {
            return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)
        }
    }
    
    //    return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];

    var queryParamsUserInfo: [String:String] {
        get {
            var params:[String:String] = [:]
            let items = self.split(separator: "&")
            for item in items {
                let kv = item.split(separator: "=")
                if kv.count == 2 {
                    params[String(kv[0])] = String(kv[1])
                }
            }
            return params
        }
    }
}
