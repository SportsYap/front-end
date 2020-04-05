//
//  TabBarViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 8/8/16.
//  Copyright © 2016 Alex Pelletier. All rights reserved.
//

import UIKit
import SideMenu

class TabBarViewController: UITabBarController {
    
    static var sharedInstance: TabBarViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TabBarViewController.sharedInstance = self
        
        self.tabBar.tintColor = UIColor(hex: "009BFF")
        self.tabBar.unselectedItemTintColor = UIColor.black
        
        let cameraViewController = storyboard?.instantiateViewController(withIdentifier: "SideMenuNavigationController") as? SideMenuNavigationController
        cameraViewController?.presentingViewControllerUseSnapshot = true
        SideMenuManager.default.leftMenuNavigationController = cameraViewController

        let settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController?.settings = settings

        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let vc = segue.destination as? SideMenuNavigationController {
            vc.settings = makeSettings()
        }
    }
}

extension TabBarViewController {
    private func makeSettings() -> SideMenuSettings {
        let presentationStyle = SideMenuPresentationStyle.viewSlideOut
        presentationStyle.presentingScaleFactor = 1

        var settings = SideMenuSettings()
        settings.pushStyle = .subMenu
        settings.presentingViewControllerUseSnapshot = true
        settings.presentationStyle = presentationStyle
        settings.animationOptions = .curveLinear
        settings.menuWidth = min(view.frame.width, view.frame.height)
        settings.statusBarEndAlpha = 0.0
        settings.enableSwipeToDismissGesture = false

        return settings
    }
}
