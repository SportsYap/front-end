//
//  LiveUserCollectionViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 6/6/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import SDWebImage

class LiveUserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var verifiedImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var user: User? {
        didSet {
            if let user = user {
                profileImageView.sd_setImage(with: user.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))
                verifiedImageView.alpha = user.verified ? 1 : 0
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.sd_cancelCurrentImageLoad()
        profileImageView.image = nil
    }
}
