//
//  ImageCache.swift
//  HideSeek
//
//  Created by apple on 6/22/16.
//  Copyright © 2016 mj. All rights reserved.
//

class ImageCache: NSObject {
    class func readCacheFromUrl(url: String)->NSData? {
        var data: NSData?
        do {
            let path: String = try getFullCachePathFromUrl(url)
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                data = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedAlways)
            }
        } catch let error as NSError{
            NSLog("\(error.localizedDescription)")
            data = nil
        }
        
        return data
    }
    
    class func writeCacheToUrl(url: String, data: NSData){
        do {
            let path: String = try getFullCachePathFromUrl(url)
            print(data.writeToFile(path, atomically: true))
        } catch let error as NSError{
            NSLog("\(error.localizedDescription)")
        }
        
    }
    
    class func getFullCachePathFromUrl(url: String) throws -> String {
        var cachePaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory,NSSearchPathDomainMask.AllDomainsMask, true)
        var cachePath = cachePaths[0] as String
        cachePath = cachePath.stringByAppendingFormat("/%@", NSBundle.mainBundle().bundleIdentifier! + "/image")
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        
        if !(fileManager.fileExistsAtPath(cachePath)) {
            try fileManager.createDirectoryAtPath(cachePath, withIntermediateDirectories: true, attributes: nil)
        }
        
        var newURL:NSString
        newURL = getFileNameFromUrl(url)
        cachePath = cachePath.stringByAppendingFormat("/%@", newURL)
        return cachePath
    }
    
    class func getFileNameFromUrl(url: String) -> String{
        let splitedArray = url.componentsSeparatedByString("/")
        let fileName = splitedArray[splitedArray.count - 1]
        return fileName
        
    }
}
