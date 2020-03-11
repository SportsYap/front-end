//
//  ParentScrollingViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 4/23/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class ParentScrollingViewController: UIViewController {

    static var shared: ParentScrollingViewController!
    
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("sdfsffssf")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ParentScrollingViewController.shared = self
        
        scrollView.contentSize = CGSize(width: self.view.frame.width*2, height: self.view.frame.height)
        scrollView.setContentOffset(CGPoint(x: self.view.frame.width, y: 0), animated: false)
    }
    
    func enabled(is enabled: Bool){
        guard ParentScrollingViewController.shared != nil else { return }
        ParentScrollingViewController.shared.scrollView.isScrollEnabled = enabled
    }
    
    func scrollToCamera(){
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        enabled(is: true)
        children[0].children[0].viewWillAppear(true)
    }
    
    func scrollToTabs(){
        scrollView.setContentOffset(CGPoint(x: self.view.frame.width, y: 0), animated: true)
        enabled(is: TabBarViewController.sharedInstance.selectedIndex == 0)
        TagGameViewController.preselectedGame = nil
        
        if let selected = TabBarViewController.sharedInstance.selectedViewController as? UINavigationController{
            if let currentVC = selected.viewControllers.last{
                currentVC.viewWillAppear(true)
            }
        }
    }
    
}

extension ParentScrollingViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == view.frame.width{
            TagGameViewController.preselectedGame = nil
            enabled(is: TabBarViewController.sharedInstance.selectedIndex == 0)
            children[1].viewWillAppear(true)
            children[0].children[0].viewWillDisappear(true)
        }else if scrollView.contentOffset.x == 0{
            children[0].children[0].viewWillAppear(true)
        }
    }
}
