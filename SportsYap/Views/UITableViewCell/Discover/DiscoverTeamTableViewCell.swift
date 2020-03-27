//
//  DiscoverTeamTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 3/19/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class DiscoverTeamTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hometownLabel: UILabel!
    
    @IBOutlet weak var secondaryColorView: UIView!
    @IBOutlet weak var primaryColorView: UIView!
    
    @IBOutlet weak var followButton: UIButton!
    
    var team: Team? {
        didSet {
            if let team = team {
                nameLabel.text = team.name
                hometownLabel.text = "\(team.homeTown) | \(team.sport.abv)"
                primaryColorView.backgroundColor = team.primaryColor
                secondaryColorView.backgroundColor = team.secondaryColor
                followButton.setTitle(NSLocalizedString(team.followed ? "Follow" : "Unfollow", comment: ""), for: .normal)
            }
        }
    }
    var delegate: DiscoverSearchTableViewCellDelegate?
    
    @IBAction func onFollow(_ sender: Any) {
        if let team = team {
            delegate?.onFollowTeam(team: team, cell: self)
        }
    }
}
