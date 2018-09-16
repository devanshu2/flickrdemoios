//
//  ImageDownloadOperation.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 15/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import UIKit

public typealias OperationResultHandler = (_ imageData: Data?, _ error: Error?) -> Void

class ImageDownloadOperation: AsynchronousOperation {
    private var imageURL: URL!
    private var resultHandler: OperationResultHandler?
    private var networkTask: URLSessionDataTask?
    
    init(imageURL: URL, resultHandler: OperationResultHandler?) {
        super.init()
        self.name = imageURL.absoluteString
        self.imageURL = imageURL
        self.resultHandler = resultHandler
    }
    
    override public func start() {
        if isCancelled {
            state = .finished
            return
        }
        state = .executing
        self.downloadData(url: self.imageURL) { data, response, error in
            if self.isCancelled {
                self.state = .finished
                return
            }
            if let error = error {
                debugPrint(error.localizedDescription)
                self.resultHandler?(nil, error)
            }
            else {
                self.resultHandler?(data, error)
            }
            self.state = .finished
        }
    }
    
    private func downloadData(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        self.networkTask = URLSession(configuration: .ephemeral).dataTask(with: URLRequest(url: url)) { data, response, error in
            completion(data, response, error)
            }
        self.networkTask?.resume()
    }
    
    override public func cancel() {
        super.cancel()
        self.networkTask?.cancel()
    }
}
