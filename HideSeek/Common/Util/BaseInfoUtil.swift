//
//  BaseInfoUtil.swift
//  HideSeek
//
//  Created by apple on 6/22/16.
//  Copyright © 2016 mj. All rights reserved.
//

import Foundation
import UIKit

class BaseInfoUtil {
    class func stringToRGB(colorStr:String)->UIColor {
        var cStr:String = colorStr.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if(cStr.hasPrefix("#")) {
            cStr = (cStr as NSString).substringFromIndex(1)
        }
        
        if(cStr.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rStr = (cStr as NSString).substringToIndex(2)
        let gStr = ((cStr as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bStr = ((cStr as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rStr).scanHexInt(&r)
        NSScanner(string: gStr).scanHexInt(&g)
        NSScanner(string: bStr).scanHexInt(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    class func getLabelHeight(size: CGFloat, width: CGFloat, message: NSString?) -> CGFloat{
        if message == nil {
            return 0
        }
        
        let font = UIFont.systemFontOfSize(size)
        let option = NSStringDrawingOptions.UsesLineFragmentOrigin
        let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
        let size = CGSizeMake(width, CGFloat(MAXFLOAT))
        let stringRect = message!.boundingRectWithSize(size, options: option, attributes: attributes as? [String : AnyObject], context: nil)
        return stringRect.height
    }
    
    class func getLabelWidth(size: CGFloat, height: CGFloat, message: NSString?) -> CGFloat{
        if message == nil {
            return 0
        }
        
        let font = UIFont.systemFontOfSize(size)
        let option = NSStringDrawingOptions.UsesLineFragmentOrigin
        let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
        let size = CGSizeMake(CGFloat(MAXFLOAT), height)
        let stringRect = message!.boundingRectWithSize(size, options: option, attributes: attributes as? [String : AnyObject], context: nil)
        return stringRect.width
    }

    class func cancelButtonDelay(tableView: UITableView) {
        for view in tableView.subviews {
            if view.isKindOfClass(UIScrollView) {
                let scroll = view as! UIScrollView
                scroll.delaysContentTouches = false
            }
        }
    }
    
    class func cancelButtonDelay(collectionView: UICollectionView) {
        for view in collectionView.subviews {
            if view.isKindOfClass(UIScrollView) {
                let scroll = view as! UIScrollView
                scroll.delaysContentTouches = false
            }
        }
    }
    
    class func cancelButtonDelay(cell: UITableViewCell) {
        for view in cell.subviews
        {
            if view.isKindOfClass(UIScrollView)
            {
                let scroll = view as! UIScrollView;
                scroll.delaysContentTouches = false;
            }
        }
    }
    
    class func cancelButtonDelay(cell: UICollectionViewCell) {
        for view in cell.subviews
        {
            if view.isKindOfClass(UIScrollView)
            {
                let scroll = view as! UIScrollView;
                scroll.delaysContentTouches = false;
            }
        }
    }
    
    class func removeNullFromDictionary(dictionary: NSDictionary) -> NSMutableDictionary{
        let mutableDictionary = NSMutableDictionary()
        
        for key in dictionary.allKeys {
            let value = dictionary.objectForKey(key);
            
            if (value != nil && !value!.isKindOfClass(NSNull)) {
                if value!.isKindOfClass(NSString) {
                    mutableDictionary.setValue(dictionary.objectForKey(key) as! NSString, forKey: key as! String);
                }
            }
        }
        
        return mutableDictionary
    }
    
    class func getRootViewController() -> UIViewController{
        var controller: UIViewController
        let systemVersion: NSString = UIDevice.currentDevice().systemVersion
        if systemVersion.floatValue < 6.0 {
            let array = UIApplication.sharedApplication().windows
            let window = array[0]
            
            let uiview = window.subviews[0]
            controller = uiview.nextResponder() as! UIViewController
        } else {
            controller = (UIApplication.sharedApplication().keyWindow?.rootViewController)!
        }
        
        return controller
    }
    
    class func getCachesPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, .UserDomainMask, true)
        var cachePath = paths[0]
        cachePath = cachePath.stringByAppendingFormat("/%@", NSBundle.mainBundle().bundleIdentifier!)
        return cachePath
    }
    
    class func cachefileSize() -> String {
        let basePath = getCachesPath()
        let fileManager = NSFileManager.defaultManager()
        var total: Float = 0
        if fileManager.fileExistsAtPath(basePath){
            let childrenPath = fileManager.subpathsAtPath(basePath)
            if childrenPath != nil{
                for path in childrenPath!{
                    let childPath = basePath.stringByAppendingString("/").stringByAppendingString(path)
                    do{
                        let attr = try fileManager.attributesOfItemAtPath(childPath)
                        let fileSize = attr["NSFileSize"] as! Float
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
        let basePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(basePath!){
            let childrenPath = fileManager.subpathsAtPath(basePath!)
            for childPath in childrenPath!{
                let cachePath = basePath?.stringByAppendingString("/").stringByAppendingString(childPath)
                do{
                    try fileManager.removeItemAtPath(cachePath!)
                }catch _{
                    result = false
                }
            }
        }
        
        return result
    }
    
    class func getIntegerFromAnyObject(object: AnyObject?) -> Int {
        return object is NSString ?
            (object as! NSString).integerValue :
            (object as! NSNumber).integerValue
    }
}