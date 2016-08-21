//
//  MyOrderTableManager.swift
//  HideSeek
//
//  Created by apple on 8/6/16.
//  Copyright © 2016 mj. All rights reserved.
//
import SQLite

class PurchaseOrderTableManager {
    static let instance = PurchaseOrderTableManager()
    
    let orderId = Expression<Int64>("order_id")
    let status = Expression<Int>("status")
    let createTime = Expression<String>("create_time")
    let updateTime = Expression<String>("update_time")
    let orderCount = Expression<Int>("count")
    let tradeNo = Expression<String>("trade_no")
    let productId = Expression<Int64>("product_id")
    let productName = Expression<String>("product_name")
    let imageUrl = Expression<String>("image_url")
    let price = Expression<Double>("price")
    let purchaseCount = Expression<Int>("purchase_count")
    let introduction = Expression<String>("introduction")
    let pullVersion = Expression<Int64>("version")
    
    var database: Connection!
    var purchaseOrderTable: Table!
    private var _orderMinId: Int64 = 0
    
    var orderMinId: Int64 {
        let tempOrderMinId = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.PURCHASE_ORDER_MIN_ID) as? NSNumber
        
        if(tempOrderMinId == nil) {
            return 0
        }
        return (tempOrderMinId?.longLongValue)!
    }
    
    var version: Int64 {
        get{
            let tempVersion = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.PURCHASE_ORDER_VERSION) as? NSNumber
            
            if(tempVersion == nil) {
                return 0
            }
            return (tempVersion?.longLongValue)!
        }
    }
    
    private init() {
        do {
            database = DatabaseManager.instance.database
            
            purchaseOrderTable = Table("purchase_order")
            
            try database.run(purchaseOrderTable.create(ifNotExists: true) { t in
                t.column(orderId, primaryKey: true)
                t.column(status)
                t.column(createTime)
                t.column(updateTime)
                t.column(orderCount)
                t.column(tradeNo)
                t.column(productId)
                t.column(productName)
                t.column(imageUrl)
                t.column(price)
                t.column(purchaseCount)
                t.column(introduction)
                t.column(pullVersion)
                })
        } catch let error as NSError {
            print("SQLiteDB - failed to create table purchase_order!")
            print("Error - \(error.localizedDescription)")
            return
        }
        
    }
    
    func searchOrders() -> NSMutableArray {
        let orderList = NSMutableArray()
        
        do {
            var result: Table
            if _orderMinId == 0 {
                result = purchaseOrderTable.order(orderId.desc).limit(10)
            } else {
                result = purchaseOrderTable.filter(orderId >= _orderMinId).order(orderId.desc)
            }
            
            for item in try database.prepare(result) {
                orderList.addObject(PurchaseOrder(
                    orderId: item[orderId],
                    status: item[status],
                    createTime: item[createTime],
                    updateTime: item[updateTime],
                    count: item[orderCount],
                    tradeNo: item[tradeNo],
                    productId: item[productId],
                    productName: item[productName],
                    imageUrl: item[imageUrl],
                    price: item[price],
                    purchaseCount: item[purchaseCount],
                    introduction: item[introduction],
                    version: item[pullVersion]))
                
                if _orderMinId == 0 || _orderMinId > item[orderId] {
                    self._orderMinId = item[orderId]
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table purchase_order!")
            print("Error - \(error.localizedDescription)")
        }
        
        return orderList
    }
    
    func updateOrders(orderMinId: Int64, version: Int64, orderList: NSArray) {
        do {
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(longLong:version), forKey: UserDefaultParam.PURCHASE_ORDER_VERSION)
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(longLong:orderMinId), forKey: UserDefaultParam.PURCHASE_ORDER_MIN_ID)
            
            for orderItem in orderList {
                let orderInfo = orderItem as! PurchaseOrder
                
                let count = try database.run(purchaseOrderTable.filter(orderId == orderInfo.orderId)
                    .update(
                        status <- orderInfo.status,
                        createTime <- orderInfo.createTime,
                        updateTime <- orderInfo.updateTime,
                        orderCount <- orderInfo.count,
                        tradeNo <- orderInfo.tradeNo,
                        productId <- orderInfo.productId,
                        productName <- orderInfo.productName,
                        imageUrl <- orderInfo.imageUrl,
                        price <- orderInfo.price,
                        purchaseCount <- orderInfo.purchaseCount,
                        introduction <- orderInfo.introduction,
                        pullVersion <- orderInfo.version))
                
                if count == 0 {
                    let insert = purchaseOrderTable.insert(
                        status <- orderInfo.status,
                        createTime <- orderInfo.createTime,
                        updateTime <- orderInfo.updateTime,
                        orderCount <- orderInfo.count,
                        tradeNo <- orderInfo.tradeNo,
                        productId <- orderInfo.productId,
                        productName <- orderInfo.productName,
                        imageUrl <- orderInfo.imageUrl,
                        price <- orderInfo.price,
                        purchaseCount <- orderInfo.purchaseCount,
                        introduction <- orderInfo.introduction,
                        pullVersion <- orderInfo.version,
                        orderId <- orderInfo.orderId)
                    
                    try database.run(insert)
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table purchase_order!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func getMoreOrders(count: Int, version: Int64, hasLoaded: Bool) -> NSMutableArray {
        let orderList = NSMutableArray()
        do {
            let result = purchaseOrderTable.filter(pullVersion <= version && orderId < _orderMinId).order(productId.desc).limit(count)
            
            let resultCount = database.scalar(result.count)
            
            if resultCount == count || hasLoaded {
                for item in try database.prepare(result) {
                    orderList.addObject(PurchaseOrder(
                        orderId: item[orderId],
                        status: item[status],
                        createTime: item[createTime],
                        updateTime: item[updateTime],
                        count: item[orderCount],
                        tradeNo: item[tradeNo],
                        productId: item[productId],
                        productName: item[productName],
                        imageUrl: item[imageUrl],
                        price: item[price],
                        purchaseCount: item[purchaseCount],
                        introduction: item[introduction],
                        version: item[pullVersion]))
                    
                    if _orderMinId == 0 || _orderMinId > item[orderId] {
                        _orderMinId = item[orderId]
                    }
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table purchase_order!")
            print("Error - \(error.localizedDescription)")
        }
        
        return orderList
    }
    
    func clear() {
        do {
            let sqlStr = "delete from purchase_order; " +
            "update sqlite_sequence SET seq = 0 where name ='purchase_order'"
            try database.execute(sqlStr)
        }
        catch let error as NSError {
            print("SQLiteDB - failed to truncate table purchase_order!")
            print("Error - \(error.localizedDescription)")
        }
    }
}
