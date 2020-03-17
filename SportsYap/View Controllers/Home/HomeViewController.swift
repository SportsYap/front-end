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

    @IBOutlet var postsTableView: UITableView!
    @IBOutlet var gamesTableView: UITableView!
    
    @IBOutlet var noGamesView: UIView!
    @IBOutlet var noPostsView: UIView!
    @IBOutlet weak var loadingGamesView: UIView!
    
    @IBOutlet var contentScrollView: UIScrollView!
    @IBOutlet var timelineBttn: UIButton!
    @IBOutlet var todayGamesBttn: UIButton!
    @IBOutlet weak var cameraBttn: UIButton!
    @IBOutlet weak var leftDateArrowImageView: UIImageView!
    @IBOutlet weak var rightDateArrowImageView: UIImageView!
    @IBOutlet weak var leftDateBttn: UIButton!
    @IBOutlet weak var rightDateBttn: UIButton!
    
    @IBOutlet weak var viewModeButton: UIButton!
    @IBOutlet weak var typeButtonsScrollView: UIScrollView!
    @IBOutlet var typeButtons: [UIButton]!
    
    @IBOutlet weak var carouselView: iCarousel!
    
    var firstViewLoad = false
    
    var games = [Game]()
    var gameSports = [Sport]()
    var groupedGames = [[Game]]()
    
    var posts = [Post]()
    var postPage = 1
    
    var liveUsers = [User]()
    var gamesRefreshControl: UIRefreshControl!
    var postsRefreshControl: UIRefreshControl!
    
    private var selectedSport: Sport = .football
    private var isListMode: Bool = false
    
    var date = Date(){
        didSet{
            if date.isToday {
                todayGamesBttn.setTitle(NSLocalizedString("Today", comment: ""), for: .normal)
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd"
                todayGamesBttn.setTitle(formatter.string(from: date), for: .normal)
            }
            
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
            
            loadGames()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        date = Date()
        cameraBttn.alpha = 0
        
        guard ApiManager.shared.loggedIn else{
            return self.performSegue(withIdentifier: "auth", sender: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name(rawValue: "api-token-changed"), object: nil)
        
        gamesRefreshControl = UIRefreshControl()
        gamesRefreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                      for: UIControl.Event.valueChanged)
        gamesRefreshControl.tintColor = UIColor.gray
        self.gamesTableView.addSubview(self.gamesRefreshControl)
        
        postsRefreshControl = UIRefreshControl()
        postsRefreshControl.addTarget(self, action:
            #selector(handlePostsRefresh(_:)),
                                      for: UIControl.Event.valueChanged)
        postsRefreshControl.tintColor = UIColor.gray
        self.postsTableView.addSubview(self.postsRefreshControl)
        
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
        
        if !firstViewLoad{
            contentScrollView.setContentOffset(CGPoint(x: self.view.frame.width, y: 0), animated: false)
            firstViewLoad = true
        }
        
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
    
    @objc func reload(){
        loadGames()
    }
    
    func checkPushNotifications() {
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
    
    func loadGames() {
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
        }) { (err) in }
    }
    
    func loadPosts(){
        postPage = 1
        
        ApiManager.shared.timeline(page: postPage, onSuccess: { (posts) in
            if self.posts.map({ $0.id }).sorted() != posts.map({ $0.id }).sorted(){
                self.posts = posts
                self.postsTableView.reloadData()
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                self.noPostsView.alpha = posts.count > 0 ? 0 : 1
            })
        }) { (err) in }
    }
    
    func loadAnotherPostsPage(){
        guard posts.count != 0 && firstViewLoad else { return }
        postPage += 1
        ApiManager.shared.timeline(page: postPage, onSuccess: { (posts) in
            if posts.count > 0{
                self.posts += posts
                self.postsTableView.reloadData()
            }else{
                self.postPage -= 1
            }
        }) { (err) in }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadGames()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            /*
            ApiManager.shared.gamesStarting(onSuccess: { (games) in
                
                print("current date: \(Date())")
             
                for game in games {
                    print("")
                    print(game.description)
                    print(game.startString)
                    print(game.startString2)
                    print("")
                }
                
            }, onError: { (error) in
                print(error.localizedDescription)
                print("really an error?")
            })
            */
        }
        
        refreshControl.endRefreshing()
    }
    
    @objc func handlePostsRefresh(_ refreshControl: UIRefreshControl) {
        //loadPosts()
        refreshControl.endRefreshing()
    }
    
    //MARK: IBActions
    @IBAction func rightDateBttnPressed(_ sender: Any) {
        date = date.addingTimeInterval(86400)
    }
    @IBAction func leftDateBttnPressed(_ sender: Any) {
        date = date.addingTimeInterval(-86400)
    }
    @IBAction func timelineBttnPressed(_ sender: Any) {
        contentScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        timelineBttn.setTitleColor(UIColor.darkGray, for: .normal)
        todayGamesBttn.setTitleColor(UIColor.lightGray, for: .normal)
        cameraBttn.alpha = 1
    }
    @IBAction func todaysGamesBttnPressed(_ sender: Any) {
        contentScrollView.setContentOffset(CGPoint(x: self.view.frame.width, y: 0), animated: true)
        timelineBttn.setTitleColor(UIColor.lightGray, for: .normal)
        todayGamesBttn.setTitleColor(UIColor.darkGray, for: .normal)
        cameraBttn.alpha = 0
    }
    @IBAction func cameraBttnPressed(_ sender: Any) {
        ParentScrollingViewController.shared.scrollToCamera()
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
    
    @IBAction func onChangeViewMode(_ sender: Any) {
        isListMode = !isListMode

        viewModeButton.setTitle(NSLocalizedString(!isListMode ? "List View" : "Card View", comment: ""), for: .normal)
        
        carouselView.isHidden = isListMode
        gamesTableView.isHidden = !isListMode
    }
    
    
    //MARK: Nav
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GameDayViewController, let game = sender as? Game{
            vc.game = game
        }else if let vc = segue.destination as? ShotViewController, let post = sender as? Post{
            vc.posts = [post]
            vc.game = post.game
        }else if let vc = segue.destination as? ProfileViewController, let user = sender as? User{
            vc.user = user
        }else if let vc = segue.destination as? CommentsViewController, let post = sender as? Post{
            vc.post = post
        }else if let vc = segue.destination as? ViewLiveStreamViewController, let user = sender as? User{
            vc.user = user
        }else if let vc = segue.destination as? SinglePostViewController, let postId = sender as? Int{
            vc.postId = postId
            vc.hidesBottomBarWhenPushed = true
        }
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
        gamesTableView.reloadData()
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

extension HomeViewController: UITableViewDataSource, UITableViewDelegate, PostTableViewCellDelegate, TimelineLiveTableViewCellDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == typeButtonsScrollView {
            ParentScrollingViewController.shared.enabled(is: false)
            return
        }
        
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        
        if translation.y != 0 && translation.x < 50 || translation.x < 1 {
            ParentScrollingViewController.shared.enabled(is: false)
        }
        
        print("dragging")
        print(translation)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == typeButtonsScrollView {
            ParentScrollingViewController.shared.enabled(is: true)
            return
        }
        
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)

        print("not dragging")
        print(translation)
        ParentScrollingViewController.shared.enabled(is: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == postsTableView{
            return 2
        } else {
            if let _ = gameSports.firstIndex(of: selectedSport) {
                return 1
            }
            return 0
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == postsTableView{
            if section == 0{
                return liveUsers.count == 0 ? 0 : 1
            }
            return posts.count
        }else{
            if let index = gameSports.firstIndex(of: selectedSport) {
                let games = groupedGames[index]
                return games.count
            }
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == postsTableView{
            if indexPath.section == 0{
                if let cell = tableView.dequeueReusableCell(withIdentifier: "liveCell") as? TimelineLiveTableViewCell{
                    cell.users = liveUsers
                    cell.delegate = self
                    return cell
                }
            }else{
                if indexPath.row == posts.count-1{
                    //loadAnotherPostsPage()
                }
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as? PostTableViewCell{
    
                    let post = posts[indexPath.row]
                    
                    print("user Id: \(User.me.id)")
                    print("post id: \(post.id)")
                    
                    cell.nameLbl.text = post.user.name
                    cell.userProfileImageView.image = nil
                    cell.userProfileImageView.backgroundColor = UIColor.black
                    if let url = post.user.profileImage{
                        cell.userProfileImageView.imageFromUrl(url: url)
                    }else{
                        cell.userProfileImageView.image = #imageLiteral(resourceName: "default-profile")
                    }
                    cell.timeAgoLbl.text = post.createdAt.timeAgoSince()
                    cell.teamLbl.text = post.team?.name ?? ""
                    cell.verificiedIcon.alpha = post.user.verified ? 1 : 0
                    cell.loadingActivityIndicator.startAnimating()
                    cell.post = post
                    
                    //cell.likeBttn.setImage(!post.liked ? #imageLiteral(resourceName: "like_bttn_empty") : #imageLiteral(resourceName: "like_bttn_selected"), for: .normal)
                    cell.likeBttn.setImage(!User.me.likedPosts.contains(post.id) ? #imageLiteral(resourceName: "like_bttn_empty") : #imageLiteral(resourceName: "like_bttn_selected"), for: .normal)
                    cell.setLikeCnt(cnt: post.likeCnt ?? 0)
                    
                    if let url = post.media.photoUrl{ // Render Photo
                        cell.mediaImageView.imageFromUrl(url: url)
                        cell.playBttnImageView.alpha = 0
                        
                        cell.mediaImageView.isPinchable = true
                        
                    }else if let url = post.media.thumbnailUrl{ // Render Video Thumbnail
                        cell.mediaImageView.imageFromUrl(url: url)
                        cell.mediaImageView.isPinchable = true
                        cell.playBttnImageView.alpha = 1
                    }
                    cell.delegate = self
                    cell.selectionStyle = .none
                    
                    cell.aspectRatioConstraint.constant = self.getHeightSubstractor(post: post)
                    
                    return cell
                }
            }
        }else{
            if let index = gameSports.firstIndex(of: selectedSport) {
                let games = groupedGames[index]
                let game = games[indexPath.row]

                if let cell = tableView.dequeueReusableCell(withIdentifier: "gameCard") as? HomeGameTableViewCell{
                    cell.selectionStyle = .none
                    cell.card.load(game: game)
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == postsTableView{
            self.performSegue(withIdentifier: "showPost", sender: posts[indexPath.row])
        } else {
            if let index = gameSports.firstIndex(of: selectedSport) {
                let games = groupedGames[index]
                let game = games[indexPath.row]
                self.performSegue(withIdentifier: "showGame", sender: game)
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == postsTableView{
            if indexPath.section == 0{
                return 85
            }
            let rowHeight = 95 + self.view.frame.width * 1.34
            
            if self.getHeightSubstractor(post: posts[indexPath.row]) == 0 {
                return rowHeight
            } else {
                return (rowHeight - self.getHeightSubstractor(post: posts[indexPath.row])) - 40
            }
            
        } else {
            return 160
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView == gamesTableView ? 15 : 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 15))
        lbl.text = gameSports[section].abv
        lbl.textAlignment = .center
        lbl.textColor = UIColor(hex: "7F7F7F")
        lbl.font = UIFont.systemFont(ofSize: 12)
        if #available(iOS 13.0, *) {
            lbl.backgroundColor = UIColor.systemBackground
        } else {
            // Fallback on earlier versions
            lbl.backgroundColor = UIColor.white
        }
        return lbl
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    //MARK: PostTableViewCellDelegate
    func likeBttnPressed(post: Post){
        /*
        if post.liked{
            ApiManager.shared.unlike(post: post.id, onSuccess: {
            }, onError: voidErr)
        }else{
            ApiManager.shared.like(post: post.id, onSuccess: {
            }, onError: voidErr)
        }
        */
        
        
    }
    func commentBttnPressed(post: Post){
        self.performSegue(withIdentifier: "showComment", sender: post)
    }
    func userBttnPressed(user: User){
        self.performSegue(withIdentifier: "showProfile", sender: user)
    }
    func optionsBttnPressed(post: Post){
        let alertController = UIAlertController(title: "Options", message: "", preferredStyle: .actionSheet)
        
        if post.media.thumbnailUrl == nil {
            // its a picture so add option to save photo

            if let imageUrl = post.media.photoUrl {
                let data = NSData(contentsOf: imageUrl)
                let image = UIImage(data: data! as Data)
                
                let saveAction = UIAlertAction(title: "Save Photo", style: .default) { (action) in
                    
                    UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
                
                alertController.addAction(saveAction)
            }
        }
        
        let  deleteButton = UIAlertAction(title: "Report for Abuse", style: .destructive, handler: { (action) -> Void in
            
            let reports = UserDefaults.standard.object(forKey:"reports") as? [Int] ?? [Int]()
            
            if reports.contains(post.id) {
                // already reported
                self.alert(message: "You already reported this post.", title: "Reported")
                
            } else {
                //report post
                ApiManager.shared.report(post: post.id, onSuccess: {
                    self.handlePostsRefresh(self.postsRefreshControl)
                    
                    self.alert(message: "Post has been reported.", title: "Reported")
                }, onError: voidErr)
            }
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: TimelineLiveTableViewCellDelegate
    func liveStreamPressed(user: User) {
        self.performSegue(withIdentifier: "showLive", sender: user)
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
