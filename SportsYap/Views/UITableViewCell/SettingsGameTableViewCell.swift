//
//  SettingsGameTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/8/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

protocol SettingsGameTableViewCellDelegate {
    func unfollowBttnPressed(for team: Team)
    func followBttnPressed(for team: Team)
}

class SettingsGameTableViewCell: UITableViewCell {

    @IBOutlet var unfollowBttn: UIButton!
    
    @IBOutlet var teamNameLbl: UILabel!
    @IBOutlet var hometownLbl: UILabel!
    
    @IBOutlet var secondaryColorView: UIView!
    @IBOutlet var primaryColorView: UIView!
    
    var delegate: SettingsGameTableViewCellDelegate!
    var team: Team!
    
    @IBAction func unfollowBttnPressed(_ sender: Any) {
        if unfollowBttn.titleLabel?.text == "Unfollow"{
            delegate.unfollowBttnPressed(for: team)
            unfollowBttn.setTitle("Follow", for: .normal)
        }else{
            delegate.followBttnPressed(for: team)
            unfollowBttn.setTitle("Unfollow", for: .normal)
        }
    }
    
}
