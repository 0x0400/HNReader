//
//  UIColor+Hex.swift
//  HNReader
//
//  Created by Zhang on 15/8/12.
//  Copyright (c) 2015年 FryBase. All rights reserved.
//

import UIKit


extension UIColor {
    
    convenience init(hex: Int) {
        
        let components = (
            Red: CGFloat((hex >> 16) & 0xff) / 255,
            Green: CGFloat((hex >> 08) & 0xff) / 255,
            Blue: CGFloat((hex >> 00) & 0xff) / 255
        )
        
        self.init(red: components.Red, green: components.Green, blue: components.Blue, alpha: 1)
    }
    
}