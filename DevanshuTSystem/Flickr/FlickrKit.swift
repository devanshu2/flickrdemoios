//
//  FlickrKit.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 15/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import UIKit

class FlickrKit: NSObject {
    
    public private(set) var apiKey: String!
    
    public private(set) var apiSecret: String!
    
    public private(set) var isAuthorized: Bool = false
    
    public private(set) var authToken: String?
    public private(set) var authSecret: String?
    public private(set) var permissionGranted = FlickrPermission.read
    
    private var beginAuthURL: URL?
    
    static var shared: FlickrKit = {
        let obj = FlickrKit()
        return obj
    }()
    
    public func initialize(apiKey: String, apiSecret: String) {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
    }
    
    public func beginAuth(withCallbackURL url:URL, Completion completion:@escaping FlickrAuthBeginCompletion) {
        if self.beginAuthURL != nil {
            completion(self.beginAuthURL, nil)
            return
        }
        let paramsDictionary = ["oauth_callback": url.absoluteString]
        let urlBuilder = FlickrURLBuilder()
        let requestURL = urlBuilder.oauthURL(FromBaseURL: URL(string: Constants.Flickr.oauthBaseURLString)!, httpMethod: .get, httpParams: paramsDictionary)
        
        var request = URLRequest(url: requestURL!)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = FlickrHttpMethod.get.rawValue
        for (key, value) in NetworkManger.getDefaultHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }
        let networkManager = NetworkManger()
        _ = networkManager.makeServerRequest(request) { (data, urlResponse, error) in
            if let responseParams = data?.stringValue?.queryParamsUserInfo,
                let oauthToken = responseParams["oauth_token"],
                let oauthTokenSecret = responseParams["oauth_token_secret"] {
                self.authToken = oauthToken
                self.authSecret = oauthTokenSecret
                self.beginAuthURL = self.userAuthorizationURL(WithRequestToken: oauthToken)
                completion(self.beginAuthURL, nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    public func logout () {
        UserDefaults.standard.removeObject(forKey: String.kFlickrStoredTokenKey)
        UserDefaults.standard.removeObject(forKey: String.kFlickrStoredTokenSecret)
        UserDefaults.standard.synchronize()
        self.isAuthorized = false
        self.authSecret = nil
        self.authToken = nil
        self.beginAuthURL = nil
    }
    
    public func fetchPhotos(_ userId:String? = nil, SearchText text: String? = nil, PageNumber page:Int = 1, Completion completion: @escaping FlickrPhotoFetchCompletion) -> URLSessionDataTask? {
        var args: [String: String] = [:]
        if let storedToken = UserDefaults.standard.string(forKey: String.kFlickrStoredTokenKey) {
            args["oauth_token"] = storedToken
        }
        args["method"] = "flickr.photos.search"
        args["format"] = "json"
        args["nojsoncallback"] = "1"
        args["per_page"] = "24"
        args["page"] = "\(page)"
        if userId != nil {
            args["user_id"] = userId
        }
        if text != nil {
            args["text"] = text
        }
        let urlBuilder = FlickrURLBuilder()
        var url:URL!
        if self.isAuthorized {
            url = urlBuilder.oauthURL(FromBaseURL: URL(string: Constants.Flickr.restAPI)!, httpMethod: .get, httpParams: args)
        }
        else {
            let query = urlBuilder.signedQueryString(FromParameters: args)
            let urlString = String(format:"%@?%@", Constants.Flickr.restAPI, query)
            url = URL(string: urlString)!
        }
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = String.kGet
        let networkManager = NetworkManger()
        let dataTask = networkManager.makeServerRequest(request) { (data, urlResponse, error) in
            if let data = data {
                do {
                    do {
                        if let responseData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            guard let jsonDict = FlickrPhotoFetchResponse(json: responseData) else {
                                debugPrint("Could not convert json into data model")
                                completion(nil, error)
                                return
                            }
                            completion(jsonDict, nil)
                            return
                        }
                    }
                    catch {
                        debugPrint(error.localizedDescription)
                    }
                }
            }
            completion(nil, error)
        }
        return dataTask
    }
    
    public func photoURL(ForSize size:FlickrPhotoSize, fromPhoto photo: FlickrPhoto) -> URL {
        let photoID = photo.id
//        if photoID == nil {
//            let photoID = photoDict["primary"]
//        }
        let server = photo.server
        let farm = photo.farm
        let secret = photo.secret
        return self.photoURL(ForSize: size, PhotoID: photoID!, Server: server!, Secret: secret!, Farm: farm)
    }
    
    public func photoURL(ForSize size:FlickrPhotoSize, PhotoID photoID:String, Server server:String, Secret secret:String, Farm farm:Int?) -> URL {
        var urlString = "https://"
        if farm != nil {
            urlString.append(String(format:"farm%ld.", farm!))
        }
        urlString.append("static.flickr.com/")
        urlString.append(String(format:"%@/%@_%@", server, photoID, secret))
        urlString.append(String(format:"_%@.jpg", size.rawValue))
        return URL(string: urlString)!
    }
    
    public func checkAuthorization(_ completion: @escaping FlickrAPIAuthCompletion) {
        if let storedToken = UserDefaults.standard.string(forKey: String.kFlickrStoredTokenKey), let storedSecret = UserDefaults.standard.string(forKey: String.kFlickrStoredTokenSecret) {
            var args = ["oauth_token": storedToken]
            
            args["method"] = "flickr.auth.oauth.checkToken"
            args["format"] = "json"
            args["nojsoncallback"] = "1"
            
            let urlBuilder = FlickrURLBuilder()
            var url:URL!
            if self.isAuthorized {
                url = urlBuilder.oauthURL(FromBaseURL: URL(string: Constants.Flickr.restAPI)!, httpMethod: .get, httpParams: args)
            }
            else {
                let query = urlBuilder.signedQueryString(FromParameters: args)
                let urlString = String(format:"%@?%@", Constants.Flickr.restAPI, query)
                url = URL(string: urlString)!
            }
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            request.httpMethod = String.kGet
            let networkManager = NetworkManger()
            _ = networkManager.makeServerRequest(request) { (data, urlResponse, error) in
                if let data = data {
                    do {
                        do {
                            if let responseData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                self.authToken = storedToken
                                self.authSecret = storedSecret
                                var username:String?
                                var userid:String?
                                var fullname:String?
                                if let userData = responseData["oauth"] as? [String:Any], let userInfo = userData["user"] as? [String: String] {
                                    username = userInfo["username"]
                                    userid = userInfo["nsid"]
                                    fullname = userInfo["fullname"]
                                }
                                self.isAuthorized = true
                                completion(username?.removingPercentEncoding, userid, fullname?.removingPercentEncoding, nil)
                                return
                            }
                        }
                        catch {
                            debugPrint(error.localizedDescription)
                        }
                    }
                }
                completion(nil, nil, nil, error)
            }
        }
        else {
            let errorDescription = "There isn't a stored token to check. Login first."
            let userInfo = [NSLocalizedDescriptionKey: errorDescription]
            let error = NSError(domain: "errorDomain", code: -9999, userInfo: userInfo)
            completion(nil, nil, nil, error)
        }
    }
    
    public func completeAuth(with url:URL, andCompletion completion: @escaping FlickrAPIAuthCompletion) {
        if let result = url.queryParamsUserInfo,
            let token = result["oauth_token"],
            let verifier = result["oauth_verifier"]
            {
                let paramsDictionary = ["oauth_token": token, "oauth_verifier": verifier]
                let urlBuilder = FlickrURLBuilder()
                let baseURL = URL(string: "https://www.flickr.com/services/oauth/access_token")!
                let requestURL = urlBuilder.oauthURL(FromBaseURL: baseURL, httpMethod: .get, httpParams: paramsDictionary)
                
                var request = URLRequest(url: requestURL!)
                request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                request.httpMethod = FlickrHttpMethod.get.rawValue
                for (key, value) in NetworkManger.getDefaultHeaders() {
                    request.setValue(value, forHTTPHeaderField: key)
                }
                let networkManager = NetworkManger()
                _ = networkManager.makeServerRequest(request) { (data, urlResponse, error) in
                    let responseString = data?.stringValue
                    if let responseParamString = responseString?.removingPercentEncoding {
                        let responseStringValue = responseString!
                        if responseParamString.hasPrefix("oauth_problem=") {
                            self.beginAuthURL = nil
                            self.isAuthorized = false
                            self.authToken = nil
                            self.authSecret = nil
                            let userInfo = [NSLocalizedDescriptionKey: responseStringValue]
                            let error = NSError(domain: "errorDomain", code: -9999, userInfo: userInfo)
                            completion(nil, nil, nil, error)
                        }
                        else {
                            let params = responseStringValue.queryParamsUserInfo
                            let fullname = params["fullname"]
                            let oauthToken = params["oauth_token"]
                            let oauthTokenSecret = params["oauth_token_secret"]
                            let userNsid = params["user_nsid"]
                            let username = params["username"]
                            if oauthToken == nil || oauthTokenSecret == nil || userNsid == nil {
                                let userInfo = [NSLocalizedDescriptionKey: responseStringValue]
                                let error = NSError(domain: "errorDomain", code: -9999, userInfo: userInfo)
                                completion(nil, nil, nil, error)
                            } else {
                                UserDefaults.standard.set(oauthToken, forKey: String.kFlickrStoredTokenKey)
                                UserDefaults.standard.set(oauthTokenSecret, forKey: String.kFlickrStoredTokenSecret)
                                UserDefaults.standard.synchronize()
                                self.isAuthorized = true
                                self.authToken = oauthToken
                                self.authSecret = oauthTokenSecret
                                self.beginAuthURL = nil
                                completion(username?.removingPercentEncoding, userNsid?.removingPercentEncoding, fullname?.removingPercentEncoding, nil)
                            }
                        }
                    }
                    else {
                        completion(nil, nil, nil, error)
                    }
                }
        }
        else {
            let errorString = String(format:"Cannot obtain token/secret from URL: %@", url.absoluteString)
            let userInfo = [NSLocalizedDescriptionKey: errorString]
            let error = NSError(domain: "errorDomain", code: -9999, userInfo: userInfo)
            completion(nil, nil, nil, error)
        }
    }
    
    //Mark:- Auth URL
    private func userAuthorizationURL(WithRequestToken inRequestToken:String) -> URL {
        let perms = String(format:"&perms=read")
        let urlString = String(format:"https://www.flickr.com/services/oauth/authorize?oauth_token=%@%@", inRequestToken, perms)
        return URL(string: urlString)!
    }
}
