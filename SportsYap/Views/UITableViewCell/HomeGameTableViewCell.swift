//
//  HomeGameTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 3/9/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class HomeGameTableViewCell: UITableViewCell {

    @IBOutlet var card: GameCard!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
