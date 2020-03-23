//
//  User.swift
//  SportsYap
//
//  Created by Alex Pelletier on 1/29/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class User: DBObject {
    
    static var me = User()
    
    var name = ""
    var email = ""
    var facebook = false
    var location = "Los Angeles, CA"
    var verified = false
    var profileImage: URL?
    var password: String?
    var phone = ""
    
    var firstName = ""
    var lastName = ""
    
    var followerCnt = 0
    var followingCnt = 0
    var shotsCnt = 0
    
    var teamId: Int = 0
    
    var teams = [Team]()
    var posts = [Post]()
    var games = [Game]()
    var followers = [User]()
    var followings = [User]()
    
    var followed = false
    
    var streamingUrl: URL?
    var isStreaming = false
    
    var atGame: Bool?
    var pushToken: String?
    
    var firstname: String{
        get{
            return firstName
        }
    }
    
    // stuff to track in app not from database
    var likedPosts = [Int]()
    var currentPost: Post!
    var didSelectFromGallery = false
    
    override init() {
        super.init()
        
    }
    
    override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        loadFromDict(dict: dict)
    }
    
    func updateFromDict(dict: [String: AnyObject]){
        update(dict: dict)
        
        loadFromDict(dict: dict)
    }
    
    private func loadFromDict(dict: [String: AnyObject]){
        if let n = dict["name"] as? String{
            name = n
        }
        
        if let e = dict["email"] as? String{
            email = e
        }
        
        if let fn = dict["first_name"] as? String{
            firstName = fn
        }
        
        if let ln = dict["last_name"] as? String{
            lastName = ln
        }
        
        if let ht = dict["home_town"] as? String{
            location = ht
        }
        
        if let fc = dict["follower_count"] as? Int{
            followerCnt = fc
        }
        
        if let fc = dict["following_count"] as? Int{
            followingCnt = fc
        }
        
        if let sc = dict["shots_count"] as? Int{
            shotsCnt = sc
        }
        
        if let teamsJson = dict["teams"] as? [[String: AnyObject]]{
            for teamJson in teamsJson{
                teams.append(Team(dict: teamJson))
            }
        }
        
        if let postsJson = dict["posts"] as? [[String: AnyObject]]{
            for postJson in postsJson{
                let post = Post(dict: postJson)
                post.user = self
                posts.append(post)
            }
        }
        var postGames = [Int: Game]()
        for p in posts{
            guard let g = p.game else { continue }
            postGames[g.id] = g
        }
        games = Array(postGames.values)
        for g in games{
            g.posts = posts.filter({ $0.game?.id == g.id })
        }
        games = games.sorted(by: { $0.start > $1.start })
        
        if let cf = dict["can_follow"] as? Bool{
            followed = !cf
        }
        
        facebook = (dict["facebook"] as? String) != nil
        
        if let iv = dict["is_verified"] as? Int{
            verified = iv == 1
        }
        
        if let pf = dict["image"] as? String{
            profileImage = URL(string: "\(ApiManager.shared.BASE_IMAGE_URL)\(pf)")!
        }
        
        if let _teamId = dict["team_id"] as? Int {
            teamId = _teamId
        }

        if let sus = dict["stream_url"] as? String, let su = URL(string: sus){
            streamingUrl = su
        }
        isStreaming = (dict["is_streaming"] as? Bool) ?? false
        
        if let ag = dict["at_game"] as? Bool {
            atGame = ag
        }
        
        if let pt = dict["push_token"] as? String {
            pushToken = pt
        }
    }
}

class UserFollowablePivot: DBPivot {
    var type = ""
    
    init(dict: [String: AnyObject]){
        super.init()
        
        if let f = dict["followable_id"] as? Int{
            itemAId = f
        }
        
        if let u = dict["user_id"] as? Int{
            itemBId = u
        }
        
        if let t = dict["followable_type"] as? String{
            type = t
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        
        if let c = dict["created_at"] as? String{
            if let cAt = formatter.date(from: c){
                createdAt = cAt
            }
        }
    }
    
    init(itemA: Int, itemB: Int, type: String) {
        super.init()
        
        self.itemAId = itemA
        self.itemBId = itemB
        self.type = type
        createdAt = nil
    }
}

extension Sequence where Iterator.Element == User{
    var verified: [User]!{
        get{
            var tempUsers = [User]()
            
            for user in self {
                if user.verified, let atGame = user.atGame, atGame {
                    tempUsers.append(user)
                }
            }
            
            return tempUsers
            //return self.filter({ $0.verified })
        }
    }
    
    var atGame: [User]! {
        get {
            var tempUsers = [User]()
            
            for user in self {
                if !user.verified, let atGame = user.atGame, atGame {
                    tempUsers.append(user)
                }
            }
            
            return tempUsers
        }
    }
    
    var watchingGame: [User]! {
        get {
            var tempUsers = [User]()
            
            for user in self {
                if let atGame = user.atGame, !atGame {
                    tempUsers.append(user)
                } else if user.atGame == nil {
                    // nil so by default they are watching the game
                    tempUsers.append(user)
                }
            }
            
            return tempUsers
        }
    }

}
