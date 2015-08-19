//
//  TabBarController.swift
//  HNReader
//
//  Created by Zhang on 15/8/19.
//  Copyright (c) 2015年 FryBase. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let topStoriesTVC = self.storyboard?.instantiateViewControllerWithIdentifier("StoriesTableViewController") as! StoriesTableViewController
        topStoriesTVC.title = "Top"
        topStoriesTVC.tabBarItem = UITabBarItem(tabBarSystemItem: .TopRated, tag: 0)
        
        let recentStoriesTVC = self.storyboard?.instantiateViewControllerWithIdentifier("StoriesTableViewController") as! StoriesTableViewController
        recentStoriesTVC.title = "Recent"
        recentStoriesTVC.tabBarItem = UITabBarItem(tabBarSystemItem: .Recents, tag: 1)
        
        self.viewControllers = [UINavigationController(rootViewController: topStoriesTVC), UINavigationController(rootViewController: recentStoriesTVC)]
        
    }

}
