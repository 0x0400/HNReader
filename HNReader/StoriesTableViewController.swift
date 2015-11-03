//
//  StoriesTableViewController.swift
//  HNReader
//
//  Created by Zhang on 15/8/12.
//  Copyright (c) 2015年 FryBase. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MJRefresh

class StoriesTableViewController: UITableViewController {
    
    private let storyUrl = "https://hacker-news.firebaseio.com/v0/item/"
    private let reuseIdentifier = "StoriesCell"
    private var storiesCache = [JSON]()
    
    var topStories = JSON(NSNull)
    var storiesUrl = ""
    var numberPerFetch = 20

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.footer = MJRefreshAutoNormalFooter(refreshingBlock: { () -> Void in
            self.loadStories()
        })

        loadAllStoriesID()
    }

    func loadStories() {
        let index = storiesCache.count
        if index == topStories.count {
            self.tableView.footer.endRefreshing()
            return
        }
        var endIndex = index + 20
        if endIndex > topStories.count {
            endIndex = topStories.count
        }
        
        let fetchGroup = dispatch_group_create()
        for curIdx in index..<endIndex {
            storiesCache.append(JSON(NSNull))
            dispatch_group_enter(fetchGroup)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
                Alamofire.request(.GET, self.storyUrl + "\(self.topStories[curIdx].stringValue).json").responseJSON { response in
                    if response.result.isFailure {
                        NSLog("Error: \(response.result.error)")
                        print(response.request)
                        print(response.response)
                    } else {
                        self.storiesCache[curIdx] = JSON(response.result.value!)
                    }
                    dispatch_group_leave(fetchGroup)
                }
            }
        }
        dispatch_group_notify(fetchGroup, dispatch_get_main_queue()) {
            self.tableView.reloadData()
            self.tableView.footer.endRefreshing()
        }
    }
    
    func loadAllStoriesID() {
        Alamofire.request(.GET, storiesUrl).responseJSON { response in
            if response.result.isFailure {
                print(response.request)
                print(response.response)
            } else {
                self.topStories = JSON(response.result.value!)
                self.loadStories()
            }
        }
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storiesCache.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! StoriesTableViewCell

        // Configure the cell...
        cell.rowButton.setTitle(String(indexPath.row), forState: UIControlState.Normal)
        let storyData = storiesCache[indexPath.row]
        cell.titleLabel.text = storyData["title"].stringValue
        cell.userButton.setTitle(storyData["by"].stringValue, forState: .Normal)
        let url = storyData["url"].stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        cell.urlLabel.text = NSURL(string: url)?.host ?? ""
        cell.timeLabel.text = Helper.timeAgoFromTimeInterval(NSDate().timeIntervalSince1970 - NSTimeInterval(storyData["time"].intValue))
        cell.pointLabel.text = storyData["score"].stringValue + " points"
        cell.commentButton.setTitle(String(storyData["kids"].arrayValue.count), forState: .Normal)

        return cell
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showProfile" {
            let user = (sender as! UIButton).titleLabel?.text
            if let ptvc = segue.destinationViewController as? ProfileTableViewController {
                ptvc.user = user!
            }
        } else if segue.identifier == "showStory" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let svc = segue.destinationViewController as? StoryViewController {
                    svc.storyData = storiesCache[indexPath.row]
                }
            }
        } else if segue.identifier == "showComments" {
            let buttonPosition = sender?.convertPoint(CGPointZero, toView: self.tableView)
            if let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition!) {
                if let ctvc = segue.destinationViewController as? CommentTableViewController {
                    ctvc.comments = storiesCache[indexPath.row]["kids"].arrayValue
                }
            }
        }
    }
}
