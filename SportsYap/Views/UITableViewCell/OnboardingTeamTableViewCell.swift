//
//  OnboardingTeamTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 3/10/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class OnboardingTeamTableViewCell: UITableViewCell {

    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var homeTownLbl: UILabel!
    @IBOutlet weak var followBttn: UIButton!
    
    @IBOutlet var primaryColorView: UIView!
    @IBOutlet var secondaryColorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
