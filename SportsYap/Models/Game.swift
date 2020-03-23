//
//  Game.swift
//  SportsYap
//
//  Created by Alex Pelletier on 3/8/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class Game: DBObject {
    
    var sport = Sport.football
    var fieldId = 0
    var winningTeamId = 0
    var homeScore = 0
    var awayScore = 0
    var start = Date()
    
    var awayTeam: Team!
    var homeTeam: Team!
    var venue: Venue!
    var challenge: Challenge?
    
    var fanMeter: Double?
    var fans = [User]()
    var news = [News]()
    var posts = [Post]()
    var events = [Event]()
    
    var hasFrontRow: Bool {
        get{ return fans.verified.count > 0 }
    }
    
    var startTime: String{
        get{
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mma"
            return formatter.string(from: start)
        }
    }
    
    var startString: String?
    var startString2: String?
    
    override var description: String{
        get{ return "`\(type(of: self))`  id: \(id) on \(start)"  }
    }
    
    override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        if let sid = dict["sport_id"] as? Int, let s = Sport(rawValue: sid){
            sport = s
        }
        
        if let fid = dict["field_id"] as? Int{
            fieldId = fid
        }
        
        if let wid = dict["winning_team_id"] as? Int{
            winningTeamId = wid
        }
        
        if let hts = dict["hometeam_score"] as? Int{
            homeScore = hts
        }
        
        if let ats = dict["awayteam_score"] as? Int{
            awayScore = ats
        }
        
        if let homeTeamDict = dict["hometeam"] as? [String: AnyObject]{
            homeTeam = Team(dict: homeTeamDict)
        }
        
        if let awayTeamDict = dict["awayteam"] as? [String: AnyObject]{
            awayTeam = Team(dict: awayTeamDict)
        }
        
        if let cDict = dict["challenge"] as? [String: AnyObject]{
            challenge = Challenge(dict: cDict)
        }
        
        if let s = dict["start"] as? String{
            
            startString2 = s
            
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone(abbreviation: "PST")
            if let d = formatter.date(from: s){
                start = d
                
                
                // TESTING
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "YYYY-MM-dd h:mma"
                formatter1.string(from: start)
                
                startString = formatter1.string(from: start)
                // TESTING
                
            }   
        }
        
        if let venueDict = dict["venue"] as? [String: AnyObject]{
            venue = Venue(dict: venueDict)
        } else {
            venue = Venue()
        }
        
        fans = [User]()
        if let usersJson = dict["fans"] as? [[String: AnyObject]] {
            for userJson in usersJson {
                let u = User(dict: userJson)
                if let p = userJson["pivot"] as? [String: AnyObject] {
                    u.pivot = UserFollowablePivot(dict: p)
                } else if let tId = userJson["team_id"] as? Int {
                    u.pivot = UserFollowablePivot(itemA: tId, itemB: u.id, type: "Following")
                }
                fans.append(u)
            }
        }
    }
}

extension Array where Element == Game{
    var removeDuds: [Element]{
        return self.filter({
            ($0.awayTeam != nil && $0.awayTeam.hasColors && $0.homeTeam != nil && $0.homeTeam.hasColors)
        })
    }
}
