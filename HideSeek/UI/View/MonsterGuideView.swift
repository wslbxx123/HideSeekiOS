//
//  MonsterGuideView.swift
//  HideSeek
//
//  Created by apple on 8/18/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class MonsterGuideView: UIView {
    @IBOutlet weak var goalImageView: UIImageView!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var winScoreTitle: UILabel!
    
    var rateView: RateView!
    var closeDelegate: CloseDelegate!

    @IBAction func closeBtnClicked(_ sender: AnyObject) {
        closeDelegate?.close()
    }
    
    func initView() {
        let rateViewContents = Bundle.main.loadNibNamed("RateView",
                                                                   owner: self, options: nil)
        rateView = rateViewContents?[0] as! RateView
        
        rateView.translatesAutoresizingMaskIntoConstraints = false
        self.scoreView.addSubview(rateView)
        
        let widthConstraint = NSLayoutConstraint(item: rateView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: scoreView, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: rateView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: scoreView, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: rateView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: scoreView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: rateView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: scoreView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        scoreView.addConstraints([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])
    }
}
