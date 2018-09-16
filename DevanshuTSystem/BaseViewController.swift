//
//  BaseViewController.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 16/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import UIKit
import SVProgressHUD
import Toast

class BaseViewController: UIViewController {
    
    public lazy var doneToolbar = UIToolbar()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    public func configureDefaultDoneToolBar() {
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.toolBarDoneAction(_:)))
        self.doneToolbar.items = [flex, doneButton]
        self.doneToolbar.backgroundColor = .white
        self.doneToolbar.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0)
    }
    
    @objc public func toolBarDoneAction(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    public func showToast(_ message:String, Completion completionHandler: (() -> Swift.Void)? = nil) {
        DispatchQueue.main.async {
            self.view.makeToast(message, duration: 3.0, position: CSToastPositionBottom)
        }
    }
    
    public func showLoader() {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
    }
    
    public func hideLoader() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }

}
