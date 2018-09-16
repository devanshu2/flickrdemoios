//
//  NetworkManger.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 16/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import Foundation

class NetworkManger: NSObject {
    
    public var networkSession: URLSession?
    public var isIncognito = false
    public func getSharedConfiguration(_ isEphemeral: Bool) -> URLSessionConfiguration {
        let sessionConfiguration = isEphemeral ? URLSessionConfiguration.ephemeral : URLSessionConfiguration.default
        return sessionConfiguration
    }
    
    static func getURLStringForGetRequest(withApiEndPoint endPoint:String, params theParams:[String:String]?) -> String {
        var apiEndPoint = endPoint
        if let param = theParams {
            var pa:[String] = []
            for (key, value) in param {
                pa.append(key + "=" + value)
            }
            apiEndPoint = apiEndPoint + "?" + pa.joined(separator: "&")
        }
        return apiEndPoint.urlQueryString()!
    }
    
    public static func getDefaultHeaders() -> [String:String] {
        var headerParams: Dictionary<String, String>
        headerParams = ["Content-Type": "application/json; charset=UTF-8"]
        return headerParams
    }
    
    public func postData(withParameters params:[String: Any], apiEndpoint apiURL: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask? {
        return self.makeServerRequest(reqyestType: String.kPost, withParameters: params, apiEndpoint: apiURL, completionHandler: completionHandler)
    }
    
    public func putData(withParameters params:[String: Any], apiEndpoint apiURL: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask? {
        return self.makeServerRequest(reqyestType: String.kPut, withParameters: params, apiEndpoint: apiURL, completionHandler: completionHandler)
    }
    
    public func getData(withApiEndpoint apiURL: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask? {
        return self.makeServerRequest(reqyestType: String.kGet, withParameters: nil, apiEndpoint: apiURL, completionHandler: completionHandler)
    }
    
    public func makeServerRequest(reqyestType rType:String, withParameters params:[String: Any]? = nil, apiEndpoint apiURL: String,  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask? {
        var jsonData:Data?
        if params != nil {
            do {
                jsonData = try JSONSerialization.data(withJSONObject: params!, options: [])
            }
            catch {
                debugPrint(error.localizedDescription)
            }
        }
        return self.makeServerRequest(reqyestType: rType, withHTTPBodyData: jsonData, apiEndpoint: apiURL, completionHandler: completionHandler)
    }
    
    public func makeServerRequest(reqyestType rType:String, withHTTPBodyData data:Data? = nil, apiEndpoint apiURL: String, httpHeaders headers:[String:String] = NetworkManger.getDefaultHeaders(),  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask? {
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = rType
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = data
        debugPrint("Making \(rType) request with endpoint: \(apiURL)")
        return self.makeServerRequest(request, completionHandler: completionHandler)
    }
    
    public func makePostServerRequestWithBody(_ body: Data, ContentType contentType: String,  apiEndpoint apiURL: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask? {
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = String.kPost
        for (key, value) in NetworkManger.getDefaultHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        debugPrint("Making POST request with endpoint: \(apiURL)")
        return self.makeServerRequest(request, completionHandler: completionHandler)
    }
    
    public func makeServerRequest(_ request:URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask? {
        if self.networkSession == nil {
            self.networkSession = URLSession(configuration: getSharedConfiguration(self.isIncognito))
        }
        let dataTask = self.networkSession?.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 500 || httpResponse.statusCode == 404 {
                    let msg = (request.url?.absoluteString ?? "") + " \(httpResponse.statusCode) httpstatus"
                    debugPrint(msg)
                }
            }
            if error != nil {
                debugPrint(error!.localizedDescription)
            }
            completionHandler(data, response, error)
        }
        dataTask?.resume()
        return dataTask
    }
}
