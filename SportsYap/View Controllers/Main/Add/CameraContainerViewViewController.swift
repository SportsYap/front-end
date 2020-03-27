//
//  CameraContainerViewViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/29/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class CameraContainerViewViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var cameraLbl: UILabel!
    @IBOutlet var liveLbl: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var containerViewController: UIView!
    
    var currentIdentifier = ""
    var isSwitching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let isOnCamera = ParentScrollingViewController.shared.scrollView.contentOffset.x == 0
        if isOnCamera{
            setChildVC()
        }
        
        scrollView.alpha = TagGameViewController.preselectedGame == nil ? 1 : 0
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if ParentScrollingViewController.shared != nil{
            if ParentScrollingViewController.shared.scrollView.contentOffset.x != 0{
                self.currentIdentifier = ""
                self.isSwitching = false
                for vc in self.children{
                    vc.viewWillDisappear(false)
                    vc.view.removeFromSuperview()
                    vc.removeFromParent()
                }
            }
        }
    }
    
    func setChildVC(){
        let identifier = scrollView.contentOffset.x == 0 ? "cameraVC" : "liveVC"
        guard identifier != currentIdentifier && !isSwitching else { return }
        print(identifier)
        isSwitching = true
        currentIdentifier = identifier
        
        let delay: Double = self.children.count == 0 ? 0 : 2
        for vc in self.children{
            vc.viewWillDisappear(false)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
        
        // Allow time for previous view to release camera
        DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
            let childVC = UIStoryboard(name: "GameDay", bundle: nil).instantiateViewController(withIdentifier: identifier)
            childVC.willMove(toParent: self)
            
            // Add to containerview
            childVC.view.translatesAutoresizingMaskIntoConstraints = false
            self.containerViewController.addSubview(childVC.view)
            self.addChild(childVC)
            
            NSLayoutConstraint.activate([
                childVC.view.leadingAnchor.constraint(equalTo: self.containerViewController.leadingAnchor, constant: 0),
                childVC.view.trailingAnchor.constraint(equalTo: self.containerViewController.trailingAnchor, constant: 0),
                childVC.view.topAnchor.constraint(equalTo: self.containerViewController.topAnchor, constant: 0),
                childVC.view.bottomAnchor.constraint(equalTo: self.containerViewController.bottomAnchor, constant: 0)
            ])
            
            childVC.didMove(toParent: self)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) { // Prevent Rapid back and forth
            self.isSwitching = false
        }
    }
    
    //MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0{
            cameraLbl.alpha = 1
            liveLbl.alpha = 0.5
        }else{
            cameraLbl.alpha = 0.5
            liveLbl.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.setChildVC()
        }
    }
    
    //MARK: IBAction
    @IBAction func cameraBttnPressed(_ sender: Any) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    @IBAction func liveBttnPressed(_ sender: Any) {
        scrollView.setContentOffset(CGPoint(x: 50, y: 0), animated: true)
    }
    
}
