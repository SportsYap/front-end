//
//  MyCommentTableViewCell.swift
//  SportsYap
//
//  Created by Master on 2020/4/18.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit
import SDWebImage
import Gifu
import Nuke

protocol MyCommentTableViewCellDelegate {
    func didDeleteComment(comment: Comment)
}

class MyCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var videoPlayIcon: UIImageView!
    @IBOutlet weak var gifImageView: GIFImageView!

    var delegate: MyCommentTableViewCellDelegate?
    var comment: Comment? {
        didSet {
            if let comment = comment {
                if comment.text.contains("media.tenor.com/images/") || comment.text.contains(".gif") {
                    commentLabel.alpha = 0
                    gifImageView.alpha = 1
                    addGifImageView(gifUrl: comment.text)
                } else {
                    commentLabel.text = comment.text
                    commentLabel.alpha = 1
                    gifImageView.alpha = 0
                }
                dateLabel.text = comment.createdAt.timeAgoSince()
                if let url = comment.post?.media.photoUrl { // Render Photo
                    postImageView.sd_setImage(with: url)
                    videoPlayIcon.isHidden = true
                } else if let url = comment.post?.media.thumbnailUrl { // Render Video Thumbnail
                    postImageView.sd_setImage(with: url)
                    videoPlayIcon.isHidden = false
                } else {
                    postImageView.sd_cancelCurrentImageLoad()
                    postImageView.image = nil
                    videoPlayIcon.isHidden = true
                }
            }
        }
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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onDelete(_ sender: Any) {
        if let delegate = delegate,
            let comment = comment {
            delegate.didDeleteComment(comment: comment)
        }
    }
}
