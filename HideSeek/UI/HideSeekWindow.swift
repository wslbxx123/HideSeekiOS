//
//  HideSeekWindow.swift
//  HideSeek
//
//  Created by apple on 8/12/16.
//  Copyright © 2016 mj. All rights reserved.
//

extension UIWindow {
    func visibleViewController() -> UIViewController {
        let rootViewController = self.rootViewController
        return getVisibleViewControllerFrom(rootViewController!)
    }
    
    func getVisibleViewControllerFrom(viewController: UIViewController) -> UIViewController {
        if viewController.isKindOfClass(UINavigationController) {
            return getVisibleViewControllerFrom((viewController as! UINavigationController).visibleViewController!)
        } else if viewController.isKindOfClass(UITabBarController) {
            return getVisibleViewControllerFrom((viewController as! UITabBarController).selectedViewController!)
        } else {
            if (viewController.presentedViewController != nil) {
                return getVisibleViewControllerFrom(viewController.presentedViewController!)
            } else {
                return viewController
            }
         }
    }
}
