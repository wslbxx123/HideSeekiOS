//
//  PurchaseOrder.swift
//  HideSeek
//
//  Created by apple on 8/7/16.
//  Copyright © 2016 mj. All rights reserved.
//

class PurchaseOrder {
    var orderId: Int64
    var status: Int
    var createTime: String
    var updateTime: String
    var count: Int
    var tradeNo: String
    var productId: Int64
    var productName: String
    var imageUrl: String
    var price: Double
    var purchaseCount: Int
    var introduction: String
    var version: Int64
    
    init(orderId: Int64, status: Int, createTime: String, updateTime: String, count: Int,
         tradeNo: String, productId: Int64, productName: String, imageUrl: String,
         price: Double, purchaseCount: Int, introduction: String, version: Int64) {
        self.orderId = orderId
        self.status = status
        self.createTime = createTime
        self.updateTime = updateTime
        self.count = count
        self.tradeNo = tradeNo
        self.productId = productId
        self.productName = productName
        self.imageUrl = imageUrl
        self.price = price
        self.purchaseCount = purchaseCount
        self.introduction = introduction
        self.version = version
    }
}
