//
//  DiscoverViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 2/6/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

protocol DiscoverSearchTableViewCellDelegate {
    func onFollowUser(user: User, cell: UITableViewCell)
    func onFollowTeam(team: Team, cell: UITableViewCell)
}

class DiscoverViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet weak var typeButtonsScrollView: UIScrollView!
    @IBOutlet var typeButtons: [UIButton]!

    @IBOutlet weak var todayGamesButton: UIButton!
    @IBOutlet weak var leftDateButton: UIButton!
    @IBOutlet weak var rightDateButton: UIButton!

    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var gamesCollectionView: UICollectionView!
    
    private var selectedSport = Sport.football
    
    private var searchResult = [DBObject]()
    private var nearbyObjects = [DBObject]()
    private var trendingObjects = [DBObject]()
    
    private var nearby = [Game]()
    private var following = [Game]()

    private var date = Date() {
        didSet {
            let dateText: String
            if date.isToday {
                dateText = NSLocalizedString("Today", comment: "")
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd"
                dateText = formatter.string(from: date)
            }
            todayGamesButton.setTitle(dateText, for: .normal)

            let yesterday = date.addingTimeInterval(-24 * 60 * 60)
            let tomorrow = date.addingTimeInterval(24 * 60 * 60)
            
            if yesterday.isToday {
                leftDateButton.setTitle(NSLocalizedString("Today", comment: ""), for: .normal)
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd"
                leftDateButton.setTitle(formatter.string(from: yesterday), for: .normal)
            }
            if tomorrow.isToday {
                rightDateButton.setTitle(NSLocalizedString("Today", comment: ""), for: .normal)
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd"
                rightDateButton.setTitle(formatter.string(from: tomorrow), for: .normal)
            }
 
            loadGames()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectedSport = .football
        date = Date()
    }
    
    //MARK: Nav
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GameDayViewController, let game = sender as? Game {
            vc.game = game
        } else if let vc = segue.destination as? OtherProfileViewController {
            if let user = sender as? User {
                vc.user = user
            }
        } else if let vc = segue.destination as? CalendarViewController {
            vc.delegate = self
            vc.selectedDate = date
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.white
        
        loadGames()
    }
}

extension DiscoverViewController {
    @IBAction func onNextDay(_ sender: Any) {
        date = date.addingTimeInterval(86400)
    }

    @IBAction func onPreviousDay(_ sender: Any) {
        date = date.addingTimeInterval(-86400)
    }
    
    @IBAction func onTypeButtons(_ sender: Any) {
        guard let sender = sender as? UIButton else {
            return
        }
        
        for button in typeButtons {
            if button == sender {
                button.tintColor = UIColor.white
                button.backgroundColor = UIColor(hex: "009BFF")
            } else {
                button.tintColor = UIColor.black
                button.backgroundColor = UIColor.clear
            }
        }
        
        selectedSport = Sport(rawValue: sender.tag) ?? .football
        
        loadGames()
    }
}

extension DiscoverViewController: DiscoverSearchTableViewCellDelegate {
    
    func onFollowUser(user: User, cell: UITableViewCell) {
        if user.followed {
            
            ApiManager.shared.unfollow(user: user.id, onSuccess: {
                
                user.followed = false
                
                if let indexPath = self.searchTableView.indexPath(for: cell) {
                    self.searchTableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }) { (err) in
                
            }
            
        } else {
            
            ApiManager.shared.follow(user: user.id, onSuccess: {
                
                user.followed = true
                
                if let indexPath = self.searchTableView.indexPath(for: cell) {
                    self.searchTableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }) { (err) in
                
            }
        }
    }
    
    func onFollowTeam(team: Team, cell: UITableViewCell) {
        if team.followed {
            
            ApiManager.shared.unfollow(team: team.id, onSuccess: {

                team.followed = false

                if let i = User.me.teams.firstIndex(of: team) {
                    User.me.teams.remove(at: i)
                }

                if let indexPath = self.searchTableView.indexPath(for: cell) {
                    self.searchTableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }) { (err) in
                
            }
            
        } else {
            
            ApiManager.shared.follow(team: team.id, onSuccess: {
                
                team.followed = true
                User.me.teams.append(team)

                if let indexPath = self.searchTableView.indexPath(for: cell) {
                    self.searchTableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }) { (err) in
                
            }
        }
    }
}

extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return ((searchBar.text ?? "").isEmpty && !trendingObjects.isEmpty) ? 42 : 0
        } else if section == 2 {
            return ((searchBar.text ?? "").isEmpty && !nearbyObjects.isEmpty) ? 42 : 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title: String? = nil
        
        if section == 1 {
            if (searchBar.text ?? "").isEmpty && !trendingObjects.isEmpty {
                title = NSLocalizedString("TRENDING", comment: "")
            }
        } else if section == 2 {
            if (searchBar.text ?? "").isEmpty && !nearbyObjects.isEmpty {
                title = NSLocalizedString("NEARBY", comment: "")
            }
        }
        
        if let title = title {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 42))
            view.backgroundColor = UIColor.white
            let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.bounds.size.width - 32, height: 42))
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            label.textColor = UIColor(hex: "1F263A")
            label.font = UIFont.systemFont(ofSize: 12)
            label.text = title
            view.addSubview(label)
            return view
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (searchBar.text ?? "").isEmpty ? 0 : searchResult.count
        } else if section == 1 {
            return (searchBar.text ?? "").isEmpty ? trendingObjects.count : 0
        } else if section == 2 {
            return (searchBar.text ?? "").isEmpty ? nearbyObjects.count : 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 62
        }
        return 40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if let user = searchResult[indexPath.row] as? User {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? DiscoverUserTableViewCell {
                    cell.user = user
                    cell.delegate = self
                    cell.selectionStyle = .none
                    return cell
                }
            } else if let team = searchResult[indexPath.row] as? Team {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as? DiscoverTeamTableViewCell {
                    cell.team = team
                    cell.delegate = self
                    cell.selectionStyle = .none
                    return cell
                }
            }
        } else {
            let object = (indexPath.section == 1) ? trendingObjects[indexPath.row] : nearbyObjects[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCell") as? DiscoverSuggestionTableViewCell {
                cell.object = object
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            }
        }

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            if let user = searchResult[indexPath.row] as? User {
                if user.id == User.me.id {
                    performSegue(withIdentifier: "showProfile", sender: user)
                } else {
                    performSegue(withIdentifier: "showOtherProfile", sender: user)
                }
            }
        } else {
            let object = (indexPath.section == 1) ? trendingObjects[indexPath.row] : nearbyObjects[indexPath.row]
            if let user = object as? User {
                if user.id == User.me.id {
                    performSegue(withIdentifier: "showProfile", sender: user)
                } else {
                    performSegue(withIdentifier: "showOtherProfile", sender: user)
                }
            }
        }
    }
}

extension DiscoverViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var header: DiscoverCollectionHeaderView?
        
        if (kind == UICollectionView.elementKindSectionHeader) {
            header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath) as? DiscoverCollectionHeaderView
            header?.textLabel.text = (indexPath.section == 0) ? (NSLocalizedString("Games in", comment: "") + " \(User.me.location)") : NSLocalizedString("Your Friends are Following", comment: "")
        }
        
        return header!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return max(nearby.count, 1)
        }
        return max(following.count, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let games = (indexPath.section == 0) ? nearby : following
        if games.isEmpty {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "noGamesCell", for: indexPath)
        }
        
        let game = games[indexPath.row]
        if indexPath.row == 0 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameBanner", for: indexPath) as? DiscoverGameBannerCollectionViewCell {
                cell.card.game = game
                return cell
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameCell", for: indexPath) as? DiscoverGameCollectionViewCell {
                cell.game = game
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let games = (indexPath.section == 0) ? nearby : following
        if games.isEmpty {
            return CGSize(width: collectionView.frame.width - 16, height: 80)
        }
        
        if indexPath.row == 0 {
            return CGSize(width: collectionView.frame.width - 16, height: 160)
        }
        return CGSize(width: (collectionView.frame.width - 25) / 2, height: 142)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let games = (indexPath.section == 0) ? nearby : following
        if games.isEmpty {
            return
        }
        
        performSegue(withIdentifier: "showGame", sender: games[indexPath.row])
    }
}

extension DiscoverViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)

        self.searchTableView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.searchTableView.alpha = 1
        }
        
        ApiManager.shared.trending(onSuccess: { (result) in
            self.trendingObjects = result
            self.searchTableView.reloadData()
        }) { (_) in
            
        }
        
        ApiManager.shared.nearby(onSuccess: { (result) in
            self.nearbyObjects = result
            self.searchTableView.reloadData()
        }) { (_) in
            
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)

        UIView.animate(withDuration: 0.2, animations: {
            self.searchTableView.alpha = 0
        }) { (_) in
            self.searchTableView.isHidden = true
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        Alamofire.SessionManager.default.session.getAllTasks { (tasks) in
            tasks.forEach{ $0.cancel() }
        }
        
        ApiManager.shared.search(with: searchBar.text!, onSuccess: { (objs) in
            self.searchResult = objs
            self.searchTableView.reloadData()
        }) { (err) in }
    }
}

extension DiscoverViewController {
    private func loadGames() {
        ApiManager.shared.searchGames(for: date, sport: selectedSport, onSuccess: { (nearby, following)  in
            self.nearby = nearby
            self.following = following

            var index = 0
            // doing my best to get rid of duplicate games
            for game in self.nearby {
                if game.winningTeamId == 0 {
                    // most likely a duplicate game since no winningTeamId is 0
                    //self.games.remove(at: index)
                    index += 1
                    
                } else if game.awayScore == 0 && game.homeScore == 0 {
                    if self.nearby.contains(where: {$0.homeTeam.id == game.homeTeam.id
                        && $0.awayTeam.id == game.awayTeam.id
                        && $0.id != game.id}) {
                        
                        if game.start < Date() {
                            self.nearby.remove(at: index)
                        }
                    }
                } else {
                    index += 1
                }
            }
            
            // filter out duplicate games with different start times
            var duplicateIndex = 0
            for game in self.nearby {
                guard game.awayScore == 0 && game.homeScore == 0 else {
                    duplicateIndex += 1
                    continue
                }
                
                if self.nearby.contains(where: {$0.homeTeam.id == game.homeTeam.id
                    && $0.awayTeam.id == game.awayTeam.id
                    && $0.id != game.id
                    && $0.id > game.id}) {
                    
                    self.nearby.remove(at: duplicateIndex)
                } else {
                    duplicateIndex += 1
                }
            }
            
            
            index = 0
            // doing my best to get rid of duplicate games
            for game in self.following {
                if game.winningTeamId == 0 {
                    // most likely a duplicate game since no winningTeamId is 0
                    //self.games.remove(at: index)
                    index += 1
                    
                } else if game.awayScore == 0 && game.homeScore == 0 {
                    if self.following.contains(where: {$0.homeTeam.id == game.homeTeam.id
                        && $0.awayTeam.id == game.awayTeam.id
                        && $0.id != game.id}) {
                        
                        if game.start < Date() {
                            self.following.remove(at: index)
                        }
                    }
                } else {
                    index += 1
                }
            }
            
            // filter out duplicate games with different start times
            duplicateIndex = 0
            for game in self.following {
                guard game.awayScore == 0 && game.homeScore == 0 else {
                    duplicateIndex += 1
                    continue
                }
                
                if self.following.contains(where: {$0.homeTeam.id == game.homeTeam.id
                    && $0.awayTeam.id == game.awayTeam.id
                    && $0.id != game.id
                    && $0.id > game.id}) {
                    
                    self.following.remove(at: duplicateIndex)
                } else {
                    duplicateIndex += 1
                }
            }

            self.didReloadGames()
        }) { (err) in }
    }

    private func didReloadGames() {
        gamesCollectionView.setContentOffset(CGPoint.zero, animated: false)
        gamesCollectionView.reloadData()
    }
}

extension DiscoverViewController: CalendarViewControllerDelegate {
    func didSelectDate(date: Date) {
        self.date = date
        dismiss(animated: true, completion: nil)
    }
}
