//
//  IPayManager.swift
//  HideSeek
//
//  Created by apple on 05/11/2016.
//  Copyright © 2016 mj. All rights reserved.
//

class PayManager : NSObject {
    var purchaseDelegate: PurchaseDelegate!
    
    func purchase(sign: NSString, tradeNo: NSString, product: Product,
                  count: Int, orderId: Int64) {
        
    }
}
