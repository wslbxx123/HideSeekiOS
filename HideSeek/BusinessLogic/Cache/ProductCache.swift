//
//  ProductCache.swift
//  HideSeek
//
//  Created by apple on 7/20/16.
//  Copyright © 2016 mj. All rights reserved.
//

class ProductCache : BaseCache<Product> {
    static let instance = ProductCache()
    
    func setProducts(result: NSDictionary!) {
        saveProducts(result)
    }
    
    func saveProducts(result: NSDictionary!) {
        var list = NSMutableArray()
        let productArray = result["products"] as! NSArray
        
        for product in productArray {
            let productInfo = product as! NSDictionary
            list.addObject(Product(pkId: (productInfo["pk_id"] as! NSString).longLongValue,
                name: productInfo["product_name"] as! String,
                imageUrl: productInfo["product_image_url"] as? String,
                price: (productInfo["price"] as! NSString).integerValue,
                purchaseCount: (productInfo["purchase_count"] as! NSString).integerValue,
                introduction: productInfo["introduction"] as? String,
                version: (productInfo["version"] as! NSString).longLongValue))
        }
        
        cacheList = list
    }
}
