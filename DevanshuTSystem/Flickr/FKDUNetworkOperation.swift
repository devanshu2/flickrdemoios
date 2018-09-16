//
//  FKDUNetworkOperation.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 16/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import UIKit

public typealias FKDUNetworkCompletion = (_ response: URLResponse?, _ data:Data?,  _ error: Error?) -> Void

class FKDUNetworkOperation: AsynchronousOperation {
    public private(set) var httpConnection: NSURLConnection!
    public private(set) var receivedData: Data!
    public private(set) var request: URLRequest!
    public private(set) var response: HTTPURLResponse!
    private var url:URL!
    private var completion:FKDUNetworkCompletion!
    
    init(url:URL) {
        super.init()
        self.url = url
    }
    
    override func cancel() {
        self.httpConnection.cancel()
        self.completion = nil
        super.cancel()
    }
    
    
    
    public func sendAsyncRequest(OnCompletion completion:FKDUNetworkCompletion) {
        
    }
    
    public func connect(with request:URLRequest) {
        
    }
}
