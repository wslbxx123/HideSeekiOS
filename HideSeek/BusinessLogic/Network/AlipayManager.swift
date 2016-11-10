//
//  AlipayManager.swift
//  HideSeek
//
//  Created by apple on 8/3/16.
//  Copyright © 2016 mj. All rights reserved.
//

class AlipayManager : PayManager {
    let PARTNER = "2088421519055042";
    let SELLER = "wslbxx@hotmail.com";
    
    static let instance = AlipayManager()
    
    override func purchase(_ sign: NSString, tradeNo: NSString, product: Product,
                           count: Int, orderId: Int64) {
        super.purchase(sign, tradeNo: tradeNo, product: product, count: count, orderId: orderId)
        let order = AlipayOrder(service: "mobile.securitypay.pay",
                                partner: PARTNER as NSString,
                                inputCharset: "utf-8",
                                notifyURL: "http://www.hideseek.cn/index.php/home/store/notifyUrl",
                                outTradeNo: tradeNo,
                                subject: product.name as NSString,
                                paymentType: "1",
                                sellerID: SELLER as NSString,
                                totalFee: NSString(format: "%.2f", product.price * Double(count)),
                                body: product.introduction! as NSString,
                                itBPay: "30m",
                                showUrl: "m.alipay.com",
                                sign: sign,
                                signType: "RSA")
        let orderString = order.description
        
        AlipaySDK.defaultService().payOrder(orderString, fromScheme: "HideSeekAlipay") { (resultDic) in
            NSLog("result = %@",resultDic.debugDescription);
        }
    }
    
    func getAlipayResult(_ orderState: NSInteger) -> NSString{
        var returnStr: NSString = ""
        switch(orderState) {
        case 9000:
            returnStr = NSLocalizedString("SUCCESS_PURCHASE", comment: "Purchase the product successfully") as NSString
            break;
        case 8000:
            returnStr = NSLocalizedString("ORDER_PROCESSING", comment: "The order is being processed") as NSString
            break;
        case 4000:
            returnStr = NSLocalizedString("FALIED_PAY_ORDER", comment: "Failed to pay the order") as NSString
            break;
        case 6001:
            returnStr = NSLocalizedString("ORDER_CANCLED", comment: "The order is canceled") as NSString
            break;
        case 6002:
            returnStr = NSLocalizedString("FAILED_CONNECT_NETWORK", comment: "Failed to connect the network") as NSString
            break;
        default:
            break;
        }
        return returnStr
    }
    
    func checkAlipayResult(_ url: URL) {
        AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (result) in
            NSLog("result = %@", result.debugDescription);
            
            let resultDic = result! as NSDictionary
            let resultStatus = BaseInfoUtil.getIntegerFromAnyObject(resultDic["resultStatus"])
            let message = AlipayManager.instance.getAlipayResult(resultStatus)
            
            let window = UIApplication.shared.keyWindow
            let controller = window!.visibleViewController()
            
            if controller.isKind(of: StoreController.self) {
                let storeController = controller as! StoreController
                if(resultStatus == 9000) {
                    storeController.purchaseController.showMessage(message as String, type: HudToastFactory.MessageType.success)
                    storeController.purchaseController.purchase()
                } else {
                    storeController.purchaseController.showMessage(message as String, type: HudToastFactory.MessageType.error)
                }
            } else if controller.isKind(of: MyOrderController.self){
                let myOrderController = controller as! MyOrderController
                if(resultStatus == 9000) {
                    myOrderController.purchaseOrderController.showMessage(message as String, type: HudToastFactory.MessageType.success)
                    myOrderController.purchaseOrderController.purchase()
                    myOrderController.purchaseOrderController.close()
                } else {
                    myOrderController.purchaseOrderController.showMessage(message as String, type: HudToastFactory.MessageType.error)
                }
            }
        })
    }
}
