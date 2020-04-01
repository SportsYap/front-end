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

    @IBOutlet weak var commentBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var post: Post!
    
    private var initialLoad = true
    private var secondLoad = false
    
    private var sportsyapGifNames = [String]()
    
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
        
        profileImageView.sd_setImage(with: User.me.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))
        
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
}

extension CommentsViewController {
    private func loadComments() {
        ApiManager.shared.comments(for: post, page: 1, onSuccess: { (comments) in
            self.post.comments = comments
            self.tableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                //self.scrollToBottom()
            })
            
        }, onError: voidErr)
    }
    
    private func scrollToBottom()  {
        guard !initialLoad else {
            initialLoad = false
            return
        }
        
        let point = CGPoint(x: 0, y: self.tableView.contentSize.height + self.tableView.contentInset.bottom - self.tableView.frame.height)
        if point.y >= 0 {
            self.tableView.setContentOffset(point, animated: true)
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let tabBarHeight = UIScreen.main.bounds.height - TabBarViewController.sharedInstance.tabBar.frame.origin.y
            
            commentBottomSpacing.constant = keyboardRectangle.height - tabBarHeight
            if navigationController == nil || singlePost {
                commentBottomSpacing.constant += 50
            }
        }
    }
}

extension CommentsViewController {
    //MARK: IBAction
    @IBAction func onBack(_ sender: Any) {
        if navigationController != nil{
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onComment(_ sender: Any) {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = post.comments[indexPath.row]
    
        if comment.text.contains("media.tenor.com/images/") || comment.text.contains(".gif") {
            // gif
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentGifCell") as! CommentGifCell
            cell.comment = comment
            return cell
        } else {
            // regular comment
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentTableViewCell
            cell.comment = comment
            return cell
        }
    }
}
