//
//  CustomImageView.swift
//  HideSeek
//
//  Created by apple on 6/22/16.
//  Copyright © 2016 mj. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func setWebImage(url: String?, defaultImage: String?, isCache: Bool){
        var image: UIImage?
        if url == nil {
            return
        }
        
        if defaultImage != nil {
            self.image = UIImage(named: defaultImage!)
        }
        
        if isCache {
            let data: NSData? = ImageCache.readCacheFromUrl(url!)
            if data != nil {
                image = UIImage(data: data!)
                self.image = image
            } else {
                refreshImage(url)
            }
        } else {
            refreshImage(url)
        }
    }
    
    func setWebImage(url: String?, smallPhotoUrl: String?, defaultImage: String?, isCache: Bool){
        var image: UIImage?
        if url == nil {
            return
        }
        
        if defaultImage != nil {
            self.image = UIImage(named: defaultImage!)
        }
        
        if isCache {
            let data: NSData? = ImageCache.readCacheFromUrl(smallPhotoUrl!)
            if data != nil {
                image = UIImage(data: data!)
                self.image = image
            } else {
                refreshImage(smallPhotoUrl)
            }
        } else {
            refreshImage(smallPhotoUrl)
        }
        
        if isCache {
            let data: NSData? = ImageCache.readCacheFromUrl(url!)
            if data != nil {
                image = UIImage(data: data!)
                self.image = image
            } else {
                refreshImage(url)
            }
        } else {
            refreshImage(url)
        }
    }
    
    func refreshImage(url: String?) {
        var image: UIImage?
        let dispath = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        dispatch_async(dispath, { () -> Void in
            let URL: NSURL = NSURL(string: url!)!
            let data: NSData? = NSData(contentsOfURL: URL)
            if data != nil {
                image = UIImage(data: data!)
                ImageCache.writeCacheToUrl(url!, data: data!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.image = image
                })
            }
            
        })
    }
}
