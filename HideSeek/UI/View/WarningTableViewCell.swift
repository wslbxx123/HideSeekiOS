//
//  WarningTableViewCell.swift
//  HideSeek
//
//  Created by apple on 9/7/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class WarningTableViewCell: UITableViewCell {
    let TAG_GOAL_IMAGEVIEW = 1
    let TAG_MESSAGE_LABEL = 2
    let TAG_GET_BUTTON = 3
    
    var goalImageView: UIImageView!
    var messageLabel: UILabel!
    var getBtn: UIButton!
    var updateGoalDelegate: UpdateGoalDelegate!
    var warning: Warning!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        goalImageView = self.viewWithTag(TAG_GOAL_IMAGEVIEW) as! UIImageView
        messageLabel = self.viewWithTag(TAG_MESSAGE_LABEL) as! UILabel
        getBtn = self.viewWithTag(TAG_GET_BUTTON) as! UIButton
        getBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        getBtn.layer.cornerRadius = 5
        getBtn.layer.masksToBounds = true
        
        self.getBtn.addTarget(self, action: #selector(WarningTableViewCell.getBtnClicked), forControlEvents: UIControlEvents.TouchDown)
    }
    
    func getBtnClicked() {
        updateGoalDelegate?.updateEndGoal(self.warning.goal.pkId)
    }
    
    func initWarning(warning: Warning) {
        self.warning = warning
        let message = NSString(format: NSLocalizedString("WATCHED_BY_MONSTER", comment: "You are watched by a %@"), warning.goal.goalName)
        messageLabel.text = message as String
        
        goalImageView.image = UIImage(named: GoalImageFactory.get(warning.goal.type, showTypeName: warning.goal.showTypeName))
    }
}
