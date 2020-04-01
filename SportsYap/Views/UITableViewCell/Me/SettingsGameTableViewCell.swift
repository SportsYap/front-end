//
//  SettingsGameTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/8/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

protocol SettingsGameTableViewCellDelegate {
    func didUnfollowTeam(for team: Team)
    func didFollowTeam(for team: Team)
}

class SettingsGameTableViewCell: UITableViewCell {

    @IBOutlet weak var unfollowButton: UIButton!
    
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var hometownLabel: UILabel!
    
    @IBOutlet weak var secondaryColorView: UIView!
    @IBOutlet weak var primaryColorView: UIView!
    
    var delegate: SettingsGameTableViewCellDelegate!
    var team: Team!
    
    @IBAction func onUnfollow(_ sender: Any) {
        if unfollowButton.titleLabel?.text == "Unfollow" {
            delegate.didUnfollowTeam(for: team)
            unfollowButton.setTitle("Follow", for: .normal)
        } else {
            delegate.didFollowTeam(for: team)
            unfollowButton.setTitle("Unfollow", for: .normal)
        }
    }
}
