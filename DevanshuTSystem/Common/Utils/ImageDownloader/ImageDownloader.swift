//
//  ImageDownloader.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 15/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import UIKit

class ImageDownloader: NSObject {
    private let imageCache = NSCache<NSString, UIImage>()
    
    static var shared: ImageDownloader = {
        let obj = ImageDownloader()
        obj.downloadQueue = OperationQueue()
        return obj
    }()
    
    public var downloadQueue: OperationQueue!
    
    public func getImage(url: URL) {
        if let cachedImage = self.imageCache.object(forKey: url.absoluteString as NSString) {
            NotificationCenter.default.post(name: Constants.Notifications.ImageFetchNotification, object: nil, userInfo: [String.kImage:cachedImage, String.kImageURL:url.absoluteString])
        }
        else {
            //check if already in progress
            let filteredOps = self.downloadQueue.operations.filter { (op) -> Bool in
                if op.name == url.absoluteString {
                    return true
                }
                else {
                    return false
                }
            }
            if filteredOps.count > 0 {
                return
            }
            
            //go for image download
            let operation = ImageDownloadOperation(imageURL: url) { (data, error) in
                if error == nil {
                    if let data = data, let cachedImage = UIImage(data: data) {
                        self.imageCache.setObject(cachedImage, forKey: url.absoluteString as NSString)
                        NotificationCenter.default.post(name: Constants.Notifications.ImageFetchNotification, object: nil, userInfo: [String.kImage:cachedImage, String.kImageURL:url.absoluteString])
                    }
                }
                else {
                    debugPrint(error!.localizedDescription)
                }
            }
            self.downloadQueue.addOperation(operation)
        }
    }
    
    public func setHighPriorityForURLS(_ urlStringSet:Set<String>) {
        for op in self.downloadQueue.operations {
            if urlStringSet.contains(op.name!) {
                op.queuePriority = .normal
            }
            else {
                op.queuePriority = .low
            }
        }
    }
}

