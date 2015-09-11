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

class CommentTableViewController: UITableViewController {
    
    private let commentUrl = "https://hacker-news.firebaseio.com/v0/item/"
    private let reuseIdentifier = "commentCell"
    private let commentCache = NSCache()
    
    var comments = [JSON]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CommentTableViewCell
        
        // Configure the cell...
        if let jsonData: AnyObject = commentCache.objectForKey(comments[indexPath.row].stringValue) {
            let commentData = JSON(jsonData)
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
            
//            var webView = cell.contentView.viewWithTag(110) as? WKWebView
//            if webView == nil {
////                webView = WKWebView(frame: CGRectMake(0, 0, 400, 400))
//                webView = WKWebView()
////                webView?.backgroundColor = UIColor.redColor()
//                webView?.tag = 110
//                cell.contentView.addSubview(webView!)
//                
//                webView!.setTranslatesAutoresizingMaskIntoConstraints(false)
//                let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[webView]-[commentButton]", options: nil, metrics: nil, views: ["commentButton": cell.commentButton, "webView": webView!])
//                let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[userButton]-[webView(>=100)]-|", options: nil, metrics: nil, views: ["userButton": cell.userButton, "webView": webView!])
//                cell.contentView.addConstraints(horizontalConstraints)
//                cell.contentView.addConstraints(verticalConstraints)
//            }
//            webView?.loadHTMLString(commentData["text"].stringValue, baseURL: nil)
            
        } else {
            Alamofire.request(.GET, commentUrl + "\(comments[indexPath.row].stringValue).json").responseJSON { (req, res, result) in
                if result.isFailure {
                    NSLog("Error: \(result.error)")
                    print(req)
                    print(res)
                } else {
                    self.commentCache.setObject(result.value!, forKey: self.comments[indexPath.row].stringValue)
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }
        }
        
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
                    ctvc.comments = JSON(commentCache.objectForKey(comments[indexPath.row].stringValue)!)["kids"].arrayValue
                }
            }
        }
    }

}
