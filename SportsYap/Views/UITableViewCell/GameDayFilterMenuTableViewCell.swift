//
//  GameDayFilterMenuTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 3/1/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

protocol GameDayFilterMenuTableViewCellDelegate {
    func menuChanged(to filter: String)
}

class GameDayFilterMenuTableViewCell: UITableViewCell {
    
    @IBOutlet var newsBttn: UIButton!
    @IBOutlet var fansBttn: UIButton!
    
    var delegate: GameDayFilterMenuTableViewCellDelegate!
    
    @IBAction func newsBttnPressed(_ sender: Any) {
        delegate.menuChanged(to: "news")
    }
    @IBAction func fansBttnPressed(_ sender: Any) {
        delegate.menuChanged(to: "fans")
    }
    


}
