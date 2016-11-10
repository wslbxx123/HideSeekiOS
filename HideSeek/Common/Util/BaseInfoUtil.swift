//
//  BaseInfoUtil.swift
//  HideSeek
//
//  Created by apple on 6/22/16.
//  Copyright © 2016 mj. All rights reserved.
//

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class BaseInfoUtil {
    class func stringToRGB(_ colorStr:String)->UIColor {
        var cStr:String = colorStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if(cStr.hasPrefix("#")) {
            cStr = (cStr as NSString).substring(from: 1)
        }
        
        if(cStr.characters.count != 6) {
            return UIColor.gray
        }
        
        let rStr = (cStr as NSString).substring(to: 2)
        let gStr = ((cStr as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bStr = ((cStr as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rStr).scanHexInt32(&r)
        Scanner(string: gStr).scanHexInt32(&g)
        Scanner(string: bStr).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    class func getLabelHeight(_ size: CGFloat, width: CGFloat, message: String?) -> CGFloat{
        if message == nil {
            return 0
        }
        
        let font = UIFont.systemFont(ofSize: size)
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let attributes = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
        let size = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let stringRect = message?.boundingRect(with: size, options: option, attributes: attributes as? [String : AnyObject], context: nil)
        return stringRect!.height + 10
    }
    
    class func getLabelWidth(_ size: CGFloat, height: CGFloat, message: String?) -> CGFloat{
        if message == nil {
            return 0
        }
        
        let font = UIFont.systemFont(ofSize: size)
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let attributes = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
        let size = CGSize(width: CGFloat(MAXFLOAT), height: height)
        let stringRect = message?.boundingRect(with: size, options: option, attributes: attributes as? [String : AnyObject], context: nil)
        return stringRect!.width
    }

    class func cancelButtonDelay(_ tableView: UITableView) {
        for view in tableView.subviews {
            if view.isKind(of: UIScrollView.self) {
                let scroll = view as! UIScrollView
                scroll.delaysContentTouches = false
            }
        }
    }
    
    class func cancelButtonDelay(_ collectionView: UICollectionView) {
        for view in collectionView.subviews {
            if view.isKind(of: UIScrollView.self) {
                let scroll = view as! UIScrollView
                scroll.delaysContentTouches = false
            }
        }
    }
    
    class func cancelButtonDelay(_ cell: UITableViewCell) {
        for view in cell.subviews
        {
            if view.isKind(of: UIScrollView.self)
            {
                let scroll = view as! UIScrollView;
                scroll.delaysContentTouches = false;
            }
        }
    }
    
    class func cancelButtonDelay(_ cell: UICollectionViewCell) {
        for view in cell.subviews
        {
            if view.isKind(of: UIScrollView.self)
            {
                let scroll = view as! UIScrollView;
                scroll.delaysContentTouches = false;
            }
        }
    }
    
    class func removeNullFromDictionary(_ dictionary: NSDictionary) -> NSMutableDictionary{
        let mutableDictionary = NSMutableDictionary()
        
        for key in dictionary.allKeys {
            let value = dictionary.object(forKey: key);
            
            if (value != nil && !(value! as AnyObject).isKind(of: NSNull.self)) {
                if (value! as AnyObject).isKind(of: NSString.self) {
                    mutableDictionary.setValue(dictionary.object(forKey: key) as! NSString, forKey: key as! String);
                }
            }
        }
        
        return mutableDictionary
    }
    
    class func getRootViewController() -> UIViewController{
        var controller: UIViewController
        let systemVersion: NSString = UIDevice.current.systemVersion as NSString
        if systemVersion.floatValue < 6.0 {
            let array = UIApplication.shared.windows
            let window = array[0]
            
            let uiview = window.subviews[0]
            controller = uiview.next as! UIViewController
        } else {
            controller = (UIApplication.shared.keyWindow?.rootViewController)!
        }
        
        return controller
    }
    
    class func getCachesPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true)
        var cachePath = paths[0]
        cachePath = cachePath.appendingFormat("/%@", Bundle.main.bundleIdentifier!)
        return cachePath
    }
    
    class func cachefileSize() -> String {
        let basePath = getCachesPath()
        let fileManager = FileManager.default
        var total: Float = 0
        if fileManager.fileExists(atPath: basePath){
            let childrenPath = fileManager.subpaths(atPath: basePath)
            if childrenPath != nil{
                for path in childrenPath!{
                    let childPath = (basePath + "/") + path
                    do{
                        let attr = try fileManager.attributesOfItem(atPath: childPath)
                        let fileSize = (attr[FileAttributeKey.size] as! NSNumber).floatValue
                        total += fileSize
                        
                    }catch _{
                        
                    }
                }
            }
        }
        
        return NSString(format: "%.2f MB", total / 1024.0 / 1024.0 ) as String
    }
    
    class func clearCache() -> Bool{
        var result = true
        let basePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: basePath!){
            let childrenPath = fileManager.subpaths(atPath: basePath!)
            for childPath in childrenPath!{
                let cachePath = ((basePath)! + "/") + childPath
                do{
                    try fileManager.removeItem(atPath: cachePath)
                }catch _{
                    result = false
                }
            }
        }
        
        return result
    }
    
    class func getIntegerFromAnyObject(_ object: Any?) -> Int {
        return object is NSString ?
            (object as! NSString).integerValue :
            (object as! NSNumber).intValue
    }
    
    class func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! NSString
        let buildVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as! NSString
        
        return (version as String) + "." + (buildVersion as String)
    }
    
    class func topViewController() -> UIViewController? {
        var resultViewController: UIViewController? = nil
        // 多window的情况下， 需要对window进行有效选择选择
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            resultViewController = getTopViewController(rootViewController)
            while resultViewController?.presentedViewController != nil {
                resultViewController = resultViewController?.presentedViewController
            }
        }
        return resultViewController
    }
    
    class func getTopViewController(_ object: AnyObject!) -> UIViewController? {
        if let navigationController = object as? UINavigationController {
            return getTopViewController(navigationController.viewControllers.last)
        }
        else if let tabBarController = object as? UITabBarController {
            if tabBarController.selectedIndex < tabBarController.viewControllers?.count {
                return getTopViewController(tabBarController.viewControllers![tabBarController.selectedIndex])
            }
        }
        else if let vc = object as? UIViewController {
            return vc
        }
        
        return nil
    }
}
