//
//  Teams.swift
//  SportsYap
//
//  Created by Alex Pelletier on 2/22/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

enum Sport: Int{
    case baseball = 1
    case basketball
    case football
    case soccer
    case hockey
    case collegeBasketball
    case collegeFootball
    
    var name: String{
        get{
            switch self {
                case .baseball: return "BaseBall"
                case .basketball: return "Basketball"
                case .football: return "Football"
                case .soccer: return "Soccer"
                case .hockey: return "Hockey"
                case .collegeBasketball: return "Basketball"
                case .collegeFootball: return "Football"
            }
        }
    }
    
    var image: UIImage{
        get{
            switch self {
                case .baseball: return #imageLiteral(resourceName: "baseball_bg")
                case .basketball, .collegeBasketball: return #imageLiteral(resourceName: "basketball_bg")
                case .football, .collegeFootball: return #imageLiteral(resourceName: "football_bg")
                case .soccer: return #imageLiteral(resourceName: "soccer_bg")
                case .hockey: return #imageLiteral(resourceName: "hockey_bg")
            }
        }
    }
    
    var abv: String{
        get{
            switch self {
                case .baseball: return "MLB"
                case .basketball: return "NBA"
                case .football: return "NFL"
                case .soccer: return "MLS"
                case .hockey: return "NHL"
                case .collegeBasketball: return "NCAAM"
                case .collegeFootball: return "NCAAF"
            }
        }
    }
    
    var gameDayString: String{
        get{
            switch self {
            case .hockey: return "Ice"
            case .collegeBasketball, .basketball: return "Court"
            default: return "Field"
            }
        }
    }
    
    var id: Int{ get{ return rawValue }}
    
    static var all: [Sport]{
        get{ return [.baseball, .basketball, .football, .soccer, .hockey, .collegeBasketball, .collegeFootball] }
    }
}

class Team: DBObject {

    var sport = Sport.baseball
    var homeTown = ""
    var name = ""
    var abbr = ""
    var active = true
    
    var primaryColor = UIColor(hex: "262626")
    var secondaryColor = UIColor(hex: "EEEEEE")
    var hasColors: Bool{
        return primaryColor != UIColor(hex: "262626") && secondaryColor != UIColor(hex: "EEEEEE")
    }
    var followed = false
    
    override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        if let sid = dict["sport_id"] as? Int, let s = Sport(rawValue: sid){
            sport = s
        }
        
        if let ht = dict["home_town"] as? String{
            homeTown = ht
        }
        
        if let n = dict["name"] as? String{
            name = n
        }
        
        if let a = dict["abbreviation"] as? String{
            abbr = a
        }
        
        if let a = dict["active"] as? Bool{
            active = a
        }
        
        if let pch = dict["primary_color"] as? String{
            if pch != "##########", pch.length == 7{
                primaryColor = UIColor(hex: pch)
            }
        }
        
        if let sch = dict["secondary_color"] as? String{
            if sch != "##########", sch.length == 7{
                secondaryColor = UIColor(hex: sch)
            }
        }
        
        if let cf = dict["can_follow"] as? Bool{
            followed = !cf
        }
    }
}

extension Array where Element == Team{
    var alphabetized: [Element]{
        get{
            return self.sorted(by: { $0.name < $1.name })
        }
    }
}
