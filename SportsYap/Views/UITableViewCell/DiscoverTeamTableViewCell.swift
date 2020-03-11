//
//  DiscoverTeamTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 3/19/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class DiscoverTeamTableViewCell: UITableViewCell {

    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var hometownLbl: UILabel!
    
    @IBOutlet var secondaryColor: UIView!
    @IBOutlet var primaryColor: UIView!
    
    @IBOutlet var followBttn: UIButton!
    
    var team: Team!{
        didSet{
            setFollowBttnTitle(following: team.followed)
        }
    }
    var delegate: DiscoverTableViewCellDelegate!
    
    func setFollowBttnTitle(following: Bool){
        if following{
            followBttn.setTitle("Unfollow", for: .normal)
        }else{
            followBttn.setTitle("Follow", for: .normal)
        }
    }
    
    //MARK: IBAction
    @IBAction func followBttnPressed(_ sender: Any) {
        delegate.followBttnPressed(team: team)
        team.followed = !team.followed
        setFollowBttnTitle(following: team.followed)
    }

}
