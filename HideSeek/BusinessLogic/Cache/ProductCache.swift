//
//  ProductCache.swift
//  HideSeek
//
//  Created by apple on 7/20/16.
//  Copyright © 2016 mj. All rights reserved.
//

class ProductCache : BaseCache<Product> {
    static let instance = ProductCache()
    var productTableManager: ProductTableManager!
    var version: Int64 = 0
    
    var productList: NSMutableArray {
        get {
            if(super.cacheList.count > 0) {
                return super.cacheList
            }
            
            return productTableManager.searchProducts()
        }
    }
    
    private override init() {
        super.init()
        productTableManager = ProductTableManager.instance
    }
    
    func setProducts(result: NSDictionary!) {
        saveProducts(result)
        
        cacheList = productTableManager.searchProducts()
        version = productTableManager.version
    }
    
    func addProducts(result: NSDictionary!) {
        saveProducts(result)
        
        getMoreProducts(10, hasLoaded: true)
    }
    
    func saveProducts(result: NSDictionary!) {
        let list = NSMutableArray()
        let tempVersion = result["version"] as? NSString
        var version: Int64
        if(tempVersion == nil) {
            version = productTableManager.version
        } else {
            version = (tempVersion?.longLongValue)!
        }
        let productMinId = (result["product_min_id"] as! NSString).longLongValue
        
        let productArray = result["products"] as! NSArray
        
        for product in productArray {
            let productInfo = product as! NSDictionary
            list.addObject(Product(pkId: (productInfo["pk_id"] as! NSString).longLongValue,
                name: productInfo["product_name"] as! String,
                imageUrl: productInfo["product_image_url"] as? String,
                price: (productInfo["price"] as! NSString).doubleValue,
                purchaseCount: (productInfo["purchase_count"] as! NSString).integerValue,
                introduction: productInfo["introduction"] as? String,
                version: (productInfo["version"] as! NSString).longLongValue))
        }
        
        productTableManager.updateProducts(productMinId, version: version, productList: list)
    }
    
    func getMoreProducts(count: Int, hasLoaded: Bool) -> Bool {
        let productList = productTableManager.getMoreProducts(count, version: version, hasLoaded: hasLoaded)
        
        self.cacheList.addObjectsFromArray(productList as [AnyObject])
        
        return productList.count > 0
    }
}
