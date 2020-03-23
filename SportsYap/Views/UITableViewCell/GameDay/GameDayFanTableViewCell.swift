//
//  GameDayFanTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/22/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import SDWebImage

class GameDayFanTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var isVerifiedImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var teamImageView: UIImageView!

    var game: Game?
    var fan: User? {
        didSet {
            if let user = fan {
                nameLabel.text = user.name
                isVerifiedImageView.alpha = user.verified ? 1 : 0
                profileImageView.sd_setImage(with: user.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))
                
                if user.pivot?.itemAId == game?.awayTeam.id {
                    teamImageView.image = UIImage(named: "team_color_away")
                } else if user.pivot?.itemAId == game?.homeTeam.id {
                    teamImageView.image = UIImage(named: "team_color_home")
                } else {
                    teamImageView.image = nil
                }
                
                if let date = user.pivot?.createdAt {
                    timeLabel.text = date.timeAgoSince()
                } else {
                    timeLabel.text = ""
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.sd_cancelCurrentImageLoad()
        profileImageView.image = nil
    }
}
