//
//  ExchangeOrderCache.swift
//  HideSeek
//
//  Created by apple on 8/11/16.
//  Copyright © 2016 mj. All rights reserved.
//

class ExchangeOrderCache : BaseCache<PurchaseOrder> {
    static let instance = ExchangeOrderCache()
    var exchangeOrderTableManager: ExchangeOrderTableManager!
    var version: Int64 = 0
    
    var orderList: NSMutableArray {
        if(super.cacheList.count > 0) {
            return super.cacheList
        }
        
        return exchangeOrderTableManager.searchOrders()
    }
    
    private override init() {
        super.init()
        exchangeOrderTableManager = ExchangeOrderTableManager.instance
    }
    
    func getMoreOrders(count: Int, hasLoaded: Bool) -> Bool {
        let orderList = exchangeOrderTableManager.getMoreOrders(count, version: version, hasLoaded: hasLoaded)
        
        self.cacheList.addObjectsFromArray(orderList as [AnyObject])
        return orderList.count > 0
    }
    
    func setOrders(orderInfo: NSDictionary!) {
        saveOrders(orderInfo)
        
        cacheList = exchangeOrderTableManager.searchOrders()
        version = exchangeOrderTableManager.version
    }
    
    func saveOrders(result: NSDictionary!) {
        let list = NSMutableArray()
        let temp_version = result["version"] as? NSString
        var version: Int64
        if(temp_version == nil) {
            version = exchangeOrderTableManager.version
        } else {
            version = (temp_version?.longLongValue)!
        }
        let orderMinId = (result["order_min_id"] as! NSString).longLongValue
        let orderArray = result["orders"] as! NSArray
        
        for order in orderArray {
            let orderInfo = order as! NSDictionary
            list.addObject(ExchangeOrder(
                orderId: (orderInfo["pk_id"] as! NSString).longLongValue,
                status: (orderInfo["status"] as! NSString).integerValue,
                createTime: orderInfo["create_time"] as! String,
                updateTime: orderInfo["update_time"] as! String,
                count: (orderInfo["count"] as! NSString).integerValue,
                rewardId: (orderInfo["reward_id"] as! NSString).longLongValue,
                rewardName: orderInfo["reward_name"] as! String,
                imageUrl: orderInfo["reward_image_url"] as! String,
                record: (orderInfo["record"] as! NSString).doubleValue,
                exchangeCount: (orderInfo["exchange_count"] as! NSString).integerValue,
                introduction: orderInfo["introduction"] as! String,
                version: (orderInfo["version"] as! NSString).longLongValue))
        }
        
        exchangeOrderTableManager.updateOrders(orderMinId, version: version, orderList: list)
    }
    
    func addOrders(result: NSDictionary!) {
        saveOrders(result)
        
        getMoreOrders(10, hasLoaded: true)
    }
}
