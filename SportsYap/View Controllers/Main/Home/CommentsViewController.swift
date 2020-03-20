//
//  CommentsViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/25/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class CommentsViewController: UIViewController {

    @IBOutlet var commentBottomSpacing: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var commentTextField: UITextField!
    @IBOutlet var profileImageView: UIImageView!
    
    var post: Post!
    var initialLoad = true
    var secondLoad = false
    
    var sportsyapGifNames = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        ParentScrollingViewController.shared.enabled(is: false)
        
        User.me.currentPost = post
        
        if commentBottomSpacing.constant != 0 {
            commentBottomSpacing.constant = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "CommentGifCell", bundle: nil), forCellReuseIdentifier: "commentGifCell")
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 45))
        commentTextField.leftView = paddingView
        commentTextField.leftViewMode = .always
        
        loadComments()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        if let url = User.me.profileImage{
            profileImageView.imageFromUrl(url: url)
        }
        
        sportsyapGifNames.append("ko.gif")
        sportsyapGifNames.append("And1.gif")
        sportsyapGifNames.append("choke.gif")
        sportsyapGifNames.append("fistShake.gif")
        sportsyapGifNames.append("IssaThree.gif")
        sportsyapGifNames.append("LIT.gif")
        sportsyapGifNames.append("Shh.gif")
        sportsyapGifNames.append("batFlip_1.gif")
        sportsyapGifNames.append("Homer.gif")
        sportsyapGifNames.append("RallyMonkey.gif")
        sportsyapGifNames.append("robbed.gif")
        sportsyapGifNames.append("youreOut.gif")
        sportsyapGifNames.append("BigCatch.gif")
        sportsyapGifNames.append("Flag.gif")
        sportsyapGifNames.append("IssaTD_1.gif")
        sportsyapGifNames.append("ItsGood.gif")
        sportsyapGifNames.append("MakeNoise.gif")
        sportsyapGifNames.append("goal.gif")
        sportsyapGifNames.append("hockey_goal.gif")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        loadComments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    func loadComments(){
        ApiManager.shared.comments(for: post, page: 1, onSuccess: { (comments) in
            self.post.comments = comments
            self.tableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                //self.scrollToBottom()
            })
            
        }, onError: voidErr)
    }
    
    func scrollToBottom()  {
        guard !initialLoad else {
            initialLoad = false
            return
        }
        
        let point = CGPoint(x: 0, y: self.tableView.contentSize.height + self.tableView.contentInset.bottom - self.tableView.frame.height)
        if point.y >= 0{
            self.tableView.setContentOffset(point, animated: true)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let tabBarHeight = UIScreen.main.bounds.height - TabBarViewController.sharedInstance.tabBar.frame.origin.y
            commentBottomSpacing.constant = keyboardRectangle.height - tabBarHeight
            if self.navigationController == nil || singlePost {
                commentBottomSpacing.constant += 50
            }
        }
    }
    
    @objc func deletePressed(sender: UIButton) {
        let comment = post.comments[sender.tag]
        deleteComment(comment: comment, row: sender.tag)
    }
    
    private func deleteComment(comment: Comment, row: Int) {
        ApiManager.shared.deleteComment(for: post, comment: comment, onSuccess: {
            self.post.comments.remove(at: row)
            self.tableView.reloadData()
        }) { (error) in
            self.alert(message: "Error deleting your comment. Please try again.")
            self.loadComments()
        }
    }
    
    //MARK: IBAction
    @IBAction func backBttnPressed(_ sender: Any) {
        if self.navigationController != nil{
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func commentBttnPressed(_ sender: Any) {
        let text = commentTextField.text ?? ""
        ApiManager.shared.postComment(for: post, text: text, onSuccess: {
            self.commentTextField.text = ""
            self.commentTextField.resignFirstResponder()
            self.commentBottomSpacing.constant = 0
            self.loadComments()
        }, onError: voidErr)
    }
    
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            deleteComment(comment: post.comments[indexPath.row], row: indexPath.row)
            /*
            ApiManager.shared.deleteComment(for: post, comment: post.comments[indexPath.row], onSuccess: {
                self.post.comments.remove(at: indexPath.row)
                self.tableView.reloadData()
            }) { (error) in
                self.alert(message: "Error deleting your comment. Please try again.")
                self.loadComments()
            }
            */
        }
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = post.comments[indexPath.row]
    
        if comment.text.contains("media.tenor.com/images/") || comment.text.contains(".gif") {
            // gif
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentGifCell") as! CommentGifCell
            
            cell.isVerifiedImageView.alpha = comment.user.verified ? 1 : 0
            cell.timeAgoLbl.text = comment.createdAt.timeAgoSince()
            if let url = comment.user.profileImage{
                cell.profileImageView.imageFromUrl(url: url)
            }else{
                cell.profileImageView.image = #imageLiteral(resourceName: "default-profile")
            }
            
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(deletePressed(sender:)), for: .touchUpInside)
            cell.addGifImageView(gifUrl: comment.text)
            
            cell.textLbl.attributedText = NSMutableAttributedString().bold(comment.user.name)
            
            return cell
            
        } else {
            // regular comment
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentTableViewCell
            
            cell.isVerifiedImageView.alpha = comment.user.verified ? 1 : 0
            cell.timeAgoLbl.text = comment.createdAt.timeAgoSince()
            if let url = comment.user.profileImage{
                cell.profileImageView.imageFromUrl(url: url)
            }else{
                cell.profileImageView.image = #imageLiteral(resourceName: "default-profile")
            }
            
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(deletePressed(sender:)), for: .touchUpInside)
            
            cell.textLbl.attributedText = NSMutableAttributedString().bold(comment.user.name).normal(" \(comment.text)")
            
            return cell
        }
        
        
        
        /*
        if let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as? CommentTableViewCell{
            let comment = post.comments[indexPath.row]
            cell.isVerifiedImageView.alpha = comment.user.verified ? 1 : 0
            cell.timeAgoLbl.text = comment.createdAt.timeAgoSince()
            if let url = comment.user.profileImage{
                cell.profileImageView.imageFromUrl(url: url)
            }else{
                cell.profileImageView.image = #imageLiteral(resourceName: "default-profile")
            }
            
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(deletePressed(sender:)), for: .touchUpInside)
            
            if comment.text.contains("media.tenor.com/images/") {
                // gif
                cell.textLbl.attributedText = NSMutableAttributedString().bold(comment.user.name)
                cell.addGifImageView(gifUrl: comment.text)

            } else {
                // regular comment
                cell.textLbl.attributedText = NSMutableAttributedString().bold(comment.user.name).normal(" \(comment.text)")
            }

            return cell
        }
        
        return UITableViewCell()
        */
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
