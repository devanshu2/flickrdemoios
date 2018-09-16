//
//  PublicClosures.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 17/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import Foundation

typealias FlickrAuthBeginCompletion = (_ flickrLoginPageURL: URL?, _ error: Error?) -> Void
typealias FlickrAPIAuthCompletion = (_ userName: String?, _ userId: String?, _ fullName:String?, _ error: Error?) -> Void
typealias FlickrPhotoFetchCompletion = (_ response: FlickrPhotoFetchResponse?, _ error: Error?) -> Void
