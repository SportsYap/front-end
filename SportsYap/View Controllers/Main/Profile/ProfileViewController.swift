//
//  ProfileViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 2/6/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var teamsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var myActivityButton: UIButton!
    @IBOutlet weak var friendsActivityButton: UIButton!
    @IBOutlet weak var myTabIndicatorLeading: NSLayoutConstraint!

    private var refreshControl: UIRefreshControl!
    
    private var friendsActivities: [Post] = []
    private var showingMyPosts: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.alpha = navigationController?.viewControllers.count == 1 ? 0 : 1
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.gray
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadContent()
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CommentsViewController, let post = sender as? Post {
            vc.post = post
        } else if let vc = segue.destination as? ViewUsersViewController, let m = sender as? ViewUsersMode {
            vc.mode = m
            vc.rootUser = User.me
        }
    }
}

extension ProfileViewController {
    private func displayUser() {
        let user = User.me
        
        profileImageView.sd_setImage(with: user.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))
        nameLabel.text = user.name
        locationLabel.text = user.location

        teamsLabel.text = "\(user.teams.count)"
        followingLabel.text = "\(user.followingCnt)"
        followersLabel.text = "\(user.followerCnt)"
    }
    
    private func loadContent() {
        displayUser()
        
        ApiManager.shared.user(for: User.me.id, onSuccess: { (user) in
            User.me = user
            self.displayUser()
            if self.showingMyPosts {
                self.tableView.reloadData()
            }
        }) { (err) in }
        
        ApiManager.shared.friendsPosts(onSuccess: { (posts) in
            self.friendsActivities = posts
            if !self.showingMyPosts {
                self.tableView.reloadData()
            }
        }, onError: { (_) in
            
        })
    }
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadContent()
        refreshControl.endRefreshing()
    }
    
    private func deletePost(post: Post) {
        ApiManager.shared.deletePost(post: post.id, onSuccess: {
            if let index = User.me.posts.index(of: post) {
                User.me.posts.remove(at: index)
                self.tableView.reloadData()
            }
        }, onError: voidErr)
    }
}

extension ProfileViewController {
    //MARK: IBAction
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onEditProfile(_ sender: Any) {
        performSegue(withIdentifier: "settings", sender: nil)
    }

    @IBAction func onTapTeams(_ sender: Any) {
        performSegue(withIdentifier: "viewTeams", sender: nil)
    }

    @IBAction func onTapFollowings(_ sender: Any) {
        performSegue(withIdentifier: "viewUsers", sender: ViewUsersMode.following)
    }
    
    @IBAction func onTapFollowers(_ sender: Any) {
        performSegue(withIdentifier: "viewUsers", sender: ViewUsersMode.followers)
    }
    
    @IBAction func onSelectMyActivity(_ sender: Any) {
        myActivityButton.setTitleColor(UIColor(hex: "009BFF"), for: .normal)
        friendsActivityButton.setTitleColor(UIColor.black, for: .normal)

        UIView.animate(withDuration: 0.1, animations: {
            self.myTabIndicatorLeading.constant = 0
            self.tabView.layoutIfNeeded()
        }) { (_) in
            self.showingMyPosts = true
            self.tableView.contentOffset = .zero
            self.tableView.reloadData()
        }
    }
    
    @IBAction func onFriendsActivity(_ sender: Any) {
        myActivityButton.setTitleColor(UIColor.black, for: .normal)
        friendsActivityButton.setTitleColor(UIColor(hex: "009BFF"), for: .normal)

        UIView.animate(withDuration: 0.1, animations: {
            self.myTabIndicatorLeading.constant = self.myActivityButton.bounds.size.width
            self.tabView.layoutIfNeeded()
        }) { (_) in
            self.showingMyPosts = false
            self.tableView.contentOffset = .zero
            self.tableView.reloadData()
        }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(showingMyPosts ? User.me.posts.count : friendsActivities.count, 1)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let posts = showingMyPosts ? User.me.posts : friendsActivities
        if posts.isEmpty {
            return 180
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let posts = showingMyPosts ? User.me.posts : friendsActivities

        if posts.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: "noCell")!
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "gameCard") as? ProfilePostTableViewCell {
            cell.post = posts[indexPath.row]
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let posts = showingMyPosts ? User.me.posts : friendsActivities
        if posts.isEmpty {
            return
        }

        performSegue(withIdentifier: "showComments", sender: posts[indexPath.row])
    }
}

extension ProfileViewController: ProfilePostTableViewCellDelegate {
    func didTapOption(post: Post) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (_) in
            let alert = UIAlertController(title: NSLocalizedString("Confirm", comment: ""), message: NSLocalizedString("Are you sure you want to delete this post?", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (_) in
                self.deletePost(post: post)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
}
