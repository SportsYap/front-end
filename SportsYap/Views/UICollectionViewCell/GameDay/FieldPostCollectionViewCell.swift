//
//  FieldPostCollectionViewCell.swift
//  SportsYap
//
//  Created by Master on 2020/3/24.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit
import SDWebImage

class FieldPostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playIconView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var teamImageView: UIImageView!
    
    var post: Post? {
        didSet {
            if let post = post {
                if let url = post.media.photoUrl {
                    imageView.sd_setImage(with: url)
                    playIconView.isHidden = true
                } else {
                    imageView.sd_setImage(with: post.media.thumbnailUrl)
                    playIconView.isHidden = false
                }
                
                userImageView.sd_setImage(with: post.user.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))
                if post.teamId == post.game?.homeTeam.id {
                    teamImageView.image = UIImage(named: "team_color_home")
                } else {
                    teamImageView.image = UIImage(named: "team_color_away")
                }
            }
        }
    }
}
