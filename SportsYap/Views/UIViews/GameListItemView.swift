//
//  GameListItemView.swift
//  SportsYap
//
//  Created by Master on 2020/3/17.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit

class GameListItemView: UIView {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var homeFansStackView: UIStackView!
    @IBOutlet weak var homeLocationLabel: UILabel!
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var homeScoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var awayScoreLabel: UILabel!
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var awayLocationLabel: UILabel!
    @IBOutlet weak var awayFansStackView: UIStackView!
    
    @IBOutlet weak var stadiumLabel: UILabel!
    @IBOutlet weak var watchOnLabel: UILabel!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    var game: Game? {
        didSet {
            guard let game = game else {
                return
            }
            
            timeLabel.text = game.startTime
            // if start time is past 5 hours the current date add 'final' instead of start time
            if let startFiveHours = Calendar.current.date(byAdding: .hour, value: 5, to: game.start) {
                timeLabel.text = startFiveHours < Date() ? "Final" : game.startTime
            }
            
            homeLocationLabel.text = game.homeTeam?.homeTown ?? ""
            homeTeamNameLabel.text = game.homeTeam?.name ?? ""
            homeScoreLabel.text = "\(game.homeScore)"

            awayScoreLabel.text = "\(game.awayScore)"
            awayTeamNameLabel.text = game.awayTeam?.name ?? ""
            awayLocationLabel.text = game.awayTeam?.homeTown ?? ""

            backgroundImageView.image = game.sport.image
            
            stadiumLabel.text = game.venue.name
            watchOnLabel.text = game.sport.abv
            
            for fan in game.fans {

            }
        }
    }
}
