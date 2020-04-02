//
//  GameDayEventHeaderTableViewCell.swift
//  SportsYap
//
//  Created by Master on 2020/4/2.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit

class GameDayEventHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var team: Team? {
        didSet {
            if let team = team {
                titleLabel.text = team.name + " " + NSLocalizedString("Tailgate Party", comment: "")
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
