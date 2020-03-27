//
//  DiscoverSuggestionTableViewCell.swift
//  SportsYap
//
//  Created by Master on 2020/3/27.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit

class DiscoverSuggestionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var object: DBObject? {
        didSet {
            if let user = object as? User {
                iconView.image = UIImage(named: "trending_user")
                nameLabel.text = user.name
                followButton.setTitle(NSLocalizedString(user.followed ? "Follow" : "Unfollow", comment: ""), for: .normal)
            } else if let team = object as? Team {
                switch team.sport {
                case .baseball:
                    iconView.image = UIImage(named: "trending_baseball")
                case .basketball:
                    iconView.image = UIImage(named: "trending_bball")
                case .collegeBasketball:
                    iconView.image = UIImage(named: "trending_college_basketball")
                case .collegeFootball:
                    iconView.image = UIImage(named: "trending_college_football")
                case .football:
                    iconView.image = UIImage(named: "trending_football")
                case .hockey:
                    iconView.image = UIImage(named: "trending_puck")
                case .soccer:
                    iconView.image = UIImage(named: "trending_soccer")
                }
                nameLabel.text = team.name
                followButton.setTitle(NSLocalizedString(team.followed ? "Follow" : "Unfollow", comment: ""), for: .normal)
            }
        }
    }
    
    var delegate: DiscoverSearchTableViewCellDelegate?
    
    @IBAction func onFollow(_ sender: Any) {
        if let user = object as? User {
            delegate?.onFollowUser(user: user, cell: self)
        } else if let team = object as? Team {
            delegate?.onFollowTeam(team: team, cell: self)
        }
    }
}
