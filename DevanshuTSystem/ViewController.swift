//
//  ViewController.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 15/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import UIKit

enum GridState: Int {
    case dual = 2
    case triple = 3
    case quad = 4
    
    func getImage() -> UIImage {
        switch self {
        case .dual:
            return #imageLiteral(resourceName: "grid-2")
        case .triple:
            return #imageLiteral(resourceName: "grid-3")
        default:
            return #imageLiteral(resourceName: "grid-4")
        }
    }
}

class ViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var userId: String?
    private var pageNumer = 1
    private var gridState = GridState.dual
    private lazy var searchBar = UISearchBar()
    private var isPhotoFetchCall = false
    private var photos:[FlickrPhoto] = []
    private var cellEdge: CGFloat = 0.0
    private var padding: CGFloat = 0.0
    private var lastDataTask: URLSessionDataTask?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkAuthentication()
        self.userLoggedOut()
        self.configureDefaultDoneToolBar()
        self.searchBar.inputAccessoryView = self.doneToolbar
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search"
        self.calculateCellDimensions(self.view.bounds.size.width)
        self.collectionView.register(UINib(nibName: Constants.CellIdentifier.ImageCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: Constants.CellIdentifier.ImageCollectionViewCell)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.activityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Home"
        self.navigationItem.titleView = self.searchBar
        self.updateGridbutton()
        self.refreshData(with: true, PageNumber: 1)
    }
    
    private func updateGridbutton(_ animation:Bool = false) {
        let rightBarButtonItem = UIBarButtonItem(image: self.gridState.getImage(), style: .plain, target: self, action: #selector(self.gridButtonAction(_:)))
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
    }
    
    private func calculateCellDimensions(_ collectionWidth:CGFloat) {
        let totalFillSpace = self.gridState.rawValue + 1
        let blankSpace = collectionWidth - CGFloat( 10.0 * Double(totalFillSpace) )
        let cellWidth = blankSpace/CGFloat(self.gridState.rawValue)
        self.cellEdge = cellWidth
        self.padding = (collectionWidth - ((cellWidth * CGFloat(self.gridState.rawValue)) + (CGFloat(10.0) * CGFloat(self.gridState.rawValue - 1))))/CGFloat(2) //more precise value
        debugPrint("done")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.calculateCellDimensions(size.width)
        self.collectionView.reloadData()
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
            self.calculateCellDimensions(self.view.bounds.size.width)
            self.collectionView.reloadData()
        }
        
        let tripleAction = UIAlertAction(title: "Three In A Row", style: .default) { (action) in
            self.gridState = .triple
            self.updateGridbutton()
            self.calculateCellDimensions(self.view.bounds.size.width)
            self.collectionView.reloadData()
        }
        
        let quadAction = UIAlertAction(title: "Four In A Row", style: .default) { (action) in
            self.gridState = .quad
            self.updateGridbutton()
            self.calculateCellDimensions(self.view.bounds.size.width)
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
                self.photos.removeAll()
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
                        self.photos.removeAll()
                        self.photos = items
                        DispatchQueue.main.async {
                            let offset = CGPoint(x: -self.collectionView.adjustedContentInset.left,
                                                 y: -self.collectionView.adjustedContentInset.top)
                            self.collectionView.setContentOffset(offset, animated: true)
                            self.collectionView.reloadData()
                        }
                    }
                    else {
                        let oldCount = self.photos.count
                        self.photos.append(contentsOf: items)
                        let newCount = self.photos.count
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
        } else {
            FlickrKit.shared.logout()
            self.performSegue(withIdentifier: Constants.Segue.HomeToAuth, sender: self)
        }
    }
}

extension ViewController: UISearchBarDelegate {
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


// MARK: - UICollectionViewDelegateFlowLayout Method
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.item + 1) == self.photos.count {
            let newPage = self.pageNumer + 1
            self.refreshData(with: false, PageNumber: newPage)
            self.activityIndicator.isHidden = false
        }
        let photo = self.photos[indexPath.item]
        let url = FlickrKit.shared.photoURL(ForSize: .small320, fromPhoto: photo)
        ImageDownloader.shared.getImage(url: url)
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        var items:Set<String> = Set()
        for ip in visibleIndexPaths {
            let photoIP = self.photos[ip.item]
            let urlIP = FlickrKit.shared.photoURL(ForSize: .small320, fromPhoto: photoIP)
            items.insert(urlIP.absoluteString)
        }
        ImageDownloader.shared.setHighPriorityForURLS(items)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cellEdge, height: self.cellEdge)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
}

// MARK: - UICollectionViewDataSource Method
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifier.ImageCollectionViewCell, for: indexPath) as! ImageCollectionViewCell
        let photo = self.photos[indexPath.item]
        let url = FlickrKit.shared.photoURL(ForSize: .small320, fromPhoto: photo)
        cell.imageView.setImage(with: url, placeHolder: #imageLiteral(resourceName: "gen-image"))
        return cell
    }
}
