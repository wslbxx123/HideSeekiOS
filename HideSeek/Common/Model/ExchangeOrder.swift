//
//  ExchangeOrder.swift
//  HideSeek
//
//  Created by apple on 8/11/16.
//  Copyright © 2016 mj. All rights reserved.
//

class ExchangeOrder {
    var orderId: Int64
    var status: Int
    var createTime: String
    var updateTime: String
    var count: Int
    var rewardId: Int64
    var rewardName: String
    var imageUrl: String
    var record: Double
    var exchangeCount: Int
    var introduction: String
    var version: Int64
    
    init(orderId: Int64, status: Int, createTime: String, updateTime: String,
         count: Int, rewardId: Int64, rewardName: String, imageUrl: String,
         record: Double, exchangeCount: Int, introduction: String, version: Int64) {
        self.orderId = orderId
        self.status = status
        self.createTime = createTime
        self.updateTime = updateTime
        self.count = count
        self.rewardId = rewardId
        self.rewardName = rewardName
        self.imageUrl = imageUrl
        self.record = record
        self.exchangeCount = exchangeCount
        self.introduction = introduction
        self.version = version
    }
}

