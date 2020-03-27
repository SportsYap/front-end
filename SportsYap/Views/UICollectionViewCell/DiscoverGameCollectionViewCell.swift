//
//  DiscoverGameCollectionViewCell.swift
//  
//
//  Created by Alex Pelletier on 3/20/18.
//

import UIKit

class DiscoverGameCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var fieldNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var awayScoreLabel: UILabel!
    
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var homeScoreLabel: UILabel!
    
    @IBOutlet weak var sportBgImageView: UIImageView!
    
    var game: Game? {
        didSet {
            if let game = game {
                if game.awayTeam != nil {
                    awayTeamNameLabel.text = game.awayTeam.name
                    awayScoreLabel.text = "\(game.awayScore)"
                }
                if game.homeTeam != nil {
                    homeTeamNameLabel.text = game.homeTeam.name
                    homeScoreLabel.text = "\(game.homeScore)"
                }
                sportBgImageView.image = game.sport.image
                fieldNameLabel.text = game.venue.name
                
                timeLabel.text = game.startTime
                
                // if start time is past 5 hours the current date add 'final' instead of start time
                if let startFiveHours = Calendar.current.date(byAdding: .hour, value: 5, to: game.start) {
                    timeLabel.text = startFiveHours < Date() ? "Final" : game.startTime
                }
            }
        }
    }
}
