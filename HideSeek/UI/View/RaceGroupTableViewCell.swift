//
//  RaceGroupTableViewCell.swift
//  HideSeek
//
//  Created by apple on 9/19/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class RaceGroupTableViewCell: UITableViewCell {
    let TAG_PHOTO_IMAGEVIEW = 1
    let TAG_NAME_LABEL = 2
    let TAG_GOAL_IMAGEVIEW = 3
    let TAG_MESSAGE_LABEL = 4
    let TAG_SCORE_LABEL = 5
    let TAG_TIME_LABEL = 6
    
    var photoImageView: UIImageView!
    var nameLabel: UILabel!
    var goalImageView: UIImageView!
    var messageLabel: UILabel!
    var scoreLabel: UILabel!
    var timeLabel: UILabel!
    var goToPhotoDelegate: GoToPhotoDelegate!
    var raceGroup: RaceGroup!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.photoImageView = self.viewWithTag(TAG_PHOTO_IMAGEVIEW) as! UIImageView
        self.nameLabel = self.viewWithTag(TAG_NAME_LABEL) as! UILabel
        self.goalImageView = self.viewWithTag(TAG_GOAL_IMAGEVIEW) as! UIImageView
        self.messageLabel = self.viewWithTag(TAG_MESSAGE_LABEL) as! UILabel
        self.scoreLabel = self.viewWithTag(TAG_SCORE_LABEL) as! UILabel
        self.timeLabel = self.viewWithTag(TAG_TIME_LABEL) as! UILabel
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RaceGroupTableViewCell.photoImageViewSelected))
        self.photoImageView.isUserInteractionEnabled = true
        self.photoImageView.addGestureRecognizer(tapGesture)
    }
    
    func initRaceGroup(_ raceGroup: RaceGroup) {
        photoImageView.layer.cornerRadius = 5
        photoImageView.layer.masksToBounds = true
        photoImageView.setWebImage(raceGroup.smallPhotoUrl, defaultImage: "default_photo", isCache: true)
        nameLabel.text = raceGroup.remark == nil ? raceGroup.nickname : raceGroup.remark
        
        goalImageView.image = UIImage(named: GoalImageFactory.get(raceGroup.recordItem.goalType, showTypeName: raceGroup.recordItem.showTypeName))
        
        messageLabel.text = RaceGroupMessageFactory.get(raceGroup.recordItem.score, goalType: raceGroup.recordItem.goalType, showTypeName: raceGroup.recordItem.showTypeName)
        
        let scoreStr = raceGroup.recordItem.score >= 0 ? "+" + String(raceGroup.recordItem.score) : String(raceGroup.recordItem.score)
        
        scoreLabel.text =  NSLocalizedString("SCORE_TITLE", comment: "Score: ") + scoreStr
        
        timeLabel.text = raceGroup.recordItem.time
        self.raceGroup = raceGroup
    }
    
    func photoImageViewSelected() {
        goToPhotoDelegate?.goToPhoto(raceGroup)
    }
}
