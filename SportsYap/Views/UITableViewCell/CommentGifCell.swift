//
//  CommentGifCell.swift
//  SportsYap
//
//  Created by Solomon W on 9/3/19.
//  Copyright © 2019 Alex Pelletier. All rights reserved.
//

import UIKit
import Gifu
import Nuke

class CommentGifCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    @IBOutlet weak var gifImageView: GIFImageView!
    
    var comment: Comment? {
        didSet {
            if let comment = comment {
                timeAgoLabel.text = comment.createdAt.timeAgoSince()
                profileImageView.sd_setImage(with: comment.user.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))
                
                addGifImageView(gifUrl: comment.text)
                usernameLabel.attributedText = NSMutableAttributedString().bold(comment.user.name)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func addGifImageView(gifUrl: String) {
        if gifUrl.contains("media.tenor.com/images/") {
            if let url = URL(string: gifUrl) {
                
                let imageOptions = ImageLoadingOptions(placeholder: nil, transition: .fadeIn(duration: 0.33), failureImage: nil, failureImageTransition: nil, contentModes: nil)
                
                ImagePipeline.Configuration.isAnimatedImageDataEnabled = true
                
                Nuke.loadImage(
                    with: url,
                    options: imageOptions,
                    into: gifImageView,
                    completion: { [weak self] _ in }
                )
            }
            
        } else {
            let splitUrl = gifUrl.split(separator: "/").last
            
            if let gifName = splitUrl?.split(separator: ".").first?.description {
                let url = URL(fileURLWithPath: Bundle.main.path(forResource: gifName, ofType: ".gif")!)
                
                let imageOptions = ImageLoadingOptions(placeholder: nil, transition: .fadeIn(duration: 0.33), failureImage: nil, failureImageTransition: nil, contentModes: nil)
                
                ImagePipeline.Configuration.isAnimatedImageDataEnabled = true
                
                Nuke.loadImage(
                    with: url,
                    options: imageOptions,
                    into: gifImageView,
                    completion: { [weak self] _ in }
                )
            }
        }
    }
    
}
