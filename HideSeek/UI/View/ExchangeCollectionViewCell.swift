//
//  ExchangeCollectionViewCell.swift
//  HideSeek
//
//  Created by apple on 7/25/16.
//  Copyright © 2016 mj. All rights reserved.
//

class ExchangeCollectionViewCell: UICollectionViewCell {
    var rect: CGRect!
    var nameLabel: UILabel!
    var imageView: UIImageView!
    var recordImageView: UIImageView!
    var recordLabel: UILabel!
    var exchangeCountImageView: UIImageView!
    var exchangeCountLabel: UILabel!
    var introductionLabel: UILabel!
    var exchangeBtn: UIButton!
    var exchangeDelegate: ExchangeDelegate!
    var reward: Reward!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        rect = UIScreen.mainScreen().bounds
        self.nameLabel = UILabel()
        self.imageView = UIImageView()
        self.recordImageView = UIImageView()
        self.recordLabel = UILabel()
        self.exchangeCountImageView = UIImageView()
        self.exchangeCountLabel = UILabel()
        self.introductionLabel = UILabel()
        self.exchangeBtn = UIButton()
        
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(recordImageView)
        self.contentView.addSubview(recordLabel)
        self.contentView.addSubview(exchangeCountImageView)
        self.contentView.addSubview(exchangeCountLabel)
        self.contentView.addSubview(introductionLabel)
        self.contentView.addSubview(exchangeBtn)
        
        self.exchangeBtn.addTarget(self, action: #selector(ExchangeCollectionViewCell.exchange), forControlEvents: UIControlEvents.TouchDown)
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
    
    func setRecord(record: Int) {
        self.recordImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.recordImageView.image = UIImage(named: "record_price")
        self.recordImageView.frame = CGRect(x: 10, y: self.imageView.frame.maxY, width: 18, height: 20)
        self.recordLabel.text = "\(record)"
        self.recordLabel.font = UIFont.systemFontOfSize(10)
        self.recordLabel.textColor = UIColor.redColor()
        self.recordLabel.frame = CGRect(x: 5 + self.recordImageView.frame.maxX,
                                        y: 3 + self.imageView.frame.maxY,
                                        width: 0,
                                        height: 20)
        self.recordLabel.modifyWidth()
    }
    
    func setExchangeCount(purchaseCount: Int) {
        self.exchangeCountImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.exchangeCountImageView.image = UIImage(named: "purchase_count")
        self.exchangeCountImageView.frame = CGRect(x: self.recordLabel.frame.maxX + 20,
                                                   y: self.imageView.frame.maxY,
                                                   width: 16,
                                                   height: 20)
        self.exchangeCountLabel.text = NSString(
            format: NSLocalizedString("EXCHAGNE_COUNT", comment: "%d people purchased"),
            purchaseCount) as String
        self.exchangeCountLabel.font = UIFont.systemFontOfSize(10)
        self.exchangeCountLabel.textColor = UIColor.redColor()
        self.exchangeCountLabel.frame = CGRect(x: 5 + self.exchangeCountImageView.frame.maxX,
                                               y: 3 + self.imageView.frame.maxY,
                                               width: 0,
                                               height: 20)
        self.exchangeCountLabel.modifyWidth()
    }
    
    func setIntroduction(introduction: String?) {
        self.introductionLabel.text = introduction
        self.introductionLabel.numberOfLines = 0
        self.introductionLabel.font = UIFont.systemFontOfSize(12)
        
        let introHeight = BaseInfoUtil.getLabelHeight(12, width: rect.width / 2 - 40, message: introduction)
        
        if introHeight > 50 {
            self.introductionLabel.frame = CGRect(x: 10,
                                                  y: 5 + self.exchangeCountImageView.frame.maxY,
                                                  width: rect.width / 2 - 40,
                                                  height: 50)
        } else {
            self.introductionLabel.frame = CGRect(x: 10,
                                                  y: 5 + self.exchangeCountImageView.frame.maxY,
                                                  width: rect.width / 2 - 40,
                                                  height: 0)
            self.introductionLabel.modifyHeight()
        }
    }
    
    func setExchangeBtn() {
        self.exchangeBtn.setTitle(NSLocalizedString("PURCHASE", comment: "Purchase"), forState: UIControlState.Normal)
        self.exchangeBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.exchangeBtn.titleLabel?.font = UIFont.systemFontOfSize(15)
        self.exchangeBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        self.exchangeBtn.frame = CGRect(x: 0,
                                        y: 50 + self.introductionLabel.frame.maxY - self.introductionLabel.frame.height,
                                        width: rect.width / 2 - 20,
                                        height: 25)
    }
    
    func exchange() {
        exchangeDelegate?.exchange(reward)
    }
    
    var height : CGFloat {
        get{
            return self.introductionLabel.frame.maxY + 10
        }
    }
}

