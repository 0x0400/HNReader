//
//  Helper.swift
//  HNReader
//
//  Created by Zhang on 15/8/19.
//  Copyright (c) 2015年 FryBase. All rights reserved.
//

import Foundation


class Helper {
    
    static let SecondsInOneDay = 24 * 60 * 60
    static let SecondsInOneHour = 60 * 60
    static let SecondsInOneMinutes = 60
    
    class func timeAgoFromTimeInterval(time: NSTimeInterval) -> String {
        
        let delta = Int(time)
        if delta <= SecondsInOneMinutes {
            return "Just Now"
        }
        if delta < SecondsInOneHour {
            return "\(delta / SecondsInOneMinutes) minutes ago"
        }
        if delta < SecondsInOneDay {
            return "\(delta / SecondsInOneHour) hours ago"
        }
        return "\(delta / SecondsInOneDay) days ago"
    }

}