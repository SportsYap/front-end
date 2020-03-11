//
//  DiscoverUserTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 3/19/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class DiscoverUserTableViewCell: UITableViewCell {

    @IBOutlet var isVerifiedImageView: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var hometownLbl: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet var followBttn: UIButton!
    
    var user: User!{
        didSet{
            setFollowBttnTitle(following: user.followed)
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
        delegate.followBttnPressed(user: user)
        user.followed = !user.followed
        setFollowBttnTitle(following: user.followed)
    }
    

}
