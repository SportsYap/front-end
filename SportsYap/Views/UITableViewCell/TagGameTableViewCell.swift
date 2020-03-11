//
//  TagGameTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 4/23/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

protocol TagGameTableViewCellDelegate {
    func teamPressed(game: Game, team: Team)
}

class TagGameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet var sportBg: UIImageView!
    
    @IBOutlet var awayHomeTown: UILabel!
    @IBOutlet var awayTeamName: UILabel!
    @IBOutlet var awayScore: UILabel!
    @IBOutlet var awayTeamPrimaryColorView: UIView!
    @IBOutlet var awayTeamSecondaryColorView: UIView!
    @IBOutlet var awayTeamSelectedView: UIView!
    
    @IBOutlet var homeHomeTown: UILabel!
    @IBOutlet var homeTeamName: UILabel!
    @IBOutlet var homeScore: UILabel!
    @IBOutlet var homeTeamPrimaryColorView: UIView!
    @IBOutlet var homeTeamSecondaryColorView: UIView!
    @IBOutlet var homeTeamSelectedView: UIView!
    
    var game: Game!
    var delegate: TagGameTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func teamBttnPressed(_ sender: UIButton) {
        let team = sender.tag == 0 ? game.awayTeam : game.homeTeam
        delegate.teamPressed(game: game, team: team!)
    }
    
}
