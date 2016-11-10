//
//  CustomTabBar.swift
//  HideSeek
//
//  Created by apple on 7/17/16.
//  Copyright © 2016 mj. All rights reserved.
//

import Foundation

extension UITabBar {
    func setBgColor(_ color: UIColor) {
        self.backgroundImage = getImageWithColor(color)
    }
    
    func getImageWithColor(_ color: UIColor) ->UIImage{
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0);
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext();
        context?.setFillColor(color.cgColor);
        context?.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image!;
    }
}
