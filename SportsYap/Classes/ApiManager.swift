//
//  ApiManager.swift
//  SportsYapp
//
//  Created by Alex Pelletier on 10/4/16.
//  Copyright © 2016 Alex Pelletier. All rights reserved.
//

// User
// 'accounts@alexp.io'
// 'password'


import UIKit
import Alamofire

let voidErr: (_ error: NSError)->Void = { (err) in }
var singlePost = false

class ApiManager: NSObject {
    static var shared = ApiManager()
    
//    let BASE_URL = "https://api.sportsyap.com/api"
    let BASE_URL = "http://192.168.0.180/api"
//    let BASE_IMAGE_URL = "https://api.sportsyap.com"
    let BASE_IMAGE_URL = "http://192.168.0.180"
    var accessToken = ""{
        didSet{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-token-changed"), object: nil)
        }
    }
    var refreshToken = ""
    
    var loggedIn = false{
        didSet{
            UserDefaults.standard.set(loggedIn, forKey: "logged_in")
        }
    }
    
    override init(){
        super.init()
        
        if let at = UserDefaults.standard.string(forKey: "USER_ACCESS_TOKEN"){
            accessToken = at
        }
        if let rt = UserDefaults.standard.string(forKey: "USER_REFRESH_TOKEN"){
            refreshToken = rt
        }
        
        if accessToken != ""{
            loggedIn = true
            self.me(onSuccess: { (user) in
                self.games(for: Date(), onSuccess: { (games) in
                    self.prefetch()
                }) { (err) in }
            }) { (err) in
                self.loggedIn = false
            }
        }else{
            prefetch()
        }
        
        
    }
    
    func prefetch(){
        // Nothing to prefetch
    }

    //MARK: Auth
    func login(email: String, password: String, _ onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){ //Wire Up
        let param:[String: String] = [
            "email": email.lowercased(),
            "password": password,
            "name": "-",
            "type": "password"
        ]
        
        let path = "/user/login"
        processRequestTo(path: path, httpMethod: "POST", parameters: param, onSuccess: { (json) in
            if let data = json["data"] as? [String: AnyObject]{
                if let at = data["access_token"] as? String{
                    self.accessToken = at
                    self.refreshToken = ""
                    self.loggedIn = true

                    UserDefaults.standard.setValue(at, forKey: "USER_ACCESS_TOKEN")
                    onSuccess()
                }else{
                    onError(NSError(domain: "api.response_error", code: 500, userInfo: ["message":"signup missing access or refresh token"]))
                }
            }else{
                onError(NSError(domain: "api.response_error", code: 500, userInfo: ["message":"signup missing access or refresh token"]))
            }
        }, onError: { (err) in
            self.loggedIn = false
            onError(err)
        })
    }
    func fbLogin(email: String, name: String, token: String, _ onSuccess: @escaping (_ created: Bool)->Void, onError: @escaping (_ error: NSError)->Void){ //Wire Up
        let param:[String: String] = [
            "email": email.lowercased(),
            "password": "-",
            "name": name,
            "facebook_id": token,
            "type": "facebook"
        ]
        
        let path = "/user/login"
        processRequestTo(path: path, httpMethod: "POST", parameters: param, onSuccess: { (json) in
            if let data = json["data"] as? [String: AnyObject]{
                if let at = data["access_token"] as? String{
                    self.accessToken = at
                    self.refreshToken = ""
                    self.loggedIn = true

                    UserDefaults.standard.setValue(at, forKey: "USER_ACCESS_TOKEN")
                    let code = json["status_code"]  as? String ?? "200"
                    onSuccess(code != "200")
                }else{
                    onError(NSError(domain: "api.response_error", code: 500, userInfo: ["message":"signup missing access or refresh token"]))
                }
            }else{
                onError(NSError(domain: "api.response_error", code: 500, userInfo: ["message":"signup missing access or refresh token"]))
            }
        }, onError: { (err) in
            self.loggedIn = false
            onError(err)
        })
    }
    func phoneLogin(phone: String, name: String, token: String, _ onSuccess: @escaping (_ created: Bool)->Void, onError: @escaping (_ error: NSError)->Void){ //Wire Up
        let param:[String: String] = [
            "phone_number": phone,
            "password": "-",
            "name": name,
            "phone_token": token,
            "type": "phone",
            "email": "\(phone)@google.com"
        ]
        
        let path = "/user/login"
        processRequestTo(path: path, httpMethod: "POST", parameters: param, onSuccess: { (json) in
            if let at = json["access_token"] as? String{
                self.accessToken = at
                self.refreshToken = ""
                self.loggedIn = true

                UserDefaults.standard.setValue(at, forKey: "USER_ACCESS_TOKEN")
                let code = json["status_code"]  as? String ?? "200"
                onSuccess(code != "200")
            }else{
                onError(NSError(domain: "api.response_error", code: 500, userInfo: ["message":"signup missing access or refresh token"]))
            }
        }, onError: { (err) in
            self.loggedIn = false
            onError(err)
        })
    }
    func signup(name: String, email: String, password: String, _ onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        let param:[String: String] = [
            "name": name,
            "email": email.lowercased(),
            "username": email.lowercased(),
            "password": password,
            "type": "password"
        ]
        
        let path = "/user/register"
        processRequestTo(path: path, httpMethod: "POST", parameters: param, onSuccess: { (json) in
            if let at = json["data"]?["access_token"] as? String, let rt = json["data"]?["refresh_token"] as? String{
                self.accessToken = at
                self.refreshToken = rt
                self.loggedIn = true
                UserDefaults.standard.setValue(at, forKey: "USER_ACCESS_TOKEN")
                UserDefaults.standard.setValue(rt, forKey: "USER_REFRESH_TOKEN")
                onSuccess()
            }else{
                onError(NSError(domain: "api.response_error", code: 500, userInfo: ["message":"signup missing access or refresh token"]))
            }
        }, onError: { (err) in
            onError(err)
        })
    }
    
    //MARK: User
    func me(onSuccess: @escaping (_ user: User)->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/user"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let userJson = json["success"] as? [String: AnyObject]{
                User.me.updateFromDict(dict: userJson)
                onSuccess(User.me)
            }else{
                onError(NSError(domain: "api.response_error", code: 500, userInfo: ["message":"me missing data"]))
            }
        }, onError: { (err) in
            onError(err)
        })
    }
    
    func user(for userId: Int, onSuccess: @escaping (_ user: User)->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/user/\(userId)"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let userJson = json["success"] as? [String: AnyObject]{
                let user = User(dict: userJson)
                onSuccess(user)
            }else{
                onError(NSError(domain: "api.response_error", code: 500, userInfo: ["message":"me missing data"]))
            }
        }, onError: { (err) in
            onError(err)
        })
    }
    
    func logout(){
        accessToken = ""
        refreshToken = ""
        loggedIn = false
        UserDefaults.standard.removeObject(forKey: "USER_ACCESS_TOKEN")
        UserDefaults.standard.removeObject(forKey: "USER_REFRESH_TOKEN")
    }
    
    func uploadProfilePhoto(photo: UIImage, onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        //let imgData = UIImageJPEGRepresentation(photo, 0.2)!
        let imgData = photo.jpegData(compressionQuality: 0.2)!
        let headers: HTTPHeaders! = ["Accept": "application/json", "Authorization": "Bearer \(accessToken)"]
        let path = "/user/picture"
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imgData, withName: "file",fileName: "photo.jpg", mimeType: "image/jpg")
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: "\(BASE_URL)\(path)", method: .post, headers: headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    let code = response.response?.statusCode ?? 0
                    if code == 200{
                        onSuccess()
                    }else{
                        onError(NSError(domain: "api.error", code: code, userInfo: ["message":"invalid response code"]))
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    func updateSelf(onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/user"
        
        var params = ["name": User.me.name, "email": User.me.email, "home_town": User.me.location, "first_name": User.me.firstName, "last_name": User.me.lastName]
        if let pw = User.me.password{
            params["password"] = pw
        }
        
        processRequestTo(path: path, httpMethod: "PUT", parameters: params, onSuccess: { (json) in
            onSuccess()
        }, onError: { (err) in
            onError(err)
        })
    }
    
    func updatePushToken(token: String, onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/user/pushtoken"
        let params = ["push_token": token]
        
        processRequestTo(path: path, httpMethod: "PUT", parameters: params, onSuccess: { (json) in
            onSuccess()
        }, onError: { (err) in
            onError(err)
        })
    }
    
    //MARK: Follow
    func follow(user id: Int, onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/user/\(id)/follow"
        processRequestTo(path: path, httpMethod: "PATCH", parameters: nil, onSuccess: { (json) in
            onSuccess()
        }, onError: { (err) in
            onError(err)
        })
    }
    func unfollow(user id: Int, onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/user/\(id)/follow"
        processRequestTo(path: path, httpMethod: "DELETE", parameters: nil, onSuccess: { (json) in
            onSuccess()
        }, onError: { (err) in
            onError(err)
        })
    }
    func followers(user id: Int, onSuccess: @escaping (_ users: [User])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/user/\(id)/followers"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let usersJson = json["data"] as? [[String: AnyObject]]{
                var users = [User]()
                for userJson in usersJson{
                    users.append(User(dict: userJson))
                }
                onSuccess(users)
            }else{
                onSuccess([User]())
            }
        }, onError: { (err) in
            onError(err)
        })
    }
    func following(user id: Int, onSuccess: @escaping (_ users: [User])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/user/\(id)/following"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let usersJson = json["data"] as? [[String: AnyObject]]{
                var users = [User]()
                for userJson in usersJson{
                    users.append(User(dict: userJson))
                }
                onSuccess(users)
            }else{
                onSuccess([User]())
            }
        }, onError: { (err) in
            onError(err)
        })
    }
    
    func likes(user id: Int){
        let path = "/user/\(id)/likes"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let likesJson = json["data"] as? [[String: AnyObject]]{
                var postIds = [Int]()
                for like in likesJson {
                    guard let postId = like["followable_id"] as? Int else { continue }
                    postIds.append(postId)
                }
                
                User.me.likedPosts = postIds
                
            }else{
                print("something went wrong")
            }
        }, onError: { (err) in
            print("something went wrong2")
            print(err.localizedDescription)
        })
    }
    
    //MARK: Teams
    func teams(onSuccess: @escaping (_ teams: [Team])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/teams"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let teamsJson = json["data"] as? [[String: AnyObject]]{
                var teams = [Team]()
                for teamJson in teamsJson{
                    teams.append(Team(dict: teamJson))
                }
                onSuccess(teams)
            }else{
                onSuccess([Team]())
            }
        }, onError: { (err) in
            onError(err)
        })
    }
    func teams(for search: String, onSuccess: @escaping (_ teams: [Team])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/discover/search?q=\(search)"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let dataJson = json["data"] as? [String: AnyObject]{
                var teams = [Team]()
                if let teamsJson = dataJson["teams"] as? [[String: AnyObject]]{
                    for (_, teamJson) in teamsJson.enumerated(){
                        teams.append(Team(dict: teamJson))
                    }
                }
                
                onSuccess(teams)
            }else{
                onSuccess([Team]())
            }
        }, onError: { (err) in
            onError(err)
        })
    }
    func teams(for sport: Sport, search: String, onSuccess: @escaping (_ teams: [Team])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/discover/search?sport_id=\(sport.rawValue)&q=\(search)"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let dataJson = json["data"] as? [String: AnyObject]{
                var teams = [Team]()
                if let teamsJson = dataJson["teams"] as? [[String: AnyObject]]{
                    for (_, teamJson) in teamsJson.enumerated(){
                        teams.append(Team(dict: teamJson))
                    }
                }
                
                onSuccess(teams.filter({ $0.sport == sport }))
            }else{
                onSuccess([Team]())
            }
        }, onError: { (err) in
            onError(err)
        })
    }
    func team(for teamId: Int, onSuccess: @escaping (_ team: Team)->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/teams/\(teamId)"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let teamJson = json["data"] as? [String: AnyObject]{
                let team = Team(dict: teamJson)
                onSuccess(team)
            }else{
                onError(NSError(domain: "api.response_error", code: 500, userInfo: ["message":"missing team data"]))
            }
        }, onError: { (err) in
            onError(err)
        })
    }
    func follow(team id: Int, onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/teams/\(id)/follow"
        processRequestTo(path: path, httpMethod: "PATCH", parameters: nil, onSuccess: { (json) in
            onSuccess()
        }, onError: { (err) in
            onError(err)
        })
    }
    func unfollow(team id: Int, onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/teams/\(id)/follow"
        processRequestTo(path: path, httpMethod: "DELETE", parameters: nil, onSuccess: { (json) in
            onSuccess()
        }, onError: { (err) in
            onError(err)
        })
    }
    
    //MARK: Games
    func gamesStarting(onSuccess: @escaping (_ games: [Game])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/games/starting"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            print("/////////////")
            print("JSON FILE:   \(json)")
            print("/////////////")
            
            /*
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone(abbreviation: "PST")
            if let d = formatter.date(from: json["begin"] as! String) {
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "YYYY-MM-dd h:mma"
                
                print("begin date: \(formatter1.string(from: d))")
            }
            
            if let d = formatter.date(from: json["end"] as! String) {
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "YYYY-MM-dd h:mma"
                
                print("end date: \(formatter1.string(from: d))")
            }
 */
            if let gamesJson = json["data"] as? [[String: AnyObject]]{
                var games = [Game]()
                for gameJson in gamesJson{
                    games.append(Game(dict: gameJson))
                }
                onSuccess(games)
            }else{
                onSuccess([Game]())
            }
        }, onError: { (err) in
            onError(err)
        })
    }
    
    func games(for date: Date, onSuccess: @escaping (_ games: [Game])->Void, onError: @escaping (_ error: NSError)->Void){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyyyy"
        
        let path = "/games/find/\(dateFormatter.string(from: date))"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let gamesJson = json["data"] as? [[String: AnyObject]]{
                var games = [Game]()
                for gameJson in gamesJson{
                    games.append(Game(dict: gameJson))
                }
                onSuccess(games)
            }else{
                onSuccess([Game]())
            }
        }, onError: { (err) in
            onError(err)
        })
    }
    func games(for id: Int, onSuccess: @escaping (_ game: Game)->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/games/\(id)"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let gamesJson = json["data"] as? [[String: AnyObject]]{
                for gameJson in gamesJson{
                    let game = Game(dict: gameJson)
                    onSuccess(game)
                    return
                }
            }
            onError(NSError(domain: "api.error", code: 500, userInfo: ["message":"invalud json"]))
        }, onError: { (err) in
            onError(err)
        })
    }
    func fanMeter(for game: Game, onSuccess: @escaping (_ value: Double)->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/games/\(game.id)/fanmeter"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            let val = (json["data"] as? Double) ?? 0.5
            onSuccess(val)
        }, onError: { (err) in
            onError(err)
        })
    }
    func fans(for game: Game, onSuccess: @escaping (_ users: [User])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/games/\(game.id)/fans"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            var users = [User]()
            if let usersJson = json["data"] as? [[String: AnyObject]]{
                for userJson in usersJson{
                    let u = User(dict: userJson)
                    if let p = userJson["pivot"] as? [String: AnyObject]{
                        u.pivot = UserFollowablePivot(dict: p)
                    }else if let tId = userJson["team_id"] as? Int{
                        u.pivot = UserFollowablePivot(itemA: tId, itemB: u.id, type: "Following")
                    }
                    users.append(u)
                }
            }
            onSuccess(users)
        }, onError: { (err) in
            onError(err)
        })
    }
    func news(for game: Game, onSuccess: @escaping (_ news: [News])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/games/\(game.id)/news"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            var news = [News]()
            if let newsesJson = json["data"] as? [[String: AnyObject]]{
                for newsJson in newsesJson{
                    let n = News(dict: newsJson)
                    news.append(n)
                }
            }
            onSuccess(news)
        }, onError: { (err) in
            onError(err)
        })
    }
    
    func events(for game: Game, onSuccess: @escaping (_ events: [Event])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/games/\(game.id)/events"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            var events = [Event]()
            if let eventsJsonArray = json["data"] as? [[String: AnyObject]]{
                for eventsJson in eventsJsonArray {
                    let n = Event(dict: eventsJson)
                    events.append(n)
                }
            }
            onSuccess(events)
        }, onError: { (err) in
            onError(err)
        })
    }

    //MARK: Posts
    func story(for game: Game, page: Int, onSuccess: @escaping (_ posts: [Post])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/games/\(game.id)/story/all?sort=created_at"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            guard let data = json["data"] as? [String: AnyObject] else {
                return onError(NSError(domain: "api.error", code: 403, userInfo: ["message":"invalid json"]))
            }
            guard let postsData = data["posts"] as? [String: AnyObject] else {
                return onError(NSError(domain: "api.error", code: 403, userInfo: ["message":"invalid json"]))
            }
            guard let postsJson = postsData["data"] as? [[String: AnyObject]] else {
                return onError(NSError(domain: "api.error", code: 403, userInfo: ["message":"invalid json"]))
            }
            
            var posts = [Post]()
            for postJson in postsJson{
                posts.append(Post(dict: postJson))
            }
            onSuccess(posts)
        }, onError: { (err) in
            onError(err)
        })
    }
    
    func like(post id: Int, onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/post/\(id)/like"
        processRequestTo(path: path, httpMethod: "PATCH", parameters: nil, onSuccess: { (json) in
            onSuccess()
        }, onError: { (err) in
            onError(err)
        })
    }
    func unlike(post id: Int, onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/post/\(id)/like"
        processRequestTo(path: path, httpMethod: "DELETE", parameters: nil, onSuccess: { (json) in
            onSuccess()
        }, onError: { (err) in
            onError(err)
        })
    }
    
    func report(post id: Int, onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/post/\(id)/report"
        processRequestTo(path: path, httpMethod: "PATCH", parameters: nil, onSuccess: { (json) in
            
            var reports = UserDefaults.standard.object(forKey:"reports") as? [Int] ?? [Int]()
            reports.append(id)
            UserDefaults.standard.set(reports, forKey: "reports")
            
            onSuccess()
        }, onError: { (err) in
            onError(err)
        })
    }
    
    func singlePost(postId: Int, onSuccess: @escaping (_ post: Post)->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/post/\(postId)"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (data) in
            guard let postData = data["data"] as? [String: AnyObject] else {
                return onError(NSError(domain: "api.error", code: 403, userInfo: ["message":"invalid json"]))
            }
            
            let post = Post(dict: postData)
            onSuccess(post)

        }, onError: { (err) in
            onError(err)
        })
    }
    
    func friendsPosts(onSuccess: @escaping (_ posts: [Post])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/post/friends/"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (data) in
            guard let postsData = data["data"] as? [[String: AnyObject]] else {
                return onError(NSError(domain: "api.error", code: 403, userInfo: ["message":"invalid json"]))
            }

            var posts: [Post] = []
            for postData in postsData {
                let post = Post(dict: postData)
                posts.append(post)
            }

            onSuccess(posts)

        }, onError: { (err) in
            onError(err)
        })
    }

    //MARK: Search
    func search(with query: String, onSuccess: @escaping (_ objects: [DBObject])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/discover/search?q=\(query)"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let dataJson = json["data"] as? [String: AnyObject]{
                var objects = [DBObject]()
                
                if let usersJson = dataJson["users"] as? [[String: AnyObject]]{
                    for userJson in usersJson{
                        objects.append(User(dict: userJson))
                    }
                }
                
                if let teamsJson = dataJson["teams"] as? [[String: AnyObject]]{
                    for (i, teamJson) in teamsJson.enumerated(){
                        let j = (i+1)*2-1
                        if j < objects.count{
                            objects.insert(Team(dict: teamJson), at: j)
                        }else{
                            objects.append(Team(dict: teamJson))
                        }
                    }
                }

                onSuccess(objects)
            }else{
                onSuccess([DBObject]())
            }
        }, onError: { (err) in
            onError(err)
        })
    }
    
    func searchGames(for date: Date, sport: Sport, onSuccess: @escaping (_ games: [Game])->Void, onError: @escaping (_ error: NSError)->Void){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyyyy"
        
        print("important date: \(dateFormatter.string(from: date))")
        
        let path = "/discover/games/\(dateFormatter.string(from: date))?sport_id=\(sport.rawValue)"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let gamesJson = json["data"] as? [[String: AnyObject]]{
                var games = [Game]()
                for gameJson in gamesJson{
                    games.append(Game(dict: gameJson))
                }
                games = games.removeDuds
                onSuccess(games)
            }else{
                onSuccess([Game]())
            }
        }, onError: { (err) in
            onError(err)
        })
    }
    func searchGames(for date: Date, onSuccess: @escaping (_ games: [Game])->Void, onError: @escaping (_ error: NSError)->Void){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyyyy"
        
        let path = "/discover/games/\(dateFormatter.string(from: date))"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let gamesJson = json["data"] as? [[String: AnyObject]]{
                var games = [Game]()
                for gameJson in gamesJson{
                    games.append(Game(dict: gameJson))
                }
                games = games.removeDuds
                onSuccess(games)
            }else{
                onSuccess([Game]())
            }
        }, onError: { (err) in
            onError(err)
        })
    }
    
    //MARK: Trending
    func trending(onSuccess: @escaping (_ objects: [DBObject])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/discover/trending"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let dataJson = json["data"] as? [String: AnyObject]{
                var objects = [DBObject]()
                
                if let usersJson = dataJson["users"] as? [[String: AnyObject]]{
                    for userJson in usersJson{
                        objects.append(User(dict: userJson))
                    }
                }
                
                if let teamsJson = dataJson["teams"] as? [[String: AnyObject]]{
                    for (i, teamJson) in teamsJson.enumerated(){
                        let j = (i+1)*2-1
                        if j < objects.count{
                            objects.insert(Team(dict: teamJson), at: j)
                        }else{
                            objects.append(Team(dict: teamJson))
                        }
                    }
                }

                onSuccess(objects)
            }else{
                onSuccess([DBObject]())
            }
        }, onError: { (err) in
            onError(err)
        })
    }

    //MARK: Nearby
    func nearby(onSuccess: @escaping (_ objects: [DBObject])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/discover/nearby"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let dataJson = json["data"] as? [String: AnyObject]{
                var objects = [DBObject]()
                
                if let usersJson = dataJson["users"] as? [[String: AnyObject]]{
                    for userJson in usersJson{
                        objects.append(User(dict: userJson))
                    }
                }
                
                if let teamsJson = dataJson["teams"] as? [[String: AnyObject]]{
                    for (i, teamJson) in teamsJson.enumerated(){
                        let j = (i+1)*2-1
                        if j < objects.count{
                            objects.insert(Team(dict: teamJson), at: j)
                        }else{
                            objects.append(Team(dict: teamJson))
                        }
                    }
                }

                onSuccess(objects)
            }else{
                onSuccess([DBObject]())
            }
        }, onError: { (err) in
            onError(err)
        })
    }

    //MARK: Upload
    func uploadPhoto(contentHeight: CGFloat? = nil, game: Game, team: Team, photo: UIImage, onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        
        //let imgData = UIImageJPEGRepresentation(photo, 0.2)!
        let imgData = photo.jpegData(compressionQuality: 0.2)!
        var params = ["game_id": "\(game.id)", "team_id": "\(team.id)"]
        
        if let contentHeight = contentHeight {
            params["content_height"] = "\(contentHeight)"
        }
        
        let headers: HTTPHeaders! = ["Accept": "application/json", "Authorization": "Bearer \(accessToken)"]
        
        let path = "/post"
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imgData, withName: "file",fileName: "photo.jpg", mimeType: "image/jpg")
            for (key, value) in params {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: "\(BASE_URL)\(path)", method: .post, headers: headers) { (result) in
            switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                        let code = response.response?.statusCode ?? 0
                        if code == 200{
                            onSuccess()
                        }else{
                            onError(NSError(domain: "api.error", code: code, userInfo: ["message":"invalid response code"]))
                        }
                        }
                
                case .failure(let encodingError):
                    print(encodingError)
            }
        }
    }
    func uploadVideo(contentHeight: CGFloat? = nil, game: Game, team: Team, video: URL, thumbnail: UIImage, onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        
        let videoData = try! Data.init(contentsOf: video)
        let imageData = thumbnail.pngData() ?? Data()
        var params = ["game_id": "\(game.id)", "team_id": "\(team.id)"]
        
        if let contentHeight = contentHeight {
            params["content_height"] = "\(contentHeight)"
        }
        
        let headers: HTTPHeaders! = ["Accept": "application/json", "Authorization": "Bearer \(accessToken)"]
        
        let path = "/post"
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(videoData, withName: "file",fileName: "video.mov", mimeType: "video/mov")
            multipartFormData.append(imageData, withName: "thumb",fileName: "thumbnail.png", mimeType: "image/png")
            for (key, value) in params {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: "\(BASE_URL)\(path)", method: .post, headers: headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    let code = response.response?.statusCode ?? 0
                    if code == 200{
                        onSuccess()
                    }else{
                        onError(NSError(domain: "api.error", code: code, userInfo: ["message":"invalid response code"]))
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    func deletePost(post id: Int, onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/post/\(id)"
        processRequestTo(path: path, httpMethod: "DELETE", parameters: nil, onSuccess: { (json) in
            onSuccess()
        }, onError: { (err) in
            onError(err)
        })
    }
    
    //MARK: Timeline
    func timeline(page: Int, onSuccess: @escaping (_ posts: [Post])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/post/timeline?sort=created_at&page=\(page)"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            guard let postsData = json["posts"] as? [String: AnyObject] else {
                return onError(NSError(domain: "api.error", code: 403, userInfo: ["message":"invalid json"]))
            }
            guard let postsJson = postsData["data"] as? [[String: AnyObject]] else {
                return onError(NSError(domain: "api.error", code: 403, userInfo: ["message":"invalid json"]))
            }
            
            var posts = [Post]()
            for postJson in postsJson{
                posts.append(Post(dict: postJson))
            }
            onSuccess(posts)
        }, onError: { (err) in
            onError(err)
        })
    }
    
    //MARK: Comments
    func comments(for post: Post, page: Int, onSuccess: @escaping (_ comments: [Comment])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/post/\(post.id)/comment"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            guard let commentsRawData = json["data"] as? [String: AnyObject] else {
                return onError(NSError(domain: "api.error", code: 403, userInfo: ["message":"invalid json"]))
            }
            guard let commentsJson = commentsRawData["data"] as? [[String: AnyObject]] else {
                return onError(NSError(domain: "api.error", code: 403, userInfo: ["message":"invalid json"]))
            }
            
            var comments = [Comment]()
            for commentJson in commentsJson{
                comments.append(Comment(dict: commentJson))
            }
            onSuccess(comments)
        }, onError: { (err) in
            onError(err)
        })
    }
    
    func postComment(for post: Post, text: String, onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/post/\(post.id)/comment"
        let params = ["text": text]
        
        processRequestTo(path: path, httpMethod: "POST", parameters: params, onSuccess: { (json) in
            onSuccess()
        }, onError: { (err) in
            onError(err)
        })
    }
    
    func deleteComment(for post: Post, comment: Comment, onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/post/\(post.id)/comment/\(comment.id)"
        
        processRequestTo(path: path, httpMethod: "DELETE", parameters: nil, onSuccess: { (json) in
            onSuccess()
        }, onError: { (err) in
            onError(err)
        })
    }
    
    //MARK: Streaming
    func streamInfo(onSuccess: @escaping (_ info: [String: AnyObject], _ status: String)->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/post/live"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            if let data = json["data"] as? [String: AnyObject]{
                if let info = data["info"] as? [String: AnyObject]{
                    if let sDict = data["state"] as? [String:AnyObject],
                        let lsDict = sDict["live_stream"] as? [String: AnyObject],
                        let status = lsDict["state"] as? String{
                        print("Live Status: \(status)")
                        
                        onSuccess(info, status)
                    }
                }
            }
            onError(NSError(domain: "api.error", code: 403, userInfo: ["message":"invalid json"]))
        }, onError: { (err) in
            onError(err)
        })
    }
    func startStream(onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        return
        let path = "/post/live/start"
        processRequestTo(path: path, httpMethod: "POST", parameters: nil, onSuccess: { (json) in
            onSuccess()
        }, onError: { (err) in
            onError(err)
        })
    }
    func stopStream(onSuccess: @escaping ()->Void, onError: @escaping (_ error: NSError)->Void){
        return
        let path = "/post/live/stop"
        processRequestTo(path: path, httpMethod: "POST", parameters: nil, onSuccess: { (json) in
            onSuccess()
        }, onError: { (err) in
            onError(err)
        })
    }
    func viewStreaming(page: Int, onSuccess: @escaping (_ users: [User])->Void, onError: @escaping (_ error: NSError)->Void){
        let path = "/post/live/view"
        processRequestTo(path: path, httpMethod: "GET", parameters: nil, onSuccess: { (json) in
            guard let usersData = json["data"] as? [String: AnyObject] else {
                return onError(NSError(domain: "api.error", code: 403, userInfo: ["message":"invalid json"]))
            }
            guard let usersJson = usersData["data"] as? [[String: AnyObject]] else {
                return onError(NSError(domain: "api.error", code: 403, userInfo: ["message":"invalid json"]))
            }
            
            var users = [User]()
            for userJson in usersJson{
                users.append(User(dict: userJson))
            }
            onSuccess(users)
        }, onError: { (err) in
            onError(err)
        })
    }
    
    //MARK: - Run Request
    func processRequestTo(path: String, httpMethod: String, parameters: [String:String]?, onSuccess: @escaping (_ json: [String: AnyObject])->Void, onError: @escaping (_ error: NSError)->Void, useAppSecret: Bool = false){
        if httpMethod == "GET"{
            if let json = CacheManager.shared.uncacheDict(name: path, params: parameters){
                onSuccess(json)
                return
            }
        }
        
        let headers: HTTPHeaders! = ["Accept": "application/json", "Authorization": "Bearer \(accessToken)"]
        
        let start = Date()
        Alamofire.request("\(BASE_URL)\(path)", method: HTTPMethod.init(rawValue: httpMethod)!, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (json) in
            let code = json.response?.statusCode ?? 500
            print("[\(httpMethod)] \(path) : \(Date().timeIntervalSince(start))s \(code)")
            if let json = json.result.value as? [String: AnyObject]{
                if json["exception"] != nil{
                    onError(NSError(domain: "api.error", code: 500, userInfo: ["message":"internal server error exception thrown"]))
                    return
                }
                if code != 200 && code != 201{
                    let message = json["message"] as? String ?? "<msg>"
                    onError(NSError(domain: "api.error", code: 500, userInfo: ["message":"server returned status code \(code)", "server_message": message]))
                    return
                }
                
                if let error = json["error"] as? [String: String]{ //Make sure there is no error
                    onError(NSError(domain: "api.error", code: 500, userInfo: ["message":error.values.joined(separator: ", ")]))
                }else{
                    if httpMethod == "GET"{
                        CacheManager.shared.cacheDict(name: path, params: parameters, json: json)
                    }
                    
                    var nj = json
                    nj["status_code"] = String(code) as AnyObject
                    onSuccess(nj)
                }
            }else{
                onError(NSError(domain: "api.error", code: 500, userInfo: ["message":"invalud json"]))
            }
        }.responseString { (data) in
//            print(data.result.value ?? "")
        }
    }
    
    //MARK: - Util
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }

}
