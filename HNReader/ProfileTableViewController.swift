//
//  ProfileTableViewController.swift
//  HNReader
//
//  Created by Zhang on 15/8/12.
//  Copyright (c) 2015年 FryBase. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import DTCoreText


class ProfileTableViewController: UITableViewController {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var karmaLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    
    var user = ""
    let url = "https://hacker-news.firebaseio.com/v0/user/"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.delegate = self
        
        if !user.isEmpty {
            Alamofire.request(.GET, url + "\(user).json").responseJSON { (req, res, result) in
                if result.isFailure {
                    NSLog("Error: \(result.error)")
                    print(req)
                    print(res)
                } else {
                    let userData = JSON(result.value!)
                    self.userLabel.text = userData["id"].stringValue
                    self.createdLabel.text = Helper.timeAgoFromTimeInterval(NSDate().timeIntervalSince1970 - NSTimeInterval(userData["created"].intValue))
                    self.karmaLabel.text = userData["karma"].stringValue
                    let htmlText = NSAttributedString(HTMLData: userData["about"].stringValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, options: [DTUseiOS6Attributes: NSNumber(bool: true)], documentAttributes: nil)
                    self.aboutTextView.attributedText = htmlText
                    self.aboutTextView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                    
                    self.tableView.layoutIfNeeded()
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }

}
