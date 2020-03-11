//
//  DiscoverViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 2/6/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import Alamofire
import Segmentio

protocol DiscoverTableViewCellDelegate {
    func followBttnPressed(team: Team)
    func followBttnPressed(user: User)
}

enum SearchType {
    case users
    case teams
}

class DiscoverViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var sportTypeBgViews: [UIView]!
    @IBOutlet var cancelBttn: UIButton!
    @IBOutlet weak var leftDateArrowImageView: UIImageView!
    @IBOutlet weak var rightDateArrowImageView: UIImageView!
    @IBOutlet weak var leftDateBttn: UIButton!
    @IBOutlet weak var rightDateBttn: UIButton!
    
    @IBOutlet var noGamesView: UIView!
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet var gamesCollectionView: UICollectionView!
    
    @IBOutlet weak var segmentio: Segmentio!
        
    var selectedSport = Sport.football
    
    var searchObjs = [DBObject]()
    var userObjs = [DBObject]()
    var teamObjs = [DBObject]()
    var games = [Game]()
    
    var date = Date(){
        didSet{
            let formatter = DateFormatter()
            formatter.dateFormat = "eeee, MMMM d"
            dateLbl.text = formatter.string(from: date).capitalized
            
            loadGames()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentio()

        selectedSport = .football
        date = Date()
    }
    
    func setupSegmentio() {
        segmentio.selectedSegmentioIndex = 0
                
        view.addSubview(segmentio)
        view.sendSubviewToBack(segmentio)
        
        var content = [SegmentioItem]()
        
        let usersItem = SegmentioItem(title: "Users", image: nil)
        let teamsItem = SegmentioItem(title: "Teams", image: nil)
        content.append(usersItem)
        content.append(teamsItem)
        
        let indicatorOptions = SegmentioIndicatorOptions(
            type: .bottom,
            ratio: 1,
            height: 1.5,
            color: .black
        )
        
        let horizontalOptions = SegmentioHorizontalSeparatorOptions(
            type: SegmentioHorizontalSeparatorType.topAndBottom,
            height: 1,
            color: .lightGray
        )
        
        let verticalOptions = SegmentioVerticalSeparatorOptions(
            ratio: 0.1, // from 0.1 to 1
            color: .clear
        )
                
        let options = SegmentioOptions(
            backgroundColor: .white,
            segmentPosition: SegmentioPosition.dynamic,
            scrollEnabled: false,
            indicatorOptions: indicatorOptions,
            horizontalSeparatorOptions: horizontalOptions,
            verticalSeparatorOptions: verticalOptions,
            imageContentMode: .center,
            labelTextAlignment: .center
        )
                
        segmentio.setup(
            content: content,
            style: SegmentioStyle.onlyLabel,
            options: options
        )
        
        segmentio.valueDidChange = { segmentio, segmentIndex in
            self.searchTableView.reloadData()
        }
    }
    
    func loadGames(){
        ApiManager.shared.searchGames(for: date, sport: selectedSport, onSuccess: { (games) in
            self.games = games
            
            var index = 0
            
            // doing my best to get rid of duplicate games
            for game in self.games {
                if game.winningTeamId == 0 {
                    // most likely a duplicate game since no winningTeamId is 0
                    //self.games.remove(at: index)
                    index += 1
                    
                } else if game.awayScore == 0 && game.homeScore == 0 {
                    if self.games.contains(where: {$0.homeTeam.id == game.homeTeam.id
                        && $0.awayTeam.id == game.awayTeam.id
                        && $0.id != game.id}) {
                        
                        if game.start < Date() {
                            self.games.remove(at: index)
                        }
                                                
                    }
                }
                else {
                    index += 1
                }
            }
            
            // filter out duplicate games with different start times
            var duplicateIndex = 0
            for game in self.games {
                guard game.awayScore == 0 && game.homeScore == 0 else {
                    duplicateIndex += 1
                    continue
                }
                
                if self.games.contains(where: {$0.homeTeam.id == game.homeTeam.id
                    && $0.awayTeam.id == game.awayTeam.id
                    && $0.id != game.id
                    && $0.id > game.id}) {
                    
                    self.games.remove(at: duplicateIndex)
                } else {
                    duplicateIndex += 1
                }
            }
            
            self.gamesCollectionView.reloadData()
            self.noGamesView.alpha = games.count == 0 ? 1 : 0
        }) { (err) in }
    }
    
    //MARK: IBAction
    @IBAction func cancelBttnPressed(_ sender: Any) {
        searchBar.resignFirstResponder()
        cancelBttn.alpha = 0
        searchObjs = [DBObject]()
        userObjs = [DBObject]()
        teamObjs = [DBObject]()
        searchTableView.reloadData()
        searchBar.text = ""
        UIView.animate(withDuration: 0.5) {
            self.searchTableView.alpha = 0
            self.sportTypeBgViews.forEach({$0.alpha = 1})
            self.view.sendSubviewToBack(self.segmentio)
        }
    }
    @IBAction func sportBttnPressed(_ sender: UIButton) {
        if let s = Sport(rawValue: sender.tag){
            selectedSport = s
            
            for view in sportTypeBgViews{
                view.backgroundColor = view.tag == s.rawValue ? UIColor(hex: "479BF7") : UIColor(hex: "202638")
            }
            
            date = Date()
        }
    }
    @IBAction func rightDateBttnPressed(_ sender: Any) {
         date = date.addingTimeInterval(86400)
    }
    @IBAction func leftDateBttnPressed(_ sender: Any) {
        date = date.addingTimeInterval(-86400)
    }
    
    //MARK: Nav
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GameDayViewController, let game = sender as? Game{
            vc.game = game
        }else if let vc = segue.destination as? ProfileViewController{
            if let user = sender as? User{
                vc.user = user
            }
        }
    }
}

extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource, DiscoverTableViewCellDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentio.selectedSegmentioIndex == 0 ? userObjs.count : teamObjs.count //searchObjs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentio.selectedSegmentioIndex == 0 {
            
            if let user = userObjs[indexPath.row] as? User{
                if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? DiscoverUserTableViewCell{
                    cell.nameLbl.text = user.name
                    cell.hometownLbl.text = user.location
                    cell.isVerifiedImageView.alpha = user.verified ? 1 : 0
                    cell.user = user
                    cell.delegate = self
                    if let url = user.profileImage{
                        cell.profileImageView.imageFromUrl(url: url)
                    }else{
                        cell.profileImageView.image = #imageLiteral(resourceName: "default-profile")
                    }
                    cell.selectionStyle = .none
                    return cell
                }
            }
            
        } else if segmentio.selectedSegmentioIndex == 1 {
            
            if let team = teamObjs[indexPath.row] as? Team{
                if let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as? DiscoverTeamTableViewCell{
                    cell.nameLbl.text = team.name
                    cell.hometownLbl.text = "\(team.homeTown) | \(team.sport.abv)"
                    cell.primaryColor.backgroundColor = team.primaryColor
                    cell.secondaryColor.backgroundColor = team.secondaryColor
                    cell.team = team
                    cell.delegate = self
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }
        
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if segmentio.selectedSegmentioIndex == 0 {
            if let user = userObjs[indexPath.row] as? User{
                self.performSegue(withIdentifier: "showProfile", sender: user)
            }
        } else {
            if let team = teamObjs[indexPath.row] as? Team{
            }
        }
    }
    
    //MARK: DiscoverTableViewCellDelegate
    func followBttnPressed(team: Team){
        if team.followed{
            ApiManager.shared.unfollow(team: team.id, onSuccess: {
            }) { (err) in }
            if let i = User.me.teams.firstIndex(of: team){
                User.me.teams.remove(at: i)
            }
        }else{
            ApiManager.shared.follow(team: team.id, onSuccess: {
            }) { (err) in }
            User.me.teams.append(team)
        }
    }
    func followBttnPressed(user: User){
        if user.followed{
            ApiManager.shared.unfollow(user: user.id, onSuccess: {
            }) { (err) in }
        }else{
            ApiManager.shared.follow(user: user.id, onSuccess: {
            }) { (err) in }
        }
    }
}

extension DiscoverViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let game = games[indexPath.row]
        if indexPath.row == 0{
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameBanner", for: indexPath) as? DiscoverGameBannerCollectionViewCell{
                cell.card.load(game: game)
                return cell
            }
        }else{
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameCell", for: indexPath) as? DiscoverGameCollectionViewCell{
                if game.awayTeam != nil{
                    cell.awayTeamNameLbl.text = game.awayTeam.name
                    cell.awayScore.text = "\(game.awayScore)"
                }
                if game.homeTeam != nil{
                    cell.homeTeamNameLbl.text = game.homeTeam.name
                    cell.homeScore.text = "\(game.homeScore)"
                }
                cell.sportBg.image = game.sport.image
                cell.fieldNameLbl.text = game.venue.name
                
                cell.timeLbl.text = game.startTime
                
                // if start time is past 5 hours the current date add 'final' instead of start time
                if let startFiveHours = Calendar.current.date(byAdding: .hour, value: 5, to: game.start) {
                    cell.timeLbl.text = startFiveHours < Date() ? "Final" : game.startTime
                }
                
                
                return cell
            }
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0{
            return CGSize(width: collectionView.frame.width, height: 140)
        }
        return CGSize(width: collectionView.frame.width / 2 - 5, height: 140)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "showGame", sender: games[indexPath.row])
    }
}

extension DiscoverViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        cancelBttn.alpha = 1
        UIView.animate(withDuration: 0.5) {
            self.searchTableView.alpha = 1
            self.sportTypeBgViews.forEach({$0.alpha = 0})
            self.view.bringSubviewToFront(self.segmentio)
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        Alamofire.SessionManager.default.session.getAllTasks { (tasks) in
            tasks.forEach{ $0.cancel() }
        }
        
        ApiManager.shared.search(with: searchBar.text!, onSuccess: { (objs) in
            self.searchObjs = objs
            
            self.userObjs = []
            self.teamObjs = []
            
            self.searchObjs.forEach({
                if $0 is User {
                    self.userObjs.append($0)
                } else if $0 is Team {
                    self.teamObjs.append($0)
                }
            })

            self.searchTableView.reloadData()
        }) { (err) in }
    }
}
