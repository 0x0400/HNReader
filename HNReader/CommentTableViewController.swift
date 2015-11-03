//
//  CommentTableViewController.swift
//  HNReader
//
//  Created by Zhang on 15/8/14.
//  Copyright (c) 2015年 FryBase. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON
import DTCoreText
import MJRefresh

class CommentTableViewController: UITableViewController {
    
    private let commentUrl = "https://hacker-news.firebaseio.com/v0/item/"
    private let reuseIdentifier = "commentCell"
    private var commentCache = [JSON]()
    
    var comments = [JSON]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableViewAutomaticDimension

        tableView.footer = MJRefreshAutoNormalFooter(refreshingBlock: { () -> Void in
            self.loadComments()
        })

        loadComments()
    }

    func loadComments() {
        let index = commentCache.count
        if index == comments.count {
            self.tableView.footer.endRefreshing()
            return
        }
        var endIndex = index + 20
        if endIndex > comments.count {
            endIndex = comments.count
        }

        let fetchGroup = dispatch_group_create()
        for curIdx in index..<endIndex {
            commentCache.append(JSON(NSNull))
            dispatch_group_enter(fetchGroup)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
                Alamofire.request(.GET, self.commentUrl + "\(self.comments[curIdx].stringValue).json").responseJSON { response in
                    if response.result.isFailure {
                        NSLog("Error: \(response.result.error)")
                        print(response.request)
                        print(response.response)
                    } else {
                        self.commentCache[curIdx] = JSON(response.result.value!)
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentCache.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CommentTableViewCell
        
        // Configure the cell...
        let commentData = commentCache[indexPath.row]
        cell.userButton.setTitle(commentData["by"].stringValue, forState: .Normal)
        cell.timeLabel.text = Helper.timeAgoFromTimeInterval(NSDate().timeIntervalSince1970 - NSTimeInterval(commentData["time"].intValue))

        let kids = commentData["kids"].arrayValue.count
        if kids == 0 {
            cell.commentButton.hidden = true
        } else {
            cell.commentButton.setTitle(String(kids), forState: .Normal)
            cell.commentButton.hidden = false
        }
        
        let htmlText = NSAttributedString(HTMLData: commentData["text"].stringValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, options: [DTUseiOS6Attributes: NSNumber(bool: true)], documentAttributes: nil)
        cell.contentTextView.attributedText = htmlText
        cell.contentTextView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)

        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showProfile" {
            let user = (sender as! UIButton).titleLabel?.text
            if let ptvc = segue.destinationViewController as? ProfileTableViewController {
                ptvc.user = user!
            }
        } else if segue.identifier == "showComments" {
            let buttonPosition = sender?.convertPoint(CGPointZero, toView: self.tableView)
            if let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition!) {
                if let ctvc = segue.destinationViewController as? CommentTableViewController {
                    ctvc.comments = commentCache[indexPath.row]["kids"].arrayValue
                }
            }
        }
    }

}
