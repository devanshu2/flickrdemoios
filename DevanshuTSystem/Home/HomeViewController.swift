//
//  ViewController.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 15/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import UIKit


class HomeViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var userId: String?
    private var pageNumer = 1
    private var gridState = GridState.dual
    private lazy var searchBar = UISearchBar()
    private var isPhotoFetchCall = false
    private var lastDataTask: URLSessionDataTask?
    
    private lazy var collectionModal = HomeCollectionModal()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Home"
        self.navigationItem.titleView = self.searchBar
        self.updateGridbutton()
        self.refreshData(with: true, PageNumber: 1)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionModal.calculateCellDimensions(size.width)
        self.collectionView.reloadData()
    }
    
    private func initViewController() {
        self.checkAuthentication()
        self.userLoggedOut()
        self.configureDefaultDoneToolBar()
        self.searchBar.inputAccessoryView = self.doneToolbar
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search"
        self.collectionModal.delegate = self
        self.collectionModal.calculateCellDimensions(self.view.bounds.size.width)
        self.collectionView.register(UINib(nibName: Constants.CellIdentifier.ImageCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: Constants.CellIdentifier.ImageCollectionViewCell)
        self.collectionView.delegate = self.collectionModal
        self.collectionView.dataSource = self.collectionModal
        self.activityIndicator.isHidden = true
    }
    
    private func updateGridbutton(_ animation:Bool = false) {
        let rightBarButtonItem = UIBarButtonItem(image: self.gridState.getImage(), style: .plain, target: self, action: #selector(self.gridButtonAction(_:)))
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
    }
    
    override func toolBarDoneAction(_ sender: Any) {
        self.searchBar.resignFirstResponder()
        self.refreshData(with: true, PageNumber: 1)
    }
    
    @objc private func gridButtonAction(_ sender: Any?) {
        let actionSheet = UIAlertController(title: "Choose Grid Type", message: "", preferredStyle: .actionSheet)
        let duaAction = UIAlertAction(title: "Two In A Row", style: .default) { (action) in
            self.gridState = .dual
            self.updateGridbutton()
            self.collectionModal.calculateCellDimensions(self.view.bounds.size.width)
            self.collectionView.reloadData()
        }
        
        let tripleAction = UIAlertAction(title: "Three In A Row", style: .default) { (action) in
            self.gridState = .triple
            self.updateGridbutton()
            self.collectionModal.calculateCellDimensions(self.view.bounds.size.width)
            self.collectionView.reloadData()
        }
        
        let quadAction = UIAlertAction(title: "Four In A Row", style: .default) { (action) in
            self.gridState = .quad
            self.updateGridbutton()
            self.collectionModal.calculateCellDimensions(self.view.bounds.size.width)
            self.collectionView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if self.gridState == .dual {
            actionSheet.addAction(tripleAction)
            actionSheet.addAction(quadAction)
        }
        else if self.gridState == .triple {
            actionSheet.addAction(duaAction)
            actionSheet.addAction(quadAction)
        }
        else {
            actionSheet.addAction(duaAction)
            actionSheet.addAction(tripleAction)
        }
        actionSheet.addAction(cancelAction)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc private func userAuthCallback(_ notification:Notification) {
        if let callBackURL = notification.userInfo?[String.kCallBackURL] as? URL {
            self.showLoader()
            FlickrKit.shared.completeAuth(with: callBackURL, andCompletion: { [weak self] (userName, userId, fullName, error) in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.hideLoader()
                    if userId != nil {
                        self.userLoggedIn(userName!, userID: userId!)
                    }
                    else {
                        self.showToast(error?.localizedDescription ?? "Please try later")
                    }
                    _ = self.navigationController?.popToRootViewController(animated: true)
                }
            })
        }
    }
    
    private func checkAuthentication() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.userAuthCallback(_:)), name: Constants.Notifications.UserAuthCallbackNotification, object: nil)
        self.showLoader()
        FlickrKit.shared.checkAuthorization { [weak self] (userName, userId, fullName, error) -> Void in
            guard let `self` = self else { return }
            self.hideLoader()
            DispatchQueue.main.async {
                if (userId != nil) {
                    self.userLoggedIn(userName!, userID: userId!)
                } else {
                    self.userLoggedOut()
                }
            }
        }
    }
    
    private func refreshData(with loader:Bool, PageNumber page:Int) {
        if page == 1 {
            self.isPhotoFetchCall = false
            self.lastDataTask?.cancel()
            self.activityIndicator.isHidden = true
        }
        if self.isPhotoFetchCall {
            return
        }
        if loader {
            self.showLoader()
        }
        self.isPhotoFetchCall = true
        self.lastDataTask = FlickrKit.shared.fetchPhotos(self.userId, SearchText: self.searchBar.text, PageNumber: page) { [weak self] (response, error) in
            guard let `self` = self else { return }
            self.hideLoader()
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
            }
            if response?.stat == .fail, let message = response?.message {
                self.collectionModal.photos.removeAll()
                DispatchQueue.main.async {
                    let offset = CGPoint(x: -self.collectionView.adjustedContentInset.left,
                                         y: -self.collectionView.adjustedContentInset.top)
                    self.collectionView.setContentOffset(offset, animated: true)
                    self.collectionView.reloadData()
                }
                if let errorCode = response?.code, errorCode == 3 {
                    // Parameterless searches have been disabled. Please use flickr.photos.getRecent instead.
                }
                else {
                    DispatchQueue.main.async {
                        self.showToast(message)
                    }
                }
            }
            else {
                if let items = response?.photoResponse?.photos, items.count > 0 {
                    self.pageNumer = (response?.photoResponse?.page)!
                    if page == 1 {
                        self.collectionModal.photos.removeAll()
                        self.collectionModal.photos = items
                        DispatchQueue.main.async {
                            let offset = CGPoint(x: -self.collectionView.adjustedContentInset.left,
                                                 y: -self.collectionView.adjustedContentInset.top)
                            self.collectionView.setContentOffset(offset, animated: true)
                            self.collectionView.reloadData()
                        }
                    }
                    else {
                        let oldCount = self.collectionModal.photos.count
                        self.collectionModal.photos.append(contentsOf: items)
                        let newCount = self.collectionModal.photos.count
                        var indexPaths = [IndexPath]()
                        for i in oldCount..<newCount {
                            indexPaths.append(IndexPath(item: i, section: 0))
                        }
                        DispatchQueue.main.async {
                            self.collectionView.performBatchUpdates({
                                self.collectionView.insertItems(at: indexPaths)
                            }, completion: nil)
                        }
                    }
                    
                }
            }
            self.isPhotoFetchCall = false
        }
    }
    
    private func userLoggedIn(_ userName: String, userID: String) {
        self.userId = userID
        self.authButton.setTitle("Logout", for: UIControlState())
        self.authLabel.text = "You are logged in as \(userName)"
    }
    
    private func userLoggedOut() {
        self.authButton.setTitle("Login", for: UIControlState())
        self.authLabel.text = "Login to flickr"
        self.userId = nil
    }
    
    @IBAction func authButtonPressed(_ sender: AnyObject) {
        if(FlickrKit.shared.isAuthorized) {
            FlickrKit.shared.logout()
            self.userLoggedOut()
            self.refreshData(with: true, PageNumber: 1)
        } else {
            FlickrKit.shared.logout()
            self.performSegue(withIdentifier: Constants.Segue.HomeToAuth, sender: self)
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.refreshData(with: true, PageNumber: 1)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationItem.setRightBarButton(nil, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.updateGridbutton()
    }
}

extension HomeViewController: HomeCollectionModalDelegate {
    func getGridState() -> GridState {
        return self.gridState
    }
    
    func getActivityIndicator() -> UIActivityIndicatorView {
        return self.activityIndicator
    }
    
    func getPageNumber() -> Int {
        return self.pageNumer
    }
    
    func refreshDataCall(with loader:Bool, PageNumber page:Int) {
        self.refreshData(with: loader, PageNumber: page)
    }
}
