//
//  ImageCollectionViewCell.swift
//  DevanshuTSystem
//
//  Created by Devanshu Saini on 17/09/18.
//  Copyright © 2018 Devanshu Saini. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: CustomImageView!
    @IBOutlet weak var imageViewWrapper: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageViewWrapper.layer.borderColor = UIColor.gray.cgColor
        self.imageViewWrapper.layer.borderWidth = 1.0
    }

}
