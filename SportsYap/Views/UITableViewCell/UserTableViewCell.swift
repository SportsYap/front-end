//
//  UserTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/22/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate {
    func followBttnPressed(user: User)
}

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet var isVerifiedImageView: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var hometownLbl: UILabel!
    
    @IBOutlet var followBttn: UIButton!
    
    var user: User!{
        didSet{
            setFollowBttnTitle(following: user.followed)
        }
    }
    var delegate: UserTableViewCellDelegate!
    
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
