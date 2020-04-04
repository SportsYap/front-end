//
//  UserTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/22/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate {
    func didFollowUser(user: User)
}

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var isVerifiedImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hometownLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    var user: User! {
        didSet {
            nameLabel.text = user.name
            hometownLabel.text = user.location
            isVerifiedImageView.alpha = user.verified ? 1 : 0
            profileImageView.sd_setImage(with: user.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))

            if user.id == User.me.id {
                followButton.isHidden = true
            } else {
                followButton.isHidden = false
                followButton.setTitle(user.followed ? "Unfollow" : "+ Follow", for: .normal)
            }
        }
    }
    var delegate: UserTableViewCellDelegate!
}

extension UserTableViewCell {
    //MARK: IBAction
    @IBAction func onFollow(_ sender: Any) {
        delegate.didFollowUser(user: user)
    }
}
