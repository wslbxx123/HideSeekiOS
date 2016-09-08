//
//  BadgeUtil.swift
//  HideSeek
//
//  Created by apple on 9/7/16.
//  Copyright © 2016 mj. All rights reserved.
//

class BadgeUtil {
    class func addMeBadge(num: Int) {
        let tabBarController = BaseInfoUtil.getRootViewController() as! ViewController
        
        let item = tabBarController.uiTabBar.items![3]
        if item.badgeValue == nil {
            item.badgeValue = "0"
        }
        let badgeValue = NSString(string: item.badgeValue!).integerValue
        item.badgeValue = NSString(format: "%d", badgeValue + num) as String
        
        let navigationController = tabBarController.viewControllers![3] as! UINavigationController
        let meController = navigationController.viewControllers[0] as! MeController
        meController.setBadgeValue()
    }
    
    class func updateMeBadge() {
        addMeBadge(1)
    }
    
    class func clearMeBadge() {
        let tabBarController = BaseInfoUtil.getRootViewController() as! ViewController
        
        let item = tabBarController.uiTabBar.items![3]
        item.badgeValue = nil
        
        let navigationController = tabBarController.viewControllers![3] as! UINavigationController
        let meController = navigationController.viewControllers[0] as! MeController
        meController.clearBadgeValue()
    }
}
