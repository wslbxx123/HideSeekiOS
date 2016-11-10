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
    
    func getVisibleViewControllerFrom(_ viewController: UIViewController) -> UIViewController {
        if viewController.isKind(of: UINavigationController.self) {
            return getVisibleViewControllerFrom((viewController as! UINavigationController).visibleViewController!)
        } else if viewController.isKind(of: UITabBarController.self) {
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
