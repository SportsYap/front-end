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
    
    @IBOutlet weak var challengeView: UIView!
    @IBOutlet weak var challengeViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var awayTownLabel: UILabel!
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var awayScoreLabel: UILabel!
    
    @IBOutlet weak var homeTownLabel: UILabel!
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var homeScoreLabel: UILabel!
    
    @IBOutlet weak var homePrimaryColorView: UIView!
    @IBOutlet weak var homeSecondaryColorView: UIView!
    @IBOutlet weak var awayPrimaryColorView: UIView!
    @IBOutlet weak var awaySecondaryColorView: UIView!

    @IBOutlet weak var sportBackgroundImageView: UIImageView!
    
    @IBOutlet weak var fanMeterContainerView: UIView!
    @IBOutlet weak var fanMeterLeading: NSLayoutConstraint!

    @IBOutlet weak var enterFieldButton: UIButton!

    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var fansButton: UIButton!
    @IBOutlet weak var eventsButton: UIButton!
    @IBOutlet weak var newsButton : UIButton!
    
    @IBOutlet weak var indicatorViewLeading: NSLayoutConstraint!

    var game: Game!
    
    enum TabItems: Int {
        case Fans = 0
        case Events
        case News
    }
    private var selectedTabItem: TabItems = .Fans

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApiManager.shared.news(for: self.game, onSuccess: { (news) in
            self.game.news = news
            if self.selectedTabItem == .News {
                self.tableView.reloadData()
            }
        }, onError: voidErr)
        
        ApiManager.shared.events(for: self.game, onSuccess: { (events1, events2) in
            self.game.events1 = events1
            self.game.events2 = events2
            if self.selectedTabItem == .Events {
                self.tableView.reloadData()
            }
        }, onError: voidErr)
        
        ApiManager.shared.games(for: self.game.id, onSuccess: { (game) in
            self.game.challenge = game.challenge
            if self.selectedTabItem == .Fans {
                self.tableView.reloadData()
            }
        }, onError: voidErr)
        
        ApiManager.shared.fanMeter(for: self.game, onSuccess: { (val) in
            self.game.fanMeter = val
            self.displayGameInfo()
        }) { (err) in }
        
        singlePost = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        displayGameInfo()
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EnterFieldViewController {
            vc.game = game
        } else if let vc = segue.destination as? OtherProfileViewController, let user = sender as? User {
            vc.user = user
        } else if let vc = segue.destination as? ChallengeViewController, let challenge = game.challenge {
            vc.challenge = challenge
            vc.game = game
        }
    }
}

extension GameDayViewController {
    private func displayGameInfo() {
        if (game.challenge != nil) {
            challengeView.isHidden = false
            challengeViewHeight.constant = 90
        } else {
            challengeView.isHidden = true
            challengeViewHeight.constant = 0
        }
        
        let headerView = tableView.tableHeaderView!
        headerView.layoutIfNeeded()
        
        var frame = headerView.frame
        frame.size.height = tabView.frame.origin.y + tabView.frame.size.height
        headerView.frame = frame
        tableView.tableHeaderView = headerView
        
        tableView.layoutIfNeeded()
        tableView.beginUpdates()
        tableView.endUpdates()
        
        titleLabel.text = game.venue.name
        timeLabel.text = game.startTime
        
        awayTownLabel.text = game.awayTeam.homeTown
        awayTeamNameLabel.text = game.awayTeam.name
        awayScoreLabel.text = "\(game.awayScore)"
        awayPrimaryColorView.backgroundColor = game.awayTeam.primaryColor
        awaySecondaryColorView.backgroundColor = game.awayTeam.secondaryColor
        
        homeTownLabel.text = game.homeTeam.homeTown
        homeTeamNameLabel.text = game.homeTeam.name
        homeScoreLabel.text = "\(game.homeScore)"
        homePrimaryColorView.backgroundColor = game.homeTeam.primaryColor
        homeSecondaryColorView.backgroundColor = game.homeTeam.secondaryColor

        sportBackgroundImageView.image = game.sport.image
        
        let val = game.fanMeter ?? 0.5
        fanMeterLeading.constant = (UIScreen.main.bounds.width - 54) * CGFloat(val)
        
        enterFieldButton.layer.borderWidth = 2
        enterFieldButton.layer.borderColor = UIColor(hex: "009BFF").cgColor
        enterFieldButton.layer.cornerRadius = 5
        enterFieldButton.layer.masksToBounds = true
        enterFieldButton.layer.maskedCorners = [.layerMinXMaxYCorner]
    }
}

extension GameDayViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch selectedTabItem {
        case .Fans:
            return 4
        case .Events:
            return 1
        case .News:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedTabItem {
        case .Fans:
            if section == 0 {
                return game.fans.verified.count
            } else if section == 1 {
                return game.fans.atGame.count
            } else if section == 2 {
                return game.fans.watchingGame.count
            } else {
                return game.fans.isEmpty ? 1 : 0
            }
        case .Events:
            var count = 0
            if !game.events1.isEmpty {
                count += game.events1.count + 1
            }
            if !game.events2.isEmpty {
                count += game.events2.count + 1
            }
            return max(count, 1)
        case .News:
            return max(game.news.count, 1)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedTabItem {
        case .News:
            if game.news.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noCell")!
                cell.textLabel?.text = NSLocalizedString("No News", comment: "")
                return cell
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell") as? GameDayNewsTableViewCell {
                let news = game.news[indexPath.row]
                cell.news = news
                return cell
            }
        case .Fans:
            let user: User
            if indexPath.section == 0 {
                user = game.fans.verified[indexPath.row]
            } else if indexPath.section == 1 {
                user = game.fans.atGame[indexPath.row]
            } else if indexPath.section == 2 {
                user = game.fans.watchingGame[indexPath.row]
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noCell")!
                cell.textLabel?.text = NSLocalizedString("No Fans", comment: "")
                return cell
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "fanCell") as? GameDayFanTableViewCell {
                cell.game = game
                cell.fan = user
                return cell
            }
        case .Events:
            if game.events1.isEmpty && game.events2.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noCell")!
                cell.textLabel?.text = NSLocalizedString("No Events", comment: "")
                return cell
            }

            var row = indexPath.row
            if !game.events1.isEmpty {
                if row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "eventHeaderCell") as! GameDayEventHeaderTableViewCell
                    cell.team = game.homeTeam
                    return cell
                }

                row -= 1
                if row < game.events1.count {
                    let event = game.events1[row]
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as? GameDayEventTableViewCell {
                        cell.event = event
                        return cell
                    }
                }
                
                row -= game.events1.count
            }

            if !game.events2.isEmpty {
                if row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "eventHeaderCell") as! GameDayEventHeaderTableViewCell
                    cell.team = game.awayTeam
                    return cell
                }

                row -= 1
                if row < game.events2.count {
                    let event = game.events2[row]
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as? GameDayEventTableViewCell {
                        cell.event = event
                        return cell
                    }
                }
            }
        }
    
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch selectedTabItem {
        case .Fans:
            return game.fans.isEmpty ? 180 : 62
        case .Events:
            if game.events1.isEmpty && game.events2.isEmpty {
                return 180
            }
            
            var row = indexPath.row
            if !game.events1.isEmpty {
                if row == 0 {
                    return 44
                }

                row -= 1
                if row < game.events1.count {
                    return 166
                }
                
                row -= game.events1.count
            }

            if !game.events2.isEmpty {
                if row == 0 {
                    return 44
                }

                row -= 1
                if row < game.events2.count {
                    return 166
                }
            }
            return 0
        case .News:
            return game.news.isEmpty ? 180 : 79
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedTabItem == .Fans {
            if game.fans.isEmpty {
                return
            }
            
            let user: User
            if indexPath.section == 0 {
                user = game.fans.verified[indexPath.row]
            } else if indexPath.section == 1 {
                user = game.fans.atGame[indexPath.row]
            } else if indexPath.section == 2 {
                user = game.fans.watchingGame[indexPath.row]
            } else {
                return
            }

            if user.id == User.me.id {
                performSegue(withIdentifier: "showProfile", sender: user)
            } else {
                performSegue(withIdentifier: "showOtherProfile", sender: user)
            }
        } else if selectedTabItem == .News {
            if game.news.isEmpty {
                return
            }
            
            if let url = game.news[indexPath.row].url {
                UIApplication.shared.open(url)
            }
        } else if selectedTabItem == .Events {
            if game.events1.isEmpty && game.events2.isEmpty {
                return
            }
            
            var row = indexPath.row
            if !game.events1.isEmpty {
                if row == 0 {
                    return
                }

                row -= 1
                if row < game.events1.count {
                    let event = game.events1[row]
                    if let url = event.url {
                        UIApplication.shared.open(url)
                    }
                }
                
                row -= game.events1.count
            }

            if !game.events2.isEmpty {
                if row == 0 {
                    return
                }

                row -= 1
                if row < game.events2.count {
                    let event = game.events2[row]
                    if let url = event.url {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch selectedTabItem {
        case .Fans:
            if section == 0 {
                return game.hasFrontRow ? 42 : 0
            } else if section == 1 {
                return game.fans.atGame.isEmpty ? 0 : 42
            } else if section == 2 {
                return game.fans.watchingGame.isEmpty ? 0 : 42
            } else {
                return 0
            }
        case .Events:
            return (game.events1.isEmpty && game.events2.isEmpty) ? 0 : 42
        case .News:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title: String? = nil
        switch selectedTabItem {
        case .Fans:
            title = [NSLocalizedString("FRONT ROW", comment: ""),
                NSLocalizedString("FRIENDS AT THE GAME", comment: ""),
                NSLocalizedString("WATCHING THE GAME", comment: "")][section]
        case .Events:
            title = NSLocalizedString("PRE-GAME", comment: "")
        case .News:
            break
        }
        
        if let title = title {
            let titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.bounds.size.width, height: 42))
            titleLabel.text = title
            titleLabel.textColor = UIColor(hex: "1F263A")
            titleLabel.font = UIFont.systemFont(ofSize: 12)
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 42))
            headerView.addSubview(titleLabel)
            
            return headerView
        }
        return nil
    }
}

//MARK: IBActions
extension GameDayViewController {
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onChallengeGame(_ sender: Any) {
        performSegue(withIdentifier: "showChallenge", sender: nil)
    }

    @IBAction func onEnterField(_ sender: UIButton) {
        if User.me.likedPosts.count == 0 {
            ApiManager.shared.likes(user: User.me.id)
        }
        
        performSegue(withIdentifier: "showField", sender: nil)
    }
    
    @IBAction func onAddShot(_ sender: UIButton) {
        TagGameViewController.preselectedGame = game
        ParentScrollingViewController.shared.scrollToCamera()
    }
    
    @IBAction func onFans(_ sender: Any) {
        if selectedTabItem == .Fans {
            return
        }
        
        UIView.animate(withDuration: 0.1, animations: {
            self.indicatorViewLeading.constant = self.fansButton.frame.origin.x
            self.tabView.layoutIfNeeded()
        }) { (_) in
            self.fansButton.setTitleColor(UIColor(hex: "009BFF"), for: .normal)
            self.eventsButton.setTitleColor(UIColor(hex: "1F263A"), for: .normal)
            self.newsButton.setTitleColor(UIColor(hex: "1F263A"), for: .normal)

            self.selectedTabItem = .Fans
            self.tableView.reloadData()
        }
    }
    
    @IBAction func onEvents(_ sender: Any) {
        if selectedTabItem == .Events {
            return
        }
        
        UIView.animate(withDuration: 0.1, animations: {
            self.indicatorViewLeading.constant = self.eventsButton.frame.origin.x
            self.tabView.layoutIfNeeded()
        }) { (_) in
            self.fansButton.setTitleColor(UIColor(hex: "1F263A"), for: .normal)
            self.eventsButton.setTitleColor(UIColor(hex: "009BFF"), for: .normal)
            self.newsButton.setTitleColor(UIColor(hex: "1F263A"), for: .normal)

            self.selectedTabItem = .Events
            self.tableView.reloadData()
        }
    }
    
    @IBAction func onNews(_ sender: Any) {
        if selectedTabItem == .News {
            return
        }

        UIView.animate(withDuration: 0.1, animations: {
            self.indicatorViewLeading.constant = self.newsButton.frame.origin.x
            self.tabView.layoutIfNeeded()
        }) { (_) in
            self.fansButton.setTitleColor(UIColor(hex: "1F263A"), for: .normal)
            self.eventsButton.setTitleColor(UIColor(hex: "1F263A"), for: .normal)
            self.newsButton.setTitleColor(UIColor(hex: "009BFF"), for: .normal)

            self.selectedTabItem = .News
            self.tableView.reloadData()
        }
    }
}
