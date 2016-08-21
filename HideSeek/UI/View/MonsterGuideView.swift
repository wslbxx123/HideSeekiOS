//
//  MonsterGuideView.swift
//  HideSeek
//
//  Created by apple on 8/18/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class MonsterGuideView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var goalImageView: UIImageView!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var scoreView: UIView!
    var rateView: RateView!

    func initView() {
        let rateViewContents = NSBundle.mainBundle().loadNibNamed("RateView",
                                                                   owner: self, options: nil)
        rateView = rateViewContents[0] as! RateView
        
        rateView.translatesAutoresizingMaskIntoConstraints = false
        self.scoreView.addSubview(rateView)
        
        let widthConstraint = NSLayoutConstraint(item: rateView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: scoreView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: rateView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: scoreView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: rateView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: scoreView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: rateView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: scoreView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        scoreView.addConstraints([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])
    }
}
