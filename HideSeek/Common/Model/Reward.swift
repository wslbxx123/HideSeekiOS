//
//  Reward.swift
//  HideSeek
//
//  Created by apple on 8/2/16.
//  Copyright © 2016 mj. All rights reserved.
//

class Reward {
    var pkId: Int64
    var name: String
    var imageUrl: String?
    var record: Double = 0
    var exchangeCount: Int
    var introduction: String?
    var version: Int64 = 0
    
    init(pkId: Int64, name: String, imageUrl: String?, record: Double, exchangeCount: Int,
         introduction: String?, version: Int64) {
        self.pkId = pkId
        self.name = name
        self.imageUrl = imageUrl
        self.record = record
        self.exchangeCount = exchangeCount
        self.introduction = introduction
        self.version = version
    }
}
