//
//  GameDayGameTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 3/10/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

protocol GameDayGameTableViewCellDelegate {
    func enterFieldBttnPressed()
    func addToFieldBttnPressed()
}

class GameDayGameTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var timeLbl: UILabel!
    
    @IBOutlet var awayHomeTown: UILabel!
    @IBOutlet var awayTeamName: UILabel!
    @IBOutlet var awayScore: UILabel!
    @IBOutlet var awayTeamPrimaryColorView: UIView!
    @IBOutlet var awayTeamSecondaryColorView: UIView!
    
    @IBOutlet var homeHomeTown: UILabel!
    @IBOutlet var homeTeamName: UILabel!
    @IBOutlet var homeScore: UILabel!
    @IBOutlet var homeTeamPrimaryColorView: UIView!
    @IBOutlet var homeTeamSecondaryColorView: UIView!
    
    @IBOutlet var sportBg: UIImageView!
    
    @IBOutlet var fanMeterContainerView: UIView!
    @IBOutlet var fanMeterLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var enterLabel: UILabel!
    @IBOutlet var addLabel: UILabel!
    
    var delegate: GameDayGameTableViewCellDelegate!
    
    func load(game: Game){
        titleLbl.text = game.venue.name
        timeLbl.text = game.startTime
        
        awayHomeTown.text = game.awayTeam.homeTown
        awayTeamName.text = game.awayTeam.name
        awayScore.text = "\(game.awayScore)"
        awayTeamPrimaryColorView.backgroundColor = game.awayTeam.primaryColor
        awayTeamSecondaryColorView.backgroundColor = game.awayTeam.secondaryColor
        
        homeHomeTown.text = game.homeTeam.homeTown
        homeTeamName.text = game.homeTeam.name
        homeScore.text = "\(game.homeScore)"
        homeTeamPrimaryColorView.backgroundColor = game.homeTeam.primaryColor
        homeTeamSecondaryColorView.backgroundColor = game.homeTeam.secondaryColor
        
        sportBg.image = game.sport.image
        
        let val = game.fanMeter ?? 0.5
        fanMeterLeadingConstraint.constant = (UIScreen.main.bounds.width - 54) * CGFloat(val)
        
        enterLabel.text = "Enter the \(game.sport.gameDayString)"
        addLabel.text = "Add to the \(game.sport.gameDayString)"
    }
    
    //MARK: IBAction
    @IBAction func enterFieldBttnPressed(_ sender: Any) {
        delegate.enterFieldBttnPressed()
    }
    @IBAction func addToFieldBttnPressed(_ sender: Any) {
        delegate.addToFieldBttnPressed()
    }
    
    
}
