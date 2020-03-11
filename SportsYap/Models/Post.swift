//
//  Post.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/2/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class Post: DBObject {
    
    var media: UserMedia!
    var user: User!
    
    var gameId = 0
    var teamId = 0
    var team: Team?
    var game: Game?
    
    var liked = false
    var likeCnt: Int?
    var comments = [Comment]()
    var contentHeight = 0
    
    override init(dict: [String: AnyObject]){
        super.init(dict: dict)
        
        if let ti = dict["team_id"] as? Int{
            teamId = ti
        }
        
        if let tJson = dict["team"] as? [String: AnyObject]{
            team = Team(dict: tJson)
        }
        
        if let gi = dict["game_id"] as? Int{
            gameId = gi
        }
        
        if let uJson = dict["user"] as? [String: AnyObject]{
            user = User(dict: uJson)
        }
        
        if let gJson = dict["game"] as? [String: AnyObject]{
            game = Game(dict: gJson)
        }
        
        if let lc = dict["likes"] as? Int{
            likeCnt = lc
        }
        
        if let ch = dict["content_height"] as? Int {
            contentHeight = ch
        }
        
        if let fn = dict["filename"] as? String, let t = dict["type"] as? String{
            media = UserMedia()
            if t == "mov"{
                media.videoUrl = URL(string: "\(ApiManager.shared.BASE_IMAGE_URL)/uploads/\(fn).mov")!
                media.thumbnailUrl = URL(string: "\(ApiManager.shared.BASE_IMAGE_URL)/uploads/\(fn).png")!
            }else if t == "jpg"{
                media.photoUrl = URL(string: "\(ApiManager.shared.BASE_IMAGE_URL)/uploads/\(fn).jpg")!
            }
        }
        
        liked = (dict["liked"] as? Bool) ?? false
        
    }
}
