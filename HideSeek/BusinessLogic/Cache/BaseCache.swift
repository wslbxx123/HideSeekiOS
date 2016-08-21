//
//  BaseCache.swift
//  HideSeek
//
//  Created by apple on 7/3/16.
//  Copyright © 2016 mj. All rights reserved.
//

class BaseCache<T> {
    var cacheList : NSMutableArray!
    
    init() {
        cacheList = []
    }
    
    func clearList() {
        cacheList.removeAllObjects()
    }
}
