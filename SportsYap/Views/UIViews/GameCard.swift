//
//  GameCard.swift
//  SportsYap
//
//  Created by Alex Pelletier on 3/9/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class GameCard: UIView {

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
    @IBOutlet weak var activeChallengeImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
    }
    
    func xibSetup(){
        if let view = Bundle.main.loadNibNamed("GameCard", owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
            
            
        }
    }
    
    
    func load(game: Game){
        titleLbl.text = game.venue.name
        timeLbl.text = game.startTime
        
        // if start time is past 5 hours the current date add 'final' instead of start time
        if let startFiveHours = Calendar.current.date(byAdding: .hour, value: 5, to: game.start) {
            timeLbl.text = startFiveHours < Date() ? "Final" : game.startTime
        }
        
        if game.awayTeam != nil{
            awayHomeTown.text = game.awayTeam.homeTown
            awayTeamName.text = game.awayTeam.name
            awayScore.text = "\(game.awayScore)"
            awayTeamPrimaryColorView.backgroundColor = game.awayTeam.primaryColor
            awayTeamSecondaryColorView.backgroundColor = game.awayTeam.secondaryColor
        }
        
        if game.homeTeam != nil{
            homeHomeTown.text = game.homeTeam.homeTown
            homeTeamName.text = game.homeTeam.name
            homeScore.text = "\(game.homeScore)"
            homeTeamPrimaryColorView.backgroundColor = game.homeTeam.primaryColor
            homeTeamSecondaryColorView.backgroundColor = game.homeTeam.secondaryColor
        }
        
        sportBg.image = game.sport.image
        
        activeChallengeImageView.alpha = game.challenge != nil ? 1 : 0
    }
}
