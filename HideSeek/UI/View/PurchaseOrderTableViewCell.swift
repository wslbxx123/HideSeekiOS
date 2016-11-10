//
//  PurchaseOrderTableViewCell.swift
//  HideSeek
//
//  Created by apple on 8/8/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import OAStackView

class PurchaseOrderTableViewCell: UITableViewCell {
    let TAG_PRODUCT_IMAGEVIEW = 1;
    let TAG_NAME_LABEL = 2;
    let TAG_AMOUNT_LABEL = 3;
    let TAG_PAY_BUTTON = 4;
    let TAG_SUCCESS_LABEL = 5;
    let TAG_PROCESS_VIEW = 6;
    
    var productImageView: UIImageView!
    var nameLabel: UILabel!
    var amountLabel: UILabel!
    var payBtn: UIButton!
    var successLabel: UILabel!
    var processView: OAStackView!
    var purchaseDelegate: PurchaseDelegate!
    var product: Product!
    var orderId: Int64 = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.productImageView = self.viewWithTag(TAG_PRODUCT_IMAGEVIEW) as! UIImageView
        self.nameLabel = self.viewWithTag(TAG_NAME_LABEL) as! UILabel
        self.amountLabel = self.viewWithTag(TAG_AMOUNT_LABEL) as! UILabel
        self.payBtn = self.viewWithTag(TAG_PAY_BUTTON) as! UIButton
        self.successLabel = self.viewWithTag(TAG_SUCCESS_LABEL) as! UILabel
        self.processView = self.viewWithTag(TAG_PROCESS_VIEW) as! OAStackView
        self.payBtn.addTarget(self, action: #selector(PurchaseOrderTableViewCell.payBtnClicked), for: UIControlEvents.touchDown)
    }
    
    func payBtnClicked() {
        purchaseDelegate?.purchase(product, orderId: orderId)
    }
    
    func initOrder(_ order: PurchaseOrder) {
        orderId = order.orderId
        productImageView.setWebImage(order.imageUrl, defaultImage: "default_photo", isCache: true)
        nameLabel.text = order.productName
        amountLabel.text = NSString(format: NSLocalizedString("AMOUNT_TITLE", comment: "Amount: %.2f yuan") as NSString, order.price * Double(order.count)) as String
        payBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        payBtn.layer.cornerRadius = 5
        payBtn.layer.masksToBounds = true
        if(order.status == 0) {
            successLabel.isHidden = true
            processView.isHidden = false
        } else {
            successLabel.isHidden = false
            processView.isHidden = true
        }
        
        product = Product(pkId: order.productId, name: order.productName, imageUrl: order.imageUrl, price: order.price * Double(order.count), purchaseCount: order.count, introduction: order.introduction, version: 1)
    }
}
