//
//  ExchangeOrderTableManager.swift
//  HideSeek
//
//  Created by apple on 8/11/16.
//  Copyright © 2016 mj. All rights reserved.
//

import SQLite

class ExchangeOrderTableManager {
    static let instance = ExchangeOrderTableManager()
    
    let orderId = Expression<Int64>("order_id")
    let status = Expression<Int>("status")
    let createTime = Expression<String>("create_time")
    let updateTime = Expression<String>("update_time")
    let orderCount = Expression<Int>("count")
    let rewardId = Expression<Int64>("reward_id")
    let rewardName = Expression<String>("reward_name")
    let imageUrl = Expression<String>("image_url")
    let record = Expression<Int>("record")
    let exchangeCount = Expression<Int>("exchange_count")
    let introduction = Expression<String>("introduction")
    let pullVersion = Expression<Int64>("version")
    
    var database: Connection!
    var exchangeOrderTable: Table!
    private var _orderMinId: Int64 = 0
    
    var orderMinId: Int64 {
        let tempOrderMinId = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.EXCHANGE_ORDER_MIN_ID) as? NSNumber
        
        if(tempOrderMinId == nil) {
            return 0
        }
        return (tempOrderMinId?.longLongValue)!
    }
    
    var version: Int64 {
        get{
            let tempVersion = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.EXCHANGE_ORDER_VERSION) as? NSNumber
            
            if(tempVersion == nil) {
                return 0
            }
            return (tempVersion?.longLongValue)!
        }
    }
    
    private init() {
        do {
            database = DatabaseManager.instance.database
            
            exchangeOrderTable = Table("exchange_order")
            
            try database.run(exchangeOrderTable.create(ifNotExists: true) { t in
                t.column(orderId, primaryKey: true)
                t.column(status)
                t.column(createTime)
                t.column(updateTime)
                t.column(orderCount)
                t.column(rewardId)
                t.column(rewardName)
                t.column(imageUrl)
                t.column(record)
                t.column(exchangeCount)
                t.column(introduction)
                t.column(pullVersion)
                })
        } catch let error as NSError {
            print("SQLiteDB - failed to create table exchange_order!")
            print("Error - \(error.localizedDescription)")
            return
        }
        
    }
    
    func searchOrders() -> NSMutableArray {
        let orderList = NSMutableArray()
        
        do {
            var result: Table
            if _orderMinId == 0 {
                result = exchangeOrderTable.order(orderId.desc).limit(10)
            } else {
                result = exchangeOrderTable.filter(orderId >= _orderMinId).order(orderId.desc)
            }
            
            for item in try database.prepare(result) {
                orderList.addObject(ExchangeOrder(
                    orderId: item[orderId],
                    status: item[status],
                    createTime: item[createTime],
                    updateTime: item[updateTime],
                    count: item[orderCount],
                    rewardId: item[rewardId],
                    rewardName: item[rewardName],
                    imageUrl: item[imageUrl],
                    record: item[record],
                    exchangeCount: item[exchangeCount],
                    introduction: item[introduction],
                    version: item[pullVersion]))
                
                if _orderMinId == 0 || _orderMinId > item[orderId] {
                    self._orderMinId = item[orderId]
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table exchange_order!")
            print("Error - \(error.localizedDescription)")
        }
        
        return orderList
    }
    
    func updateOrders(orderMinId: Int64, version: Int64, orderList: NSArray) {
        do {
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(longLong:version), forKey: UserDefaultParam.EXCHANGE_ORDER_VERSION)
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(longLong:orderMinId), forKey: UserDefaultParam.EXCHANGE_ORDER_MIN_ID)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            for orderItem in orderList {
                let orderInfo = orderItem as! ExchangeOrder
                
                let count = try database.run(exchangeOrderTable.filter(orderId == orderInfo.orderId)
                    .update(
                        status <- orderInfo.status,
                        createTime <- orderInfo.createTime,
                        updateTime <- orderInfo.updateTime,
                        orderCount <- orderInfo.count,
                        rewardId <- orderInfo.rewardId,
                        rewardName <- orderInfo.rewardName,
                        imageUrl <- orderInfo.imageUrl,
                        record <- orderInfo.record,
                        exchangeCount <- orderInfo.exchangeCount,
                        introduction <- orderInfo.introduction,
                        pullVersion <- orderInfo.version))
                
                if count == 0 {
                    let insert = exchangeOrderTable.insert(
                        status <- orderInfo.status,
                        createTime <- orderInfo.createTime,
                        updateTime <- orderInfo.updateTime,
                        orderCount <- orderInfo.count,
                        rewardId <- orderInfo.rewardId,
                        rewardName <- orderInfo.rewardName,
                        imageUrl <- orderInfo.imageUrl,
                        record <- orderInfo.record,
                        exchangeCount <- orderInfo.exchangeCount,
                        introduction <- orderInfo.introduction,
                        pullVersion <- orderInfo.version,
                        orderId <- orderInfo.orderId)
                    
                    try database.run(insert)
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table exchange_order!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func getMoreOrders(count: Int, version: Int64, hasLoaded: Bool) -> NSMutableArray {
        let orderList = NSMutableArray()
        do {
            let result = exchangeOrderTable.filter(pullVersion <= version && orderId < _orderMinId).order(rewardId.desc).limit(count)
            
            let resultCount = database.scalar(result.count)
            
            if resultCount == count || hasLoaded {
                for item in try database.prepare(result) {
                    orderList.addObject(ExchangeOrder(
                        orderId: item[orderId],
                        status: item[status],
                        createTime: item[createTime],
                        updateTime: item[updateTime],
                        count: item[orderCount],
                        rewardId: item[rewardId],
                        rewardName: item[rewardName],
                        imageUrl: item[imageUrl],
                        record: item[record],
                        exchangeCount: item[exchangeCount],
                        introduction: item[introduction],
                        version: item[pullVersion]))
                    
                    if _orderMinId == 0 || _orderMinId > item[orderId] {
                        _orderMinId = item[orderId]
                    }
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table exchange_order!")
            print("Error - \(error.localizedDescription)")
        }
        
        return orderList
    }
    
    func clear() {
        do {
            let sqlStr = "delete from exchange_order; " +
            "update sqlite_sequence SET seq = 0 where name ='exchange_order'"
            try database.execute(sqlStr)
            self._orderMinId = 0
        }
        catch let error as NSError {
            print("SQLiteDB - failed to truncate table exchange_order!")
            print("Error - \(error.localizedDescription)")
        }
    }
}

