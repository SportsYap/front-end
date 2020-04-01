//
//  OnboardingTeamTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 3/10/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class OnboardingTeamTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var homeTownLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var primaryColorView: UIView!
    @IBOutlet weak var secondaryColorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
