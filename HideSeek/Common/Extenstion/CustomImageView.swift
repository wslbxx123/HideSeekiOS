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
    func setWebImage(_ url: String?, defaultImage: String?, isCache: Bool){
        var image: UIImage?
        if url == nil {
            return
        }
        
        if defaultImage != nil {
            self.image = UIImage(named: defaultImage!)
        }
        
        if isCache {
            let data: Data? = ImageCache.readCacheFromUrl(url!)
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
    
    func setWebImage(_ url: String?, smallPhotoUrl: String?, defaultImage: String?, isCache: Bool){
        var image: UIImage?
        if url == nil {
            return
        }
        
        if defaultImage != nil {
            self.image = UIImage(named: defaultImage!)
        }
        
        if isCache {
            let data: Data? = ImageCache.readCacheFromUrl(smallPhotoUrl!)
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
            let data: Data? = ImageCache.readCacheFromUrl(url!)
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
    
    func refreshImage(_ url: String?) {
        var image: UIImage?
        let dispath = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high)
        dispath.async(execute: { () -> Void in
            let URL: Foundation.URL = Foundation.URL(string: url!)!
            let data: Data? = try? Data(contentsOf: URL)
            if data != nil {
                image = UIImage(data: data!)
                ImageCache.writeCacheToUrl(url!, data: data!)
                DispatchQueue.main.async(execute: { () -> Void in
                    self.image = image
                })
            }
            
        })
    }
}
