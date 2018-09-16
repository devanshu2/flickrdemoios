//
//  FlickrURLBuilder.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 16/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import UIKit

enum FlickrHttpMethod: String {
    case get = "GET"
    case post = "POST"
}

class FlickrURLBuilder: NSObject {
    
    //MARK:- URL Encryption
    public func oauthURL(FromBaseURL inURL:URL, httpMethod method:FlickrHttpMethod, httpParams params:[String:String]?) -> URL? {
        let newArgs = self.signedOAuth(withHTTPQueryParameters: params, baseURL: inURL, httpMethod: method)
        var queryArray = [String]()
        
        for (key, value) in newArgs {
            queryArray.append(String(format:"%@=%@", key, value.escapedURLString!))
        }
        let newURLStringWithQuery = String(format: "%@?%@", inURL.absoluteString, queryArray.joined(separator: "&"))
        return URL(string: newURLStringWithQuery)
    }
    
    private func signedOAuth(withHTTPQueryParameters params:[String:String]?, baseURL inURL:URL, httpMethod method:FlickrHttpMethod) -> [String:String] {
        
        let httpMethod = method.rawValue
        var newArgs = [String:String]()
        if params != nil {
            newArgs = params!
        }
        
        let generatedUUID = UUID().uuidString
        let index = generatedUUID.index(generatedUUID.startIndex, offsetBy: 8)
        
        newArgs["oauth_nonce"] = String(generatedUUID[..<index])
        let time = Date().timeIntervalSince1970
        newArgs["oauth_timestamp"] = String(format:"%f", time)
        newArgs["oauth_version"] = "1.0"
        newArgs["oauth_signature_method"] = "HMAC-SHA1"
        newArgs["oauth_consumer_key"] = FlickrKit.shared.apiKey //[FlickrKit sharedFlickrKit].apiKey;
        
        if params?["oauth_token"] == nil && FlickrKit.shared.authToken != nil {
            newArgs["oauth_token"] = FlickrKit.shared.authToken!
        }
        
        
        var signatureKey: String
        if FlickrKit.shared.authSecret != nil {
            signatureKey = String(format:"%@&%@", FlickrKit.shared.apiSecret, FlickrKit.shared.authSecret!)
        }
        else {
            signatureKey = String(format:"%@&", FlickrKit.shared.apiSecret)
        }
        var baseString = httpMethod + "&" + FKEscapedURLStringPlus(inURL.absoluteString) + "&"
        let sortedKeys = newArgs.keys.sorted()
        
        var baseStrArgs = [String]()
        for key in sortedKeys {
            baseStrArgs.append(String(format:"%@=%@", key, FKEscapedURLStringPlus(newArgs[key])))
        }
        
        baseString.append(FKEscapedURLStringPlus(baseStrArgs.joined(separator: "&")))
        let signature = FKOFHMACSha1Base64(signatureKey, baseString)
        
        
        
        newArgs["oauth_signature"] = signature
        return newArgs
    }
    
    //MARK:- Create query string from args and sign it
    
    public func signedQueryString(FromParameters params:[String: String]) -> String {
        let signedParams = self.signedArgumentComponents(FromParameters: params)
        var args = [String]()
        for param in signedParams {
            args.append(param.joined(separator: "="))
        }
        return args.joined(separator: "&")
    }
    
    private func signedArgumentComponents(FromParameters params: [String:String]?) -> [[String]] {
        var args = [String:String]()
        if params != nil {
            args = params!
        }
        args["api_key"] = FlickrKit.shared.apiKey
        var argArray:[[String]] = []
        var sigString = (FlickrKit.shared.apiSecret)!
        let sortedKeys = args.keys.sorted()
        
        for key in sortedKeys {
            let value = args[key]!
            sigString.append(String(format: "%@%@", key, value))
            argArray.append([key, value.escapedURLString!])
        }
        let signature = FKMD5FromString(sigString)!
        argArray.append(["api_sig", signature])
        return argArray
    }
    
    //MARK:- Args as array
    
    public func signedArgs(FromParameters params:[String: String], httpMethod method:FlickrHttpMethod, theURL url:URL) -> [String:String] {
        if FlickrKit.shared.isAuthorized {
            return self.signedOAuth(withHTTPQueryParameters: params, baseURL: url, httpMethod: method)
        }
        else {
            var returnDict:[String:String] = [:]
            let signedArgs = self.signedArgumentComponents(FromParameters: params)
            for comp in signedArgs {
                returnDict[comp.first!] = comp[1]
            }
            return returnDict
        }
    }
}
