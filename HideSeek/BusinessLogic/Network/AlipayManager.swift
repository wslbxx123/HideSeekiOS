//
//  AlipayManager.swift
//  HideSeek
//
//  Created by apple on 8/3/16.
//  Copyright © 2016 mj. All rights reserved.
//

class AlipayManager {
    let PARTNER = "2088421519055042";
    let SELLER = "wslbxx@hotmail.com";
    
    static let instance = AlipayManager()
    
    func purchase(sign: NSString, tradeNo: NSString, product: Product, count: Int) {
        let order = AlipayOrder(service: "mobile.securitypay.pay",
                                partner: PARTNER,
                                inputCharset: "utf-8",
                                notifyURL: "http://www.hideseek.cn/index.php/home/store/notifyUrl",
                                outTradeNo: tradeNo,
                                subject: product.name,
                                paymentType: "1",
                                sellerID: SELLER,
                                totalFee: NSString(format: "%.2f", product.price * Double(count)),
                                body: product.introduction!,
                                itBPay: "30m",
                                showUrl: "m.alipay.com",
                                sign: sign,
                                signType: "RSA")
        let orderString = order.description
        
        AlipaySDK.defaultService().payOrder(orderString, fromScheme: "HideSeekAlipay") { (resultDic) in
            NSLog("result = %@",resultDic.description);
        }
    }
    
    func getAlipayResult(orderState: NSInteger) -> NSString{
        var returnStr: NSString = ""
        switch(orderState) {
        case 9000:
            returnStr = NSLocalizedString("TRANSACTION_COMPLETE", comment: "Transaction Completed")
            break;
        case 8000:
            returnStr = NSLocalizedString("ORDER_PROCESSING", comment: "The order is being processed")
            break;
        case 4000:
            returnStr = NSLocalizedString("FALIED_PAY_ORDER", comment: "Failed to pay the order")
            break;
        case 6001:
            returnStr = NSLocalizedString("ORDER_CANCLED", comment: "The order is canceled")
            break;
        case 6002:
            returnStr = NSLocalizedString("FAILED_CONNECT_NETWORK", comment: "Failed to connect the network")
            break;
        default:
            break;
        }
        return returnStr
    }
}
