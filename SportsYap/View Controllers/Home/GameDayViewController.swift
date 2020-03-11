//
//  GameDayViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 2/6/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import SVWebViewController
import SafariServices

class GameDayViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var filter = "fans"
    var game: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApiManager.shared.news(for: self.game, onSuccess: { (news) in
            self.game.news = news
            self.tableView.reloadData()
        }, onError: voidErr)
        
        ApiManager.shared.games(for: self.game.id, onSuccess: { (game) in
            self.game.challenge = game.challenge
            self.tableView.reloadData()
        }, onError: voidErr)
        
        ApiManager.shared.fanMeter(for: self.game, onSuccess: { (val) in
            self.game.fanMeter = val
            self.tableView.reloadData()
        }) { (err) in }
        
        singlePost = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global(qos: .background).async {
            ApiManager.shared.fans(for: self.game, onSuccess: { (users) in
                self.game.fans = users
                
                print("the count")
                print(self.game.fans.count)
                print(self.game.fans.atGame.count)
                print(self.game.fans.watchingGame.count)
                print("the count")
                
                self.tableView.reloadData()
            }) { (err) in }
        }
    }
    
    //MARK: IBActions
    @IBAction func backBttnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Nav
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ShotViewController{
            vc.game = game
        }else if let vc = segue.destination as? ProfileViewController, let user = sender as? User{
            vc.user = user
        }else if let vc = segue.destination as? ChallengeViewController, let challenge = game.challenge{
            vc.challenge = challenge
            vc.game = game
        }
    }
    
    //MARK: Util
    func timeAgoSinceDate(date: Date) -> String {
        let dif = Int(abs(date.timeIntervalSinceNow))
        let timescale: [[Any]] = [
            [1, "sec"],
            [60, "min"],
            [3600, "hr"],
            [86400, "day"],
            [2592000, "mon"],
            [31536000, "year"],
            [Int.max, "year"],
        ]
        
        var lastKey = 1
        var lastVal = ""
        for step in timescale{
            if let key = step[0] as? Int, let value = step[1] as? String{
                if dif < key{
                    let amount = Int(Double(dif)/Double(lastKey))
                    return "\(amount) \(lastVal)" + ((amount > 1) ? "s" : "")
                }
                lastKey = key
                lastVal = value
            }
        }
        
        return "now"
    }
}

extension GameDayViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return game.challenge != nil ? 1 : 0
        }else if section == 1 || section == 2{
            return 1
        }else if section == 3{
            if filter == "fans"{
                return game.fans.verified.count
            }else {
                return game.news.count
            }
        }else if section == 4{
            if filter == "fans" {
                return game.fans.atGame.count
            }
        } else if section == 5 {
            if filter == "fans" {
                return game.fans.watchingGame.count
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "challengeCell"){
                return cell
            }
        }else if indexPath.section == 1{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "gameCard") as? GameDayGameTableViewCell{
                cell.load(game: game)
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            }
        }else if indexPath.section == 2{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell") as? GameDayFilterMenuTableViewCell{
                cell.delegate = self
                if filter == "fans"{
                    cell.newsBttn.setTitleColor(UIColor(hex: "999999"), for: .normal)
                    cell.fansBttn.setTitleColor(UIColor(hex: "272727"), for: .normal)
                }else{
                    cell.newsBttn.setTitleColor(UIColor(hex: "272727"), for: .normal)
                    cell.fansBttn.setTitleColor(UIColor(hex: "999999"), for: .normal)
                }
                cell.selectionStyle = .none
                return cell
            }
        }else if indexPath.section == 3 && filter == "news"{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell") as? GameDayNewsTableViewCell{
                let news = game.news[indexPath.row]
                cell.titleLbl.text = news.title
                cell.detailLbl.text = "\(news.author)" + (news.author == "" ? "" : " ∙ ") + timeAgoSinceDate(date: news.createdAt)
                cell.activityIndicator.startAnimating()
                if let url = news.thumbnail{
                    cell.coverPhoto.imageFromUrl(url: url)
                }else{
                    cell.coverPhoto.image = nil
                }
                return cell
            }
        }else if (indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5) && filter == "fans" {
            
            var user: User
            
            if indexPath.section == 3 {
                user = game.fans.verified[indexPath.row]
            } else if indexPath.section == 4 {
                user = game.fans.atGame[indexPath.row]
            } else {
                user = game.fans.watchingGame[indexPath.row]
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "fanCell") as? GameDayFanTableViewCell{
                cell.nameLbl.text = user.name
                cell.isVerifiedImageView.alpha = user.verified ? 1 : 0
                if let url = user.profileImage{
                    cell.profileImageView.imageFromUrl(url: url)
                }else{
                    cell.profileImageView.image = #imageLiteral(resourceName: "default-profile")
                }
                if user.pivot?.itemAId == game.awayTeam.id{
                    cell.teamNameLbl.text = game.awayTeam.name
                }else if user.pivot?.itemAId == game.homeTeam.id{
                    cell.teamNameLbl.text = game.homeTeam.name
                }else{
                    cell.teamNameLbl.text = ""
                }
                if let date = user.pivot?.createdAt{
                    cell.timeLbl.text = timeAgoSinceDate(date: date)
                }else{
                    cell.timeLbl.text = ""
                }
                return cell
            }
        }
    
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
            case 0: return 95
            case 1: return 240
            case 2: return 25
            case 3, 4, 5:
                return filter == "fans" ? 52 : 135
            default: return 50
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0{
            self.performSegue(withIdentifier: "showChallenge", sender: nil)
        }else if indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5{
            if filter == "fans"{
                
                var user: User
                
                if indexPath.section == 3 {
                    user = game.fans.verified[indexPath.row]
                } else if indexPath.section == 4 {
                    user = game.fans.atGame[indexPath.row]
                } else {
                    user = game.fans.watchingGame[indexPath.row]
                }
                self.performSegue(withIdentifier: "showProfile", sender: user)
            }else if filter == "news"{
                if let url = game.news[indexPath.row].url{
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if filter == "fans"{
            if section == 3 && game.hasFrontRow{
                return 60
            }else if section == 4 || section == 5 {
                return 60
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lbl = UILabel(frame: CGRect(x: 25, y: 20, width: 200, height: 20))
        lbl.text = ["", "", "", "FRONT ROW", "FRIENDS AT THE GAME", "WATCHING THE GAME"][section]
        lbl.textColor = UIColor(hex: "7F7F7F")
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        headerView.addSubview(lbl)
        
        return headerView
    }
}

extension GameDayViewController: GameDayFilterMenuTableViewCellDelegate{
    func menuChanged(to filter: String) {
        self.filter = filter
        tableView.reloadData()
    }
}

extension GameDayViewController: GameDayGameTableViewCellDelegate{
    func enterFieldBttnPressed(){
        if User.me.likedPosts.count == 0 {
            ApiManager.shared.likes(user: User.me.id)
        }
        
        self.performSegue(withIdentifier: "showField", sender: nil)
    }
    func addToFieldBttnPressed(){
        TagGameViewController.preselectedGame = game
        ParentScrollingViewController.shared.scrollToCamera()
    }
}
