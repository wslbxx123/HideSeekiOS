//
//  HotCityCollectionViewCell.swift
//  HideSeek
//
//  Created by apple on 7/30/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class HotCityCollectionViewCell: UICollectionViewCell {
    var rect: CGRect!
    var nameBtn: UIButton!
    var selectRegionDelegate: SelectRegionDelegate!
    var city: DomesticCity!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        rect = UIScreen.main.bounds
        self.nameBtn = UIButton()
        self.contentView.addSubview(nameBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setName(_ name: String) {
        self.nameBtn.setTitle(name, for: UIControlState())
        self.nameBtn.frame = CGRect(x: 0, y: 0, width: (rect.width  - 85) / 3, height: 40)
        self.nameBtn.setBackgroundColor("#ffffff", selectedColorStr: "#f0f0f0", disabledColorStr: "#f0f0f0")
        self.nameBtn.layer.cornerRadius = 5
        self.nameBtn.layer.masksToBounds = true
        self.nameBtn.setTitleColor(UIColor.black, for: UIControlState())
        self.nameBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        
        self.nameBtn.addTarget(self, action: #selector(HotCityCollectionViewCell.selectRegion), for: UIControlEvents.touchDown)
    }
    
    func selectRegion() {
        DomesticCityTableManager.instance.insertRecentCity(city)
        
        selectRegionDelegate.regionSelected(self.nameBtn.currentTitle!)
    }
}

