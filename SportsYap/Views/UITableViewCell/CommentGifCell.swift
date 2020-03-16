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
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var isVerifiedImageView: UIImageView!
    @IBOutlet var textLbl: UILabel!
    @IBOutlet var timeAgoLbl: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var gifImageView: GIFImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func addGifImageView(gifUrl: String) {
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
