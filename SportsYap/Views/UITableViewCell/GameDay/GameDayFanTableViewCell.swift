//
//  GameDayFanTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/22/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class GameDayFanTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var teamNameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var isVerifiedImageView: UIImageView!
    @IBOutlet var profileImageView: UIImageView!

    var game: Game?
    var fan: User? {
        didSet {
            if let user = fan {
                nameLabel.text = user.name
                isVerifiedImageView.alpha = user.verified ? 1 : 0
                if let url = user.profileImage {
                    profileImageView.imageFromUrl(url: url)
                } else {
                    profileImageView.image = #imageLiteral(resourceName: "default-profile")
                }
                
                if user.pivot?.itemAId == game?.awayTeam.id {
                    teamNameLabel.text = game?.awayTeam.name
                } else if user.pivot?.itemAId == game?.homeTeam.id {
                    teamNameLabel.text = game?.homeTeam.name
                } else {
                    teamNameLabel.text = ""
                }
                
                if let date = user.pivot?.createdAt {
                    timeLabel.text = date.timeAgoSince()
                } else {
                    timeLabel.text = ""
                }
            }
        }
    }
}
