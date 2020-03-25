//
//  HomeViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 2/6/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import OneSignal
import SwiftDate
import iCarousel

class HomeViewController: UIViewController {

    @IBOutlet weak var noGamesLabel: UILabel!
    @IBOutlet weak var noGamesView: UIView!
    @IBOutlet weak var loadingGamesView: UIView!
    
    @IBOutlet weak var todayGamesBttn: UIButton!
    @IBOutlet weak var leftDateArrowImageView: UIImageView!
    @IBOutlet weak var rightDateArrowImageView: UIImageView!
    @IBOutlet weak var leftDateBttn: UIButton!
    @IBOutlet weak var rightDateBttn: UIButton!
    
    @IBOutlet weak var viewModeButton: UIButton!
    @IBOutlet weak var typeButtonsScrollView: UIScrollView!
    @IBOutlet var typeButtons: [UIButton]!
    
    @IBOutlet weak var carouselView: iCarousel!
    
    private var games = [Game]()
    private var gameSports = [Sport]()
    private var groupedGames = [[Game]]()
    
    private var selectedSport: Sport = .football
    
    private var date = Date() {
        didSet {
            let dateText: String
            let placeholder: String
            if date.isToday {
                dateText = NSLocalizedString("Today", comment: "")
                placeholder = dateText.lowercased()
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd"
                dateText = formatter.string(from: date)
                placeholder = NSLocalizedString("at", comment: "") + " " + dateText
            }
            todayGamesBttn.setTitle(dateText, for: .normal)

            let yesterday = date.addingTimeInterval(-24 * 60 * 60)
            let tomorrow = date.addingTimeInterval(24 * 60 * 60)
            
            if yesterday.isToday {
                leftDateBttn.setTitle(NSLocalizedString("Today", comment: ""), for: .normal)
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd"
                leftDateBttn.setTitle(formatter.string(from: yesterday), for: .normal)
            }
            if tomorrow.isToday {
                rightDateBttn.setTitle(NSLocalizedString("Today", comment: ""), for: .normal)
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd"
                rightDateBttn.setTitle(formatter.string(from: tomorrow), for: .normal)
            }
            
            noGamesLabel.text = String(format: NSLocalizedString("Your favorite teams don’t have any games %@. Follow more teams!", comment: ""), placeholder)
            loadGames()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        date = Date()
        
        guard ApiManager.shared.loggedIn else{
            return self.performSegue(withIdentifier: "auth", sender: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadGames), name: NSNotification.Name(rawValue: "api-token-changed"), object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.checkPushNotifications()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ApiManager.shared.likes(user: User.me.id)
        }
        
        carouselView.type = .linear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ParentScrollingViewController.shared.enabled(is: true)
        
        guard !(!ApiManager.shared.loggedIn && self.presentedViewController == nil) else{
            return self.performSegue(withIdentifier: "auth", sender: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loadGames()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ParentScrollingViewController.shared.enabled(is: true)
        
        if let reportedPost = UserDefaults.standard.value(forKey: "reportedPost") as? String {
            let alert = UIAlertController(title: "Reported", message: "Your post from \(reportedPost) has been deleted due to it being reported 3 times", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in }
            
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            UserDefaults.standard.removeObject(forKey: "reportedPost")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ParentScrollingViewController.shared.enabled(is: false)
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GameDayViewController, let game = sender as? Game{
            vc.game = game
        } else if let vc = segue.destination as? ShotViewController, let post = sender as? Post{
            vc.posts = [post]
            vc.game = post.game
        } else if let vc = segue.destination as? ProfileViewController, let user = sender as? User{
            vc.user = user
        } else if let vc = segue.destination as? CommentsViewController, let post = sender as? Post{
            vc.post = post
        } else if let vc = segue.destination as? ViewLiveStreamViewController, let user = sender as? User{
            vc.user = user
        } else if let vc = segue.destination as? SinglePostViewController, let postId = sender as? Int{
            vc.postId = postId
            vc.hidesBottomBarWhenPushed = true
        }
    }
}

extension HomeViewController {
    private func checkPushNotifications() {
        // trigger push notification signup
        let hasPrompted = OneSignal.getPermissionSubscriptionState().permissionStatus.hasPrompted
        
        if !hasPrompted {
            let alert = UIAlertController(title: "Notifications", message: "Never miss a game! Turn on Notifications!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Continue", style: .default) { (action) in
                
                OneSignal.promptForPushNotifications(userResponse: { accepted in
                    print("User accepted notifications: \(accepted)")
                    guard let playerId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId else { return }
                    
                    ApiManager.shared.updatePushToken(token: playerId, onSuccess: {
                        print("success")
                    }, onError: { (error) in
                        print("error notification: \(error.localizedDescription)")
                    })
                })
            }
            
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc private func loadGames() {
        ApiManager.shared.games(for: date, onSuccess: { (games) in
            self.loadingGamesView.alpha = 0
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
                } else {
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
            
            self.gameSports = [Sport]()
            self.groupedGames = [[Game]]()
            for sport in Sport.all{
                let gamesForSport = self.games.filter({ $0.sport == sport }).sorted(by: { $0.start > $1.start })
                if gamesForSport.count > 0{
                    self.gameSports.append(sport)
                    self.groupedGames.append(gamesForSport)
                }
            }

            self.didReloadGames()
        }) { (err) in
            print(err)
        }
    }
}

//MARK: IBActions
extension HomeViewController {
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
                button.setBackgroundImage(UIImage(named: "ic_selected_type_bg"), for: .normal)
            } else {
                button.tintColor = UIColor.black
                button.setBackgroundImage(nil, for: .normal)
            }
        }
        
        selectedSport = Sport(rawValue: sender.tag) ?? .football
        
        didReloadGames()
    }
    
    
    
    // need this to resize the cell to match / closely match the height of the content
    // if the content was resized
    private func getHeightSubstractor(post: Post) -> CGFloat {
        if post.contentHeight > 400 && post.contentHeight < 500 {
            return 150
        } else if post.contentHeight > 300 && post.contentHeight < 401 {
            return 150
        } else if post.contentHeight > 200 && post.contentHeight < 301 {
            return 200
        } else if post.contentHeight > 100 && post.contentHeight < 201 {
            return 250
        } else if post.contentHeight > 0 && post.contentHeight < 101 {
            return 300
        } else {
            // photo/video wasn't resized
            return 0
        }
        
    }
    
    private func didReloadGames() {
        carouselView.currentItemIndex = 0
        carouselView.reloadData()
        
        let hasGames: Bool
        if let index = gameSports.firstIndex(of: selectedSport) {
            let games = groupedGames[index]
            hasGames = !games.isEmpty
        } else {
            hasGames = false
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.noGamesView.alpha = hasGames ? 0 : 1
        })
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == typeButtonsScrollView {
            ParentScrollingViewController.shared.enabled(is: false)
            return
        }
        
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if translation.y != 0 && translation.x < 50 || translation.x < 1 {
            ParentScrollingViewController.shared.enabled(is: false)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == typeButtonsScrollView {
            ParentScrollingViewController.shared.enabled(is: true)
            return
        }
        
        ParentScrollingViewController.shared.enabled(is: true)
    }
}

extension HomeViewController: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        if let index = gameSports.firstIndex(of: selectedSport) {
            let games = groupedGames[index]
            return games.count
        }
        return 0
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        if let sportIndex = gameSports.firstIndex(of: selectedSport) {
            let games = groupedGames[sportIndex]
            let game = games[index]
            
            if let gameView = view as? GameListItemView {
                gameView.game = game
                gameView.frame = CGRect(x: 0, y: 0, width: carousel.bounds.size.width - 100, height: carousel.bounds.size.height)
                return gameView
            } else if let gameView = Bundle.main.loadNibNamed("GameListItemView", owner: nil, options: nil)?.first as? GameListItemView {
                gameView.game = game
                gameView.frame = CGRect(x: 0, y: 0, width: carousel.bounds.size.width - 100, height: carousel.bounds.size.height)
                return gameView
            }
        }
        return UIView()
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        if let sportIndex = gameSports.firstIndex(of: selectedSport) {
            let games = groupedGames[sportIndex]
            let game = games[index]
            
            performSegue(withIdentifier: "showGame", sender: game)
        }
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .spacing:
            return 1.1
        default:
            return value
        }
    }
    
    func carouselWillBeginDragging(_ carousel: iCarousel) {
        ParentScrollingViewController.shared.enabled(is: false)
    }
    
    func carouselDidEndDragging(_ carousel: iCarousel, willDecelerate decelerate: Bool) {
        ParentScrollingViewController.shared.enabled(is: true)
    }
}
