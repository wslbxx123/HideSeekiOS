//
//  InAppPurchaseManager.swift
//  HideSeek
//
//  Created by apple on 29/10/2016.
//  Copyright © 2016 mj. All rights reserved.
//

import StoreKit

class InAppPurchaseManager: PayManager, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    let VERIFY_RECEIPT_URL = "https://buy.itunes.apple.com/verifyReceipt"
    let ITMS_SANDBOX_VERIFY_RECEIPT_URL = "https://sandbox.itunes.apple.com/verifyReceipt"
    
    static let instance = InAppPurchaseManager()
    var productDict: NSMutableDictionary!
    var _product: Product!
    var _orderId: Int64 = 0
    
    func requestProductData(productId: String) {
        let list = NSArray(objects: productId)
        let set = NSSet(array: list as [AnyObject])
        let request = SKProductsRequest(productIdentifiers: set as! Set<String>)
        request.delegate = self;
        request.start()
    }
    
    override func purchase(sign: NSString, tradeNo: NSString, product: Product,
                           count: Int, orderId: Int64) {
        super.purchase(sign, tradeNo: tradeNo, product: product, count: count, orderId: orderId)
        
        self._product = product
        self._orderId = orderId
        let bundleId = NSBundle.mainBundle().bundleIdentifier!.lowercaseString
        let productId = bundleId + "\(product.pkId)"
        
        //先判断是否支持内购
        if(SKPaymentQueue.canMakePayments()){
            requestProductData(productId)
        }
        else{
            print("============不支持内购功能")
        }
    }
    
    func buyProduct(product: SKProduct){
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        if (productDict == nil) {
            productDict = NSMutableDictionary(capacity: response.products.count)
        }
        
        for invalidProduct in response.invalidProductIdentifiers {
            print(invalidProduct)
        }
        
        for product in response.products {
            // 激活了对应的销售操作按钮，相当于商店的商品上架允许销售
            print("=======Product id=======\(product.productIdentifier)")
            print("===产品标题 ==========\(product.localizedTitle)")
            print("====产品描述信息==========\(product.localizedDescription)")
            print("=====价格: =========\(product.price)")
            
            buyProduct(product)
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // 调试
        for transaction in transactions {
            // 如果小票状态是购买完成
            if (SKPaymentTransactionState.Purchased == transaction.transactionState) {
                // 更新界面或者数据，把用户购买得商品交给用户
                print("支付成了＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
                
                purchaseDelegate.purchase()
                
                // 验证购买凭据
                self.verifyPurchase()
                
                // 将交易从交易队列中删除
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            }
            else if(SKPaymentTransactionState.Failed == transaction.transactionState){
                print("支付失败＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            }
            else if (SKPaymentTransactionState.Restored == transaction.transactionState) {//恢复购买
                // 更新界面或者数据，把用户购买得商品交给用户
                // ...
                
                // 将交易从交易队列中删除
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            }
            
        }
    }
    
    func verifyPurchase() {
        do {
            // 验证凭据，获取到苹果返回的交易凭据
            // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
            let receiptURL = NSBundle.mainBundle().appStoreReceiptURL
            // 从沙盒中获取到购买凭据
            let receiptData = NSData(contentsOfURL: receiptURL!)
            // 发送网络POST请求，对购买凭据进行验证
            let url = NSURL(string: ITMS_SANDBOX_VERIFY_RECEIPT_URL)
            // 国内访问苹果服务器比较慢，timeoutInterval需要长一点
            let request = NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10.0)
            request.HTTPMethod = "POST"
            // 在网络中传输数据，大多情况下是传输的字符串而不是二进制数据
            // 传输的是BASE64编码的字符串
            /**
             BASE64 常用的编码方案，通常用于数据传输，以及加密算法的基础算法，传输过程中能够保证数据传输的稳定性
             BASE64是可以编码和解码的
             */
            let encodeStr = receiptData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
            
            let payload = NSString(string: "{\"receipt-data\" : \"" + encodeStr! + "\"}")
            print(payload)
            let payloadData = payload.dataUsingEncoding(NSUTF8StringEncoding)
            
            request.HTTPBody = payloadData;
            
            // 提交验证请求，并获得官方的验证JSON结果
            
            let result = try NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
            
            let dict: AnyObject? = try NSJSONSerialization.JSONObjectWithData(result, options: NSJSONReadingOptions.AllowFragments)
            if (dict != nil) {
                // 比对字典中以下信息基本上可以保证数据安全
                // bundle_id&application_version&product_id&transaction_id
                // 验证成功
                print(dict)
            }
        } catch let error as NSError {
            print("Error - \(error.localizedDescription)")
            return
        } catch let error {
            print("Error - \(error)")
            return
        }
    }
}
