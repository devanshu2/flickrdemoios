//
//  CustomImageView.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 15/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {

    public var remoteImageURL: URL?
    
    private var isRemoteImageFetchNotificationObserver = false
    
    deinit {
        self.removeSelfForRemoteImageFetchNotification()
    }
    
    public func setImage(with url: URL?, placeHolder placeHolderImage: UIImage? = nil) {
        self.image = placeHolderImage
        self.remoteImageURL = url
        if let url = url {
            ImageDownloader.shared.getImage(url: url)
            self.addSelfForRemoteImageFetchNotification()
        }
        else {
            self.removeSelfForRemoteImageFetchNotification()
        }
    }
    
    private func addSelfForRemoteImageFetchNotification() {
        if self.isRemoteImageFetchNotificationObserver == false {
            NotificationCenter.default.addObserver(self, selector: #selector(self.imageRemoteFetchNotificationHandler(_:)), name: Constants.Notifications.ImageFetchNotification, object: nil)
        }
    }
    
    private func removeSelfForRemoteImageFetchNotification() {
        if self.isRemoteImageFetchNotificationObserver {
            NotificationCenter.default.removeObserver(self, name: Constants.Notifications.ImageFetchNotification, object: nil)
        }
    }
    
    @objc private func imageRemoteFetchNotificationHandler(_ notification: Notification) {
        if let remoteImage = notification.userInfo?[String.kImage] as? UIImage, let remoteImageURLString = notification.userInfo?[String.kImageURL] as? String, let imageURLString = self.remoteImageURL?.absoluteString {
            if remoteImageURLString == imageURLString {
                DispatchQueue.main.async {
                    self.image = remoteImage
                }
                self.removeSelfForRemoteImageFetchNotification()
            }
        }
    }
}
