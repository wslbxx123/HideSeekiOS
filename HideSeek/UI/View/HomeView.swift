//
//  HomeView.swift
//  HideSeek
//
//  Created by apple on 8/12/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class HomeView: UIControl {
    var touchDownDelegate: TouchDownDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addTarget(self, action: #selector(HomeView.touchDown), forControlEvents: UIControlEvents.TouchDown)
        self.addTarget(self, action: #selector(HomeView.touchCancel), forControlEvents: UIControlEvents.TouchCancel)
        self.addTarget(self, action: #selector(HomeView.touchCancel), forControlEvents: UIControlEvents.TouchUpInside)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(HomeView.gestureTouchDown))
        self.addGestureRecognizer(gesture)
    }
    
    func gestureTouchDown() {
        touchDownDelegate?.touchDown(self.tag)
    }
    
    func touchDown() {
        self.backgroundColor = UIColor.whiteColor()
    }
    
    func touchCancel() {
        self.backgroundColor = BaseInfoUtil.stringToRGB("#f1f0f0")
    }
}
