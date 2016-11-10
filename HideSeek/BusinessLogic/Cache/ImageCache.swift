//
//  ImageCache.swift
//  HideSeek
//
//  Created by apple on 6/22/16.
//  Copyright © 2016 mj. All rights reserved.
//

class ImageCache: NSObject {
    class func readCacheFromUrl(_ url: String)->Data? {
        var data: Data?
        do {
            let path: String = try getFullCachePathFromUrl(url)
            if FileManager.default.fileExists(atPath: path) {
                data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.alwaysMapped)
            }
        } catch let error as NSError{
            NSLog("\(error.localizedDescription)")
            data = nil
        }
        
        return data
    }
    
    class func writeCacheToUrl(_ url: String, data: Data){
        do {
            let path: String = try getFullCachePathFromUrl(url)
            print((try? data.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil)
        } catch let error as NSError{
            NSLog("\(error.localizedDescription)")
        }
        
    }
    
    class func getFullCachePathFromUrl(_ url: String) throws -> String {
        var cachePaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory,FileManager.SearchPathDomainMask.allDomainsMask, true)
        var cachePath = cachePaths[0] as String
        cachePath = cachePath.appendingFormat("/%@", Bundle.main.bundleIdentifier! + "/image")
        let fileManager: FileManager = FileManager.default
        
        if !(fileManager.fileExists(atPath: cachePath)) {
            try fileManager.createDirectory(atPath: cachePath, withIntermediateDirectories: true, attributes: nil)
        }
        
        var newURL:NSString
        newURL = getFileNameFromUrl(url) as NSString
        cachePath = cachePath.appendingFormat("/%@", newURL)
        return cachePath
    }
    
    class func getFileNameFromUrl(_ url: String) -> String{
        let splitedArray = url.components(separatedBy: "/")
        let fileName = splitedArray[splitedArray.count - 1]
        return fileName
        
    }
}
