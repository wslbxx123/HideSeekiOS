//
//  NewFriendTableViewCell.swift
//  HideSeek
//
//  Created by apple on 8/29/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class NewFriendTableViewCell: UITableViewCell {
    let TAG_PHOTO_IMAGEVIEW = 1
    let TAG_NAME_LABEL = 2
    let TAG_MESSAGE_LABEL = 3
    let TAG_ACCEPT_BUTTON = 4
    let TAG_STATUS_LABEL = 5
    
    var photoImageView: UIImageView!
    var nameLabel: UILabel!
    var messageLabel: UILabel!
    var acceptBtn: UIButton!
    var statusLabel: UILabel!
    var friendId: Int64!
    var acceptDelegate: AcceptDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        photoImageView = self.viewWithTag(TAG_PHOTO_IMAGEVIEW) as! UIImageView
        nameLabel = self.viewWithTag(TAG_NAME_LABEL) as! UILabel
        messageLabel = self.viewWithTag(TAG_MESSAGE_LABEL) as! UILabel
        acceptBtn = self.viewWithTag(TAG_ACCEPT_BUTTON) as! UIButton
        statusLabel = self.viewWithTag(TAG_STATUS_LABEL) as! UILabel
        self.acceptBtn.addTarget(self, action: #selector(NewFriendTableViewCell.acceptBtnClicked), for: UIControlEvents.touchDown)
    }
    
    func acceptBtnClicked() {
        acceptDelegate?.acceptFriend(friendId)
    }
    
    func initNewFriend(_ friend: User) {
        friendId = friend.pkId
        photoImageView.setWebImage(friend.smallPhotoUrl as String, defaultImage: "default_photo", isCache: true)
        nameLabel.text = friend.nickname as String
        messageLabel.text = friend.requestMessage as String
        acceptBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        acceptBtn.layer.cornerRadius = 5
        acceptBtn.layer.masksToBounds = true
        
        if friend.isFriend {
            acceptBtn.isHidden = true
            statusLabel.isHidden = false
        } else {
            acceptBtn.isHidden = false
            statusLabel.isHidden = true
        }
    }
}
