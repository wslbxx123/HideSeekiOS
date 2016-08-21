//
//  AlipayOrder.swift
//  HideSeek
//
//  Created by apple on 8/7/16.
//  Copyright © 2016 mj. All rights reserved.
//

class AlipayOrder: NSObject {
    var service: NSString
    var partner: NSString
    var inputCharset: NSString
    var notifyURL: NSString
    var outTradeNo: NSString
    var subject: NSString
    var paymentType: NSString
    var sellerID: NSString
    var totalFee: NSString
    var body: NSString
    var itBPay: NSString
    var showUrl: NSString
    var sign: NSString
    var signType: NSString
    
    init(service: NSString, partner: NSString, inputCharset: NSString,
         notifyURL: NSString, outTradeNo: NSString, subject: NSString,
         paymentType: NSString, sellerID: NSString, totalFee: NSString,
         body: NSString, itBPay: NSString, showUrl: NSString,
         sign: NSString, signType: NSString) {
        self.service = service
        self.partner = partner
        self.inputCharset = inputCharset
        self.notifyURL = notifyURL
        self.outTradeNo = outTradeNo
        self.subject = subject
        self.paymentType = paymentType
        self.sellerID = sellerID
        self.totalFee = totalFee
        self.body = body
        self.itBPay = itBPay
        self.showUrl = showUrl
        self.sign = sign
        self.signType = signType
    }
    
    override var description: String {
        let result: String = NSString(format: "service=\"%@\"&partner=\"%@\"&_input_charset=\"%@\"&notify_url=\"%@\"&out_trade_no=\"%@\"&subject=\"%@\"&payment_type=\"%@\"&seller_id=\"%@\"&total_fee=\"%@\"&body=\"%@\"&it_b_pay=\"%@\"&show_url=\"%@\"&sign=\"%@\"&sign_type=\"%@\"",
                                      self.service, self.partner, self.inputCharset,
                                      self.notifyURL, self.outTradeNo, self.subject,
                                      self.paymentType, self.sellerID, self.totalFee,
                                      self.body, self.itBPay, self.showUrl,
                                      self.sign, self.signType) as String
        
        return result
    }
}

