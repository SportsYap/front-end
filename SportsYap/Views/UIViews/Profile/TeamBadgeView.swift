//
//  TeamBadgeView.swift
//  SportsYap
//
//  Created by Master on 2020/3/29.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit

class TeamBadgeView: UIView {

    @IBOutlet weak var teamNameLabel: UILabel!
    
    @IBOutlet weak var teamPrimaryColorView: UIView!
    @IBOutlet weak var teamSecondaryColorView: UIView!

    var team: Team? {
        didSet {
            if let team = team {
                teamNameLabel.text = team.name
                teamPrimaryColorView.backgroundColor = team.primaryColor
                teamSecondaryColorView.backgroundColor = team.secondaryColor
            }
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
