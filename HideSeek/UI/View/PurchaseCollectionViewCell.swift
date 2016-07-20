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
        
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(priceImageView)
        self.contentView.addSubview(recordLabel)
        self.contentView.addSubview(purchaseCountImageView)
        self.contentView.addSubview(purchaseCountLabel)
        self.contentView.addSubview(introductionLabel)
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
    
    func setPrice(price: Int) {
        self.priceImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.priceImageView.image = UIImage(named: "price")
        self.priceImageView.frame = CGRect(x: 10, y: 10 + self.imageView.frame.maxY, width: 20, height: 20)
        self.recordLabel.text = "\(price)"
        self.recordLabel.font = UIFont.systemFontOfSize(10)
        self.recordLabel.frame = CGRect(x: 5 + self.priceImageView.frame.maxX,
                                        y: 10 + self.imageView.frame.maxY,
                                        width: 0,
                                        height: 20)
        self.recordLabel.modifyWidth()
    }
    
    func setPurchaseCount(purchaseCount: Int) {
        self.purchaseCountImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.purchaseCountImageView.image = UIImage(named: "purchase_count")
        self.purchaseCountImageView.frame = CGRect(x: self.recordLabel.frame.maxX + 20,
                                                   y: 10 + self.imageView.frame.maxY,
                                                   width: 18,
                                                   height: 20)
        self.purchaseCountLabel.text = "\(purchaseCount)"
        self.purchaseCountLabel.font = UIFont.systemFontOfSize(10)
        self.purchaseCountLabel.frame = CGRect(x: 5 + self.purchaseCountImageView.frame.maxX,
                                               y: 10 + self.imageView.frame.maxY,
                                               width: 0,
                                               height: 20)
        self.purchaseCountLabel.modifyWidth()
    }
    
    func setIntroduction(introduction: String?) {
        self.introductionLabel.text = introduction
        self.introductionLabel.numberOfLines = 0
        self.introductionLabel.font = UIFont.systemFontOfSize(12)
        self.introductionLabel.frame = CGRect(x: 10,
                                              y: 10 + self.purchaseCountImageView.frame.maxY,
                                              width: rect.width / 2 - 40,
                                              height: 0)
        self.introductionLabel.modifyHeight()
    }
    
    var height : CGFloat {
        get{
            return self.introductionLabel.frame.maxY + 10
        }
    }
}
