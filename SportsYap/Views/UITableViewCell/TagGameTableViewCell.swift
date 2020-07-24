//
//  TagGameTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 4/23/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

protocol TagGameTableViewCellDelegate {
    func didSelectTeam(game: Game, team: Team)
}

class TagGameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sportBgImageView: UIImageView!
    
    @IBOutlet weak var awayHomeTownLabel: UILabel!
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var awayScoreLabel: UILabel!
    @IBOutlet weak var awayTeamPrimaryColorView: UIView!
    @IBOutlet weak var awayTeamSecondaryColorView: UIView!
    @IBOutlet weak var awayTeamSelectedView: UIView!
    
    @IBOutlet weak var homeHomeTownLabel: UILabel!
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var homeScoreLabel: UILabel!
    @IBOutlet weak var homeTeamPrimaryColorView: UIView!
    @IBOutlet weak var homeTeamSecondaryColorView: UIView!
    @IBOutlet weak var homeTeamSelectedView: UIView!
    
    var game: Game! {
        didSet {
            if game.awayTeam != nil {
                awayHomeTownLabel.text = game.awayTeam.homeTown
                awayTeamNameLabel.text = game.awayTeam.name
                awayScoreLabel.text = "\(game.awayShots) Shots"
                awayTeamPrimaryColorView.backgroundColor = game.awayTeam.primaryColor
                awayTeamSecondaryColorView.backgroundColor = game.awayTeam.secondaryColor
            }
            
            if game.homeTeam != nil {
                homeHomeTownLabel.text = game.homeTeam.homeTown
                homeTeamNameLabel.text = game.homeTeam.name
                homeScoreLabel.text = "\(game.homeShots) Shots"
                homeTeamPrimaryColorView.backgroundColor = game.homeTeam.primaryColor
                homeTeamSecondaryColorView.backgroundColor = game.homeTeam.secondaryColor
            }
            
            sportBgImageView.image = game.sport.image
            if game.venue != nil {
                titleLabel.text = "\(game.venue.name) \(game.startTime)"
            }
        }
    }
    
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
        delegate.didSelectTeam(game: game, team: team!)
    }
    
}
