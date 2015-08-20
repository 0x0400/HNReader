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

class StoriesTableViewController: UITableViewController {
    
    private let storyUrl = "https://hacker-news.firebaseio.com/v0/item/"
    private let reuseIdentifier = "StoriesCell"
    private let storiesCache = NSCache()
    
    var topStories = JSON(NSNull)
    var storiesUrl = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "reloadData", forControlEvents: .ValueChanged)
        
        reloadData()
    }
    
    func reloadData() {
        Alamofire.request(.GET, storiesUrl).responseJSON { (req, res, json, error) in
            if error != nil {
                println(req)
                println(res)
            } else {
                self.topStories = JSON(json!)
                self.storiesCache.removeAllObjects()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topStories.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! StoriesTableViewCell

        // Configure the cell...
        cell.rowButton.setTitle(String(indexPath.row), forState: UIControlState.Normal)
        if let jsonData: AnyObject = storiesCache.objectForKey(topStories[indexPath.row].stringValue) {
            let storyData = JSON(jsonData)
            cell.titleLabel.text = storyData["title"].stringValue
            cell.userButton.setTitle(storyData["by"].stringValue, forState: .Normal)
            let url = storyData["url"].stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            cell.urlLabel.text = NSURL(string: url)?.host ?? ""
            cell.timeLabel.text = Helper.timeAgoFromTimeInterval(NSDate().timeIntervalSince1970 - NSTimeInterval(storyData["time"].intValue))
            cell.pointLabel.text = storyData["score"].stringValue + " points"
            cell.commentButton.setTitle(String(storyData["kids"].arrayValue.count), forState: .Normal)
        } else {
            Alamofire.request(.GET, storyUrl + "\(topStories[indexPath.row].stringValue).json").responseJSON { (req, res, json, error) in
                if error != nil {
                    NSLog("Error: \(error)")
                    println(req)
                    println(res)
                } else {
                    self.storiesCache.setObject(json!, forKey: self.topStories[indexPath.row].stringValue)
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }
        }

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
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                if let svc = segue.destinationViewController as? StoryViewController {
                    svc.storyData = JSON(storiesCache.objectForKey(topStories[indexPath.row].stringValue)!)
                }
            }
        } else if segue.identifier == "showComments" {
            var buttonPosition = sender?.convertPoint(CGPointZero, toView: self.tableView)
            if let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition!) {
                if let ctvc = segue.destinationViewController as? CommentTableViewController {
                    ctvc.comments = JSON(storiesCache.objectForKey(topStories[indexPath.row].stringValue)!)["kids"].arrayValue
                }
            }
        }
    }
}
