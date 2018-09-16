//
//  FlickrAuthViewController.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 16/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import UIKit
import WebKit

class FlickrAuthViewController: BaseViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView:UIProgressView!
    private var myContext = 0
    
    deinit {
        self.removeWebObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.navigationDelegate = self
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: &self.myContext)
        self.progressView.isHidden = true
        self.title = "User Authentication"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // This must be defined in your Info.plist
        // See FlickrKitDemo-Info.plist
        // Flickr will call this back. Ensure you configure your flickr app as a web app
        let callbackURLString = "devanshuTSystemFlickr://auth"
        
        // Begin the authentication process
        let url = URL(string: callbackURLString)
        self.showLoader()
        FlickrKit.shared.beginAuth(withCallbackURL: url!) { [weak self] (url, error) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.hideLoader()
                if let url = url {
                    let request = URLRequest(url: url)
                    self.webView.load(request)
                }
                else {
                    let message = error?.localizedDescription ?? "Please try later"
                    self.showToast(message)
                }
            }
        }
    }

    private func removeWebObservers() {
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress", context: &self.myContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let change = change else { return }
        if context != &myContext {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == "estimatedProgress" {
            if let progress = (change[NSKeyValueChangeKey.newKey] as AnyObject).floatValue {
                self.progressView.progress = progress
            }
        }
    }
}

extension FlickrAuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if !(url.scheme == "http" || url.scheme == "https") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.becomeFirstResponder()
        self.progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.progressView.isHidden = false
    }
}
