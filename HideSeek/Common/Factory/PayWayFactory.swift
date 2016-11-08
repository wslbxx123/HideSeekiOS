//
//  PayWayFactory.swift
//  HideSeek
//
//  Created by apple on 05/11/2016.
//  Copyright © 2016 mj. All rights reserved.
//

class PayWayFactory {
    class func get(payWay: PayWayEnum) -> PayManager {
        switch payWay {
        case PayWayEnum.applePay:
            return InAppPurchaseManager.instance
        case PayWayEnum.alipay:
            return AlipayManager.instance
        }
    }
    
    enum PayWayEnum : Int {
        case applePay = 0
        case alipay = 1
    }
}
