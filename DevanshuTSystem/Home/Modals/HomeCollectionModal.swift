//
//  HomeCollectionModal.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 17/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import UIKit

protocol HomeCollectionModalDelegate: NSObjectProtocol {
    func getGridState() -> GridState
    func getActivityIndicator() -> UIActivityIndicatorView
    func getPageNumber() -> Int
    func refreshDataCall(with loader:Bool, PageNumber page:Int)
}

class HomeCollectionModal: NSObject {
    public var photos:[FlickrPhoto] = []
    private var cellEdge: CGFloat = 0.0
    private var padding: CGFloat = 0.0
    
    public weak var delegate:HomeCollectionModalDelegate!
    
    public func calculateCellDimensions(_ collectionWidth:CGFloat) {
        let totalFillSpace = self.delegate.getGridState().rawValue + 1
        let blankSpace = collectionWidth - CGFloat( 10.0 * Double(totalFillSpace) )
        let cellWidth = blankSpace/CGFloat(self.delegate.getGridState().rawValue)
        self.cellEdge = cellWidth
        self.padding = (collectionWidth - ((cellWidth * CGFloat(self.delegate.getGridState().rawValue)) + (CGFloat(10.0) * CGFloat(self.delegate.getGridState().rawValue - 1))))/CGFloat(2) //more precise value
        debugPrint("done")
    }
}


// MARK: - UICollectionViewDelegateFlowLayout Method
extension HomeCollectionModal: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.item + 1) == self.photos.count {
            let newPage = self.delegate.getPageNumber() + 1
            self.delegate.refreshDataCall(with: false, PageNumber: newPage)
            self.delegate.getActivityIndicator().isHidden = false
        }
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        var items:Set<String> = Set()
        for ip in visibleIndexPaths {
            let photoIP = self.photos[ip.item]
            let urlIP = FlickrKit.shared.photoURL(ForSize: .small320, fromPhoto: photoIP)
            items.insert(urlIP.absoluteString)
        }
        ImageDownloader.shared.setHighPriorityForURLS(items)
        
        let photo = self.photos[indexPath.item]
        let url = FlickrKit.shared.photoURL(ForSize: .small320, fromPhoto: photo)
        ImageDownloader.shared.getImage(url: url)
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
extension HomeCollectionModal: UICollectionViewDataSource {
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
