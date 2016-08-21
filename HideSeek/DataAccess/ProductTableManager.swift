//
//  ProductTableManager.swift
//  HideSeek
//
//  Created by apple on 7/21/16.
//  Copyright © 2016 mj. All rights reserved.
//

import SQLite

class ProductTableManager {
    static let instance = ProductTableManager()
    
    let productId = Expression<Int64>("product_id")
    let name = Expression<String>("name")
    let imageUrl = Expression<String?>("image_url")
    let price = Expression<Double>("price")
    let purchaseCount = Expression<Int>("purchase_count")
    let introduction = Expression<String?>("introduction")
    let pullVersion = Expression<Int64>("version")
    
    var database: Connection!
    var productTable: Table!
    private var _productMinId: Int64 = 0
    
    var productMinId: Int64 {
        let tempProductMinId = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.PRODUCT_MIN_ID) as? NSNumber
        
        if(tempProductMinId == nil) {
            return 0
        }
        return (tempProductMinId?.longLongValue)!
    }
    
    var version: Int64 {
        get{
            let tempVersion = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.PRODUCT_VERSION) as? NSNumber
            
            if(tempVersion == nil) {
                return 0
            }
            return (tempVersion?.longLongValue)!
        }
    }
    
    private init() {
        do {
            database = DatabaseManager.instance.database
            
            productTable = Table("product")
            
            try database.run(productTable.create(ifNotExists: true) { t in
                t.column(productId, primaryKey: true)
                t.column(name)
                t.column(imageUrl)
                t.column(price)
                t.column(purchaseCount)
                t.column(introduction)
                t.column(pullVersion)
                })
        } catch let error as NSError {
            print("SQLiteDB - failed to create table product!")
            print("Error - \(error.localizedDescription)")
            return
        }

    }
    
    func searchProducts() -> NSMutableArray {
        let productList = NSMutableArray()
        
        do {
            var result: Table
            if _productMinId == 0 {
                result = productTable.order(productId.desc).limit(10)
            } else {
                result = productTable.filter(productId >= _productMinId).order(productId.desc)
            }
            
            for item in try database.prepare(result) {
                productList.addObject(Product(
                    pkId: item[productId],
                    name: item[name],
                    imageUrl: item[imageUrl],
                    price: item[price],
                    purchaseCount: item[purchaseCount],
                    introduction: item[introduction],
                    version: item[pullVersion]))
                
                if _productMinId == 0 || _productMinId > item[productId] {
                    self._productMinId = item[productId]
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table race_group!")
            print("Error - \(error.localizedDescription)")
        }
        
        return productList
    }
    
    func updateProducts(productMinId: Int64, version: Int64, productList: NSArray) {
        do {
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(longLong:version), forKey: UserDefaultParam.PRODUCT_VERSION)
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(longLong:productMinId), forKey: UserDefaultParam.PRODUCT_MIN_ID)
            
            for productItem in productList {
                let productInfo = productItem as! Product
                
                let count = try database.run(productTable.filter(productId == productInfo.pkId)
                    .update(
                        name <- productInfo.name,
                        imageUrl <- productInfo.imageUrl,
                        price <- productInfo.price,
                        purchaseCount <- productInfo.purchaseCount,
                        introduction <- productInfo.introduction,
                        pullVersion <- productInfo.version))
                
                if count == 0 {
                    let insert = productTable.insert(
                        name <- productInfo.name,
                        imageUrl <- productInfo.imageUrl,
                        price <- productInfo.price,
                        purchaseCount <- productInfo.purchaseCount,
                        introduction <- productInfo.introduction,
                        pullVersion <- productInfo.version,
                        productId <- productInfo.pkId)
                    
                    try database.run(insert)
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table race_group!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func getMoreProducts(count: Int, version: Int64, hasLoaded: Bool) -> NSMutableArray {
        let productList = NSMutableArray()
        do {
            let result = productTable.filter(pullVersion <= version && productId < _productMinId).order(productId.desc).limit(count)
            
            let resultCount = database.scalar(result.count)
            
            if resultCount == count || hasLoaded {
                for item in try database.prepare(result) {
                    productList.addObject(Product(pkId: item[productId],
                        name: item[name],
                        imageUrl: item[imageUrl],
                        price: item[price],
                        purchaseCount: item[purchaseCount],
                        introduction: item[introduction],
                        version: item[pullVersion]))
                    
                    if _productMinId == 0 || _productMinId > item[productId] {
                        _productMinId = item[productId]
                    }
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table record!")
            print("Error - \(error.localizedDescription)")
        }
        
        return productList
    }

    func clear() {
        do {
            let sqlStr = "delete from product; " +
            "update sqlite_sequence SET seq = 0 where name ='product'"
            try database.execute(sqlStr)
        }
        catch let error as NSError {
            print("SQLiteDB - failed to truncate table product!")
            print("Error - \(error.localizedDescription)")
        }
    }
}
