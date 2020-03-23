//
//  Event.swift
//  SportsYap
//
//  Created by Master on 2020/3/21.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit

class Event: DBObject {
    
    var gameId = 0
    var teamId = 0
    var team: Team?
    var game: Game?

    var thumbnail: URL?

    var name: String = ""
    var content: String = ""
    var fansGoing: Int = 0
    var cost: Double = 0
    var from: Date?
    var to: Date?
    var location: String = ""
    
    override init(dict: [String: AnyObject]) {
        super.init(dict: dict)
        
        if let ti = dict["team_id"] as? Int{
            teamId = ti
        }
        
        if let tJson = dict["team"] as? [String: AnyObject]{
            team = Team(dict: tJson)
        }
        
        if let gi = dict["game_id"] as? Int {
            gameId = gi
        }
        
        if let gJson = dict["game"] as? [String: AnyObject] {
            game = Game(dict: gJson)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'.000'XXXXX"

        if let c = dict["published"] as? String{
            if let cAt = formatter.date(from: c){
                createdAt = cAt
            }
        }

        if let ts = dict["thumbail_url"] as? String, let u = URL(string: ts){
            thumbnail = u
        }

        name = dict["name"] as? String ?? ""
        content = dict["content"] as? String ?? ""
        fansGoing = dict["fans_going"] as? Int ?? 0
        cost = dict["cost"] as? Double ?? 0

        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let from = dict["from"] as? String {
            if let date = formatter.date(from: from) {
                self.from = date
            }
        }

        if let to = dict["to"] as? String {
            if let date = formatter.date(from: to) {
                self.to = date
            }
        }
        
        location = dict["location"] as? String ?? ""
    }
}
