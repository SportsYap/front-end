//
//  ProfilePostTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/9/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

protocol ProfilePostTableViewCellDelegate {
    func didTapOption(post: Post)
    func didFistBump(post: Post)
}

class ProfilePostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var optionButton: UIButton?
    @IBOutlet weak var optionButtonWidth: NSLayoutConstraint?
    
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var videoIconView: UIImageView!
    @IBOutlet weak var postImageViewHeight: NSLayoutConstraint?
    @IBOutlet weak var videoPlayView: UIView?

    @IBOutlet weak var fistsLabel: UILabel?
    @IBOutlet weak var commentsLabel: UILabel!
    
    var post: Post? {
        didSet {
            if let post = post {
                profileImageView.sd_setImage(with: post.user.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))
                usernameLabel.text = post.user.name
                timeLabel.text = post.createdAt.timeAgoSince() + " @ " + (post.game?.venue.name ?? "")
                
                optionButton?.isHidden = (post.user.id != User.me.id)
                optionButtonWidth?.constant = (post.user.id != User.me.id) ? 0 : 50
                
                postLabel.text = post.media.comment
                if let url = post.media.photoUrl { // Render Photo
                    postImageView.sd_setImage(with: url) { (image, _, _, _) in
                        if let image = image {
                            self.postImageViewHeight?.constant = self.postImageView.bounds.size.width / image.size.width * image.size.height
                        }
                    }
                    videoIconView.isHidden = true
                } else if let url = post.media.thumbnailUrl { // Render Video Thumbnail
                    postImageView.sd_setImage(with: url) { (image, _, _, _) in
                        if let image = image {
                            self.postImageViewHeight?.constant = self.postImageView.bounds.size.width / image.size.width * image.size.height
                        }
                    }
                    postImageView.isPinchable = true
                    videoIconView.isHidden = false
                } else {
                    postImageViewHeight?.constant = 0

                    postImageView.sd_cancelCurrentImageLoad()
                    postImageView.image = nil
                    videoIconView.isHidden = true
                }

                fistsLabel?.text = "\(post.likeCnt)"
                commentsLabel.text = "\(post.commentsCount)"
            }
        }
    }
    var delegate: ProfilePostTableViewCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.sd_cancelCurrentImageLoad()
        profileImageView.image = nil
        
        postImageView.sd_cancelCurrentImageLoad()
        postImageView.image = nil
        
        postImageViewHeight?.constant = postImageView.bounds.size.width / 317 * 238
    }
    
    @IBAction func onOption(_ sender: Any) {
        if let delegate = delegate,
            let post = post {
            delegate.didTapOption(post: post)
        }
    }
    
    @IBAction func onFistBump(_ sender: Any) {
        if let delegate = delegate,
            let post = post {
            delegate.didFistBump(post: post)
        }
    }
}
