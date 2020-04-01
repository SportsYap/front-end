//
//  DiscoverUserTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 3/19/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class DiscoverUserTableViewCell: UITableViewCell {

    @IBOutlet weak var isVerifiedImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hometownLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var followButton: UIButton!
    
    var user: User! {
        didSet {
            if let user = user {
                nameLabel.text = user.name
                hometownLabel.text = user.location
                isVerifiedImageView.alpha = user.verified ? 1 : 0
                profileImageView.sd_setImage(with: user.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))
                followButton.setTitle(NSLocalizedString(user.followed ? "Unfollow" : "Follow", comment: ""), for: .normal)
            }
        }
    }
    
    var delegate: DiscoverSearchTableViewCellDelegate?
    
    @IBAction func onFollow(_ sender: Any) {
        if let user = user {
            delegate?.onFollowUser(user: user, cell: self)
        }
    }
}
