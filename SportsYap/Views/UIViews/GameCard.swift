//
//  GameCard.swift
//  SportsYap
//
//  Created by Alex Pelletier on 3/9/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class GameCard: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var awayHomeTownLabel: UILabel!
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var awayScoreLabel: UILabel!
    @IBOutlet weak var awayTeamPrimaryColorView: UIView!
    @IBOutlet weak var awayTeamSecondaryColorView: UIView!
    
    @IBOutlet weak var homeHomeTownLabel: UILabel!
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var homeScoreLabel: UILabel!
    @IBOutlet weak var homeTeamPrimaryColorView: UIView!
    @IBOutlet weak var homeTeamSecondaryColorView: UIView!
    
    @IBOutlet weak var sportBgImageView: UIImageView!
    @IBOutlet weak var activeChallengeImageView: UIImageView!
    
    var game: Game? {
        didSet {
            if let game = game {
                titleLabel.text = game.venue.name
                timeLabel.text = game.startTime
                
                // if start time is past 5 hours the current date add 'final' instead of start time
                if let startFiveHours = Calendar.current.date(byAdding: .hour, value: 5, to: game.start) {
                    timeLabel.text = startFiveHours < Date() ? "Final" : game.startTime
                }
                
                if game.awayTeam != nil{
                    awayHomeTownLabel.text = game.awayTeam.homeTown
                    awayTeamNameLabel.text = game.awayTeam.name
                    awayScoreLabel.text = "\(game.awayScore)"
                    awayTeamPrimaryColorView.backgroundColor = game.awayTeam.primaryColor
                    awayTeamSecondaryColorView.backgroundColor = game.awayTeam.secondaryColor
                }
                
                if game.homeTeam != nil{
                    homeHomeTownLabel.text = game.homeTeam.homeTown
                    homeTeamNameLabel.text = game.homeTeam.name
                    homeScoreLabel.text = "\(game.homeScore)"
                    homeTeamPrimaryColorView.backgroundColor = game.homeTeam.primaryColor
                    homeTeamSecondaryColorView.backgroundColor = game.homeTeam.secondaryColor
                }
                
                sportBgImageView.image = game.sport.image
                
                activeChallengeImageView.alpha = game.challenge != nil ? 1 : 0
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
    }
    
    private func xibSetup() {
        if let view = Bundle.main.loadNibNamed("GameCard", owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }
}
