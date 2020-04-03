//
//  CommentTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/25/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    var comment: Comment? {
        didSet {
            if let comment = comment {
                timeAgoLabel.text = comment.createdAt.timeAgoSince()
                profileImageView.sd_setImage(with: comment.user.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))
                usernameLabel.text = comment.user.name
                
                commentLabel.attributedText = NSMutableAttributedString().bold(comment.user.name).normal(" \(comment.text)")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
