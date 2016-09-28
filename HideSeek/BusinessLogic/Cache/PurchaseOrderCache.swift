//
//  OrderCache.swift
//  HideSeek
//
//  Created by apple on 8/6/16.
//  Copyright © 2016 mj. All rights reserved.
//

class PurchaseOrderCache : BaseCache<PurchaseOrder> {
    static let instance = PurchaseOrderCache()
    var purchaseOrderTableManager: PurchaseOrderTableManager!
    var version: Int64 = 0
    
    var orderList: NSMutableArray {
        if(super.cacheList.count == 0) {
            super.cacheList = purchaseOrderTableManager.searchOrders()
        }
        
        return super.cacheList
    }
    
    private override init() {
        super.init()
        purchaseOrderTableManager = PurchaseOrderTableManager.instance
    }
    
    func getMoreOrders(count: Int, hasLoaded: Bool) -> Bool {
        let orderList = purchaseOrderTableManager.getMoreOrders(count, version: version, hasLoaded: hasLoaded)
        
        self.cacheList.addObjectsFromArray(orderList as [AnyObject])
        return orderList.count > 0
    }
    
    func setOrders(orderInfo: NSDictionary!) {
        saveOrders(orderInfo)
        
        cacheList = purchaseOrderTableManager.searchOrders()
        version = purchaseOrderTableManager.version
    }
    
    func saveOrders(result: NSDictionary!) {
        let list = NSMutableArray()
        let temp_version = result["version"] as? NSString
        var version: Int64
        if(temp_version == nil) {
            version = purchaseOrderTableManager.version
        } else {
            version = (temp_version?.longLongValue)!
        }
        let orderMinId = (result["order_min_id"] as! NSString).longLongValue
        let orderArray = result["orders"] as! NSArray
        
        for order in orderArray {
            let orderInfo = order as! NSDictionary
            list.addObject(PurchaseOrder(
                orderId: (orderInfo["pk_id"] as! NSString).longLongValue,
                status: BaseInfoUtil.getIntegerFromAnyObject(orderInfo["status"]),
                createTime: orderInfo["create_time"] as! String,
                updateTime: orderInfo["update_time"] as! String,
                count: BaseInfoUtil.getIntegerFromAnyObject(orderInfo["count"]),
                tradeNo: orderInfo["trade_no"] as! String,
                productId: (orderInfo["store_id"] as! NSString).longLongValue,
                productName: orderInfo["product_name"] as! String,
                imageUrl: orderInfo["product_image_url"] as! String,
                price: (orderInfo["price"] as! NSString).doubleValue,
                purchaseCount: BaseInfoUtil.getIntegerFromAnyObject(orderInfo["purchase_count"]),
                introduction: orderInfo["introduction"] as! String,
                version: (orderInfo["version"] as! NSString).longLongValue))
        }
        
        purchaseOrderTableManager.updateOrders(orderMinId, version: version, orderList: list)
    }
    
    func addOrders(result: NSDictionary!) {
        saveOrders(result)
        
        getMoreOrders(10, hasLoaded: true)
    }
}
