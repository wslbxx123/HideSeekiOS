//
//  Product.swift
//  HideSeek
//
//  Created by apple on 7/20/16.
//  Copyright © 2016 mj. All rights reserved.
//

class Product: NSObject {
    var pkId: Int64
    var name: String
    var imageUrl: String?
    var price: Double = 0
    var purchaseCount: Int
    var introduction: String?
    var version: Int64 = 0
    
    init(pkId: Int64, name: String, imageUrl: String?, price: Double, purchaseCount: Int,
        introduction: String?, version: Int64) {
        self.pkId = pkId
        self.name = name
        self.imageUrl = imageUrl
        self.price = price
        self.purchaseCount = purchaseCount
        self.introduction = introduction
        self.version = version
    }
}
