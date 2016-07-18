//
//  CustomTabBar.swift
//  HideSeek
//
//  Created by apple on 7/17/16.
//  Copyright © 2016 mj. All rights reserved.
//

import Foundation

extension UITabBar {
    func setBgColor(color: UIColor) {
        self.backgroundImage = getImageWithColor(color)
    }
    
    func getImageWithColor(color: UIColor) ->UIImage{
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0);
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
}