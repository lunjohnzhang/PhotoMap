//
//  PostCollectionViewCell.swift
//  PhotoMap
//
//  Created by LunJohnZhang on 2018/12/2.
//  Copyright © 2018 Yulun Zhang. All rights reserved.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {
    // data model
    let data = DataModel.sharedInstance
    
    // IBOutlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var postPic: UIImageView!
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        // note: don't change the width
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}
