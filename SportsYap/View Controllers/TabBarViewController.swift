//
//  TabBarViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 8/8/16.
//  Copyright © 2016 Alex Pelletier. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    static var sharedInstance: TabBarViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TabBarViewController.sharedInstance = self
        
        self.tabBar.tintColor = UIColor(hex: "262626")
        self.tabBar.unselectedItemTintColor = UIColor(hex: "BBBABA")
    }

    
}
