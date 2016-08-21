//
//  ExchangeOrderTableViewCell.swift
//  HideSeek
//
//  Created by apple on 8/11/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class ExchangeOrderTableViewCell: UITableViewCell {
    let TAG_REWARD_IMAGEVIEW = 1;
    let TAG_NAME_LABEL = 2;
    let TAG_AMOUNT_LABEL = 3;
    let TAG_EXCHANGE_BUTTON = 4;
    let TAG_SUCCESS_LABEL = 5;
    let TAG_PROCESS_VIEW = 6;
    
    var rewardImageView: UIImageView!
    var nameLabel: UILabel!
    var amountLabel: UILabel!
    var exchangeBtn: UIButton!
    var exchangeDelegate: ExchangeDelegate!
    var reward: Reward!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.rewardImageView = self.viewWithTag(TAG_REWARD_IMAGEVIEW) as! UIImageView
        self.nameLabel = self.viewWithTag(TAG_NAME_LABEL) as! UILabel
        self.amountLabel = self.viewWithTag(TAG_AMOUNT_LABEL) as! UILabel
        self.exchangeBtn = self.viewWithTag(TAG_EXCHANGE_BUTTON) as! UIButton
        self.exchangeBtn.addTarget(self, action: #selector(ExchangeOrderTableViewCell.exchangeBtnClicked), forControlEvents: UIControlEvents.TouchDown)
    }
    
    func exchangeBtnClicked() {
        exchangeDelegate?.exchange(reward)
    }
    
    func initOrder(order: ExchangeOrder) {
        rewardImageView.setWebImage(order.imageUrl, defaultImage: "default_photo", isCache: true)
        nameLabel.text = order.rewardName
        amountLabel.text = NSString(format: NSLocalizedString("EXCHANGE_AMOUNT_TITLE", comment: "Amount: %f score"), order.record * Double(order.count)) as String
        exchangeBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        exchangeBtn.layer.cornerRadius = 5
        exchangeBtn.layer.masksToBounds = true
        
        reward = Reward(pkId: order.rewardId, name: order.rewardName, imageUrl: order.imageUrl, record: order.record * Double(order.count), exchangeCount: order.count, introduction: order.introduction, version: 1)
    }
}
