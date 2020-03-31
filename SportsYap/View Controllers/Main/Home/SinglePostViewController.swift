//
//  SinglePostViewController.swift
//  SportsYap
//
//  Created by Solomon W on 3/20/19.
//  Copyright © 2019 Alex Pelletier. All rights reserved.
//

import UIKit

class SinglePostViewController: UIViewController {
    
    @IBOutlet weak var postsTableView: UITableView!
    
    var selectedPost: Post!
    var postId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApiManager.shared.singlePost(postId: postId, onSuccess: { (post) in
            self.selectedPost = post
            self.postsTableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        singlePost = true
    }
    
    
    
    @IBAction func backPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Nav
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ShotViewController, let post = sender as? Post{
            vc.posts = [post]
            vc.game = post.game
        }else if let vc = segue.destination as? OtherProfileViewController, let user = sender as? User{
            vc.user = user
        }else if let vc = segue.destination as? CommentsViewController, let post = sender as? Post{
            vc.post = post
        }else if let vc = segue.destination as? ViewLiveStreamViewController, let user = sender as? User{
            vc.user = user
        }else if let vc = segue.destination as? SinglePostViewController, let postId = sender as? Int{
            vc.postId = postId
        }
    }
    
}

extension SinglePostViewController: UITableViewDataSource, UITableViewDelegate, PostTableViewCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedPost == nil {
            return 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCellSingle") as! PostTableViewCell
        
        let post = selectedPost!
        cell.nameLbl.text = post.user.name
        cell.userProfileImageView.image = nil
        cell.userProfileImageView.backgroundColor = UIColor.black
        cell.userProfileImageView.sd_setImage(with: post.user.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))
        cell.timeAgoLbl.text = post.createdAt.timeAgoSince()
        cell.teamLbl.text = post.team?.name ?? ""
        cell.verificiedIcon.alpha = post.user.verified ? 1 : 0
        cell.loadingActivityIndicator.startAnimating()
        cell.post = post
        //cell.likeBttn.setImage(!post.liked ? #imageLiteral(resourceName: "like_bttn_empty") : #imageLiteral(resourceName: "like_bttn_selected"), for: .normal)
        cell.likeBttn.setImage(!User.me.likedPosts.contains(post.id) ? #imageLiteral(resourceName: "like_bttn_empty") : #imageLiteral(resourceName: "like_bttn_selected"), for: .normal)
        cell.setLikeCnt(cnt: post.likeCnt ?? 0)
        if let url = post.media.photoUrl { // Render Photo
            cell.mediaImageView.sd_setImage(with: url)
            cell.playBttnImageView.alpha = 0
            
            cell.mediaImageView.isPinchable = true
            
        } else if let url = post.media.thumbnailUrl { // Render Video Thumbnail
            cell.mediaImageView.sd_setImage(with: url)
            cell.mediaImageView.isPinchable = true
            cell.playBttnImageView.alpha = 1
        } else {
            cell.mediaImageView.sd_cancelCurrentImageLoad()
            cell.mediaImageView.image = nil
        }
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedPost != nil {
            performSegue(withIdentifier: "showPostSingle", sender: selectedPost)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95 + view.frame.width * 1.34
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
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
        self.performSegue(withIdentifier: "showCommentSingle", sender: post)
    }
    func userBttnPressed(user: User) {
        if User.me.id == user.id {
            performSegue(withIdentifier: "showProfileSingle", sender: user)
        } else {
            performSegue(withIdentifier: "showOtherProfileSingle", sender: user)
        }
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
                    //self.handlePostsRefresh(self.postsRefreshControl)
                    
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
    func liveStreamPressed(user: User){
        self.performSegue(withIdentifier: "showLive", sender: user)
    }
}

