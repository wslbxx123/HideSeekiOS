//
//  PurchaseCollectionViewCell.swift
//  HideSeek
//
//  Created by apple on 7/20/16.
//  Copyright © 2016 mj. All rights reserved.
//
import UIKit

class PurchaseCollectionViewCell: UICollectionViewCell {
    var rect: CGRect!
    var nameLabel: UILabel!
    var imageView: UIImageView!
    var priceImageView: UIImageView!
    var recordLabel: UILabel!
    var purchaseCountImageView: UIImageView!
    var purchaseCountLabel: UILabel!
    var introductionLabel: UILabel!
    var purchaseBtn: UIButton!
    var purchaseDelegate: PurchaseDelegate!
    var product: Product!
    var orderId: Int64 = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        rect = UIScreen.mainScreen().bounds
        self.nameLabel = UILabel()
        self.imageView = UIImageView()
        self.priceImageView = UIImageView()
        self.recordLabel = UILabel()
        self.purchaseCountImageView = UIImageView()
        self.purchaseCountLabel = UILabel()
        self.introductionLabel = UILabel()
        self.purchaseBtn = UIButton()
        
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(priceImageView)
        self.contentView.addSubview(recordLabel)
        self.contentView.addSubview(purchaseCountImageView)
        self.contentView.addSubview(purchaseCountLabel)
        self.contentView.addSubview(introductionLabel)
        self.contentView.addSubview(purchaseBtn)
        
        self.purchaseBtn.addTarget(self, action: #selector(PurchaseCollectionViewCell.purchase), forControlEvents: UIControlEvents.TouchDown)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setName(name: String) {
        self.nameLabel.text = name
        self.nameLabel.numberOfLines = 0
        self.nameLabel.font = UIFont.systemFontOfSize(15)
        self.nameLabel.frame = CGRect(x: 10, y: 10, width: rect.width / 2 - 40, height: 0)
        self.nameLabel.modifyHeight()
    }
    
    func setImageUrl(imageUrl: String?) {
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.imageView.frame = CGRect(x: 10, y: 10 + self.nameLabel.frame.maxY, width: rect.width / 2 - 40, height: rect.width / 2 - 40)
        self.imageView.setWebImage(imageUrl, defaultImage: "default_photo", isCache: true)
    }
    
    func setPrice(price: Double) {
        self.priceImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.priceImageView.image = UIImage(named: "price")
        self.priceImageView.frame = CGRect(x: 10, y: self.imageView.frame.maxY, width: 18, height: 20)
        self.recordLabel.text = "\(price)"
        self.recordLabel.font = UIFont.systemFontOfSize(10)
        self.recordLabel.textColor = UIColor.redColor()
        self.recordLabel.frame = CGRect(x: 5 + self.priceImageView.frame.maxX,
                                        y: 3 + self.imageView.frame.maxY,
                                        width: 0,
                                        height: 20)
        self.recordLabel.modifyWidth()
    }
    
    func setPurchaseCount(purchaseCount: Int) {
        self.purchaseCountImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.purchaseCountImageView.image = UIImage(named: "purchase_count")
        self.purchaseCountImageView.frame = CGRect(x: self.recordLabel.frame.maxX + 20,
                                                   y: self.imageView.frame.maxY,
                                                   width: 16,
                                                   height: 20)
        self.purchaseCountLabel.text = NSString(
            format: NSLocalizedString("PURCHASE_COUNT", comment: "%d people purchased"),
            purchaseCount) as String
        self.purchaseCountLabel.font = UIFont.systemFontOfSize(10)
        self.purchaseCountLabel.textColor = UIColor.redColor()
        self.purchaseCountLabel.frame = CGRect(x: 5 + self.purchaseCountImageView.frame.maxX,
                                               y: 3 + self.imageView.frame.maxY,
                                               width: 0,
                                               height: 20)
        self.purchaseCountLabel.modifyWidth()
    }
    
    func setIntroduction(introduction: String?) {
        self.introductionLabel.text = introduction
        self.introductionLabel.numberOfLines = 0
        self.introductionLabel.font = UIFont.systemFontOfSize(12)
        
        let introHeight = BaseInfoUtil.getLabelHeight(12, width: rect.width / 2 - 40, message: introduction)
        
        if introHeight > 50 {
            self.introductionLabel.frame = CGRect(x: 10,
                                                  y: 5 + self.purchaseCountImageView.frame.maxY,
                                                  width: rect.width / 2 - 40,
                                                  height: 50)
        } else {
            self.introductionLabel.frame = CGRect(x: 10,
                                                  y: 5 + self.purchaseCountImageView.frame.maxY,
                                                  width: rect.width / 2 - 40,
                                                  height: 0)
            self.introductionLabel.modifyHeight()
        }
    }
    
    func setPurchaseBtn() {
        self.purchaseBtn.setTitle(NSLocalizedString("PURCHASE", comment: "Purchase"), forState: UIControlState.Normal)
        self.purchaseBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.purchaseBtn.titleLabel?.font = UIFont.systemFontOfSize(15)
        self.purchaseBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        self.purchaseBtn.frame = CGRect(x: 0,
                                        y: 50 + self.introductionLabel.frame.maxY - self.introductionLabel.frame.height,
                                        width: rect.width / 2 - 20,
                                        height: 25)
    }
    
    func purchase() {
        purchaseDelegate?.purchase(product, orderId: orderId)
    }
    
    var height : CGFloat {
        get{
            return self.introductionLabel.frame.maxY + 10
        }
    }
}
