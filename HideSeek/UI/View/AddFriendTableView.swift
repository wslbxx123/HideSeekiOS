//
//  AddFriendTableView.swift
//  HideSeek
//
//  Created by apple on 8/24/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class AddFriendTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    let TAG_PHOTO_IMAGEVIEW = 1
    let TAG_NAME_LABEL = 2
    var addFriendList: NSMutableArray!
    var screenHeight: CGFloat!
    var goToProfileDelegate: GoToProfileDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.addFriendList = NSMutableArray()
        self.screenHeight = UIScreen.main.bounds.height - 44
        self.separatorStyle = UITableViewCellSeparatorStyle.none;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: "addFriendCell")! as UITableViewCell
        
        if addFriendList.count < (indexPath as NSIndexPath).row + 1 {
            return cell
        }
        let friend = addFriendList.object(at: (indexPath as NSIndexPath).row) as! User
        
        let photoImageView = cell.viewWithTag(TAG_PHOTO_IMAGEVIEW) as! UIImageView
        let nameLabel = cell.viewWithTag(TAG_NAME_LABEL) as! UILabel
        
        photoImageView.layer.cornerRadius = 5
        photoImageView.layer.masksToBounds = true
        photoImageView.setWebImage(friend.smallPhotoUrl as String, defaultImage: "default_photo", isCache: true)
        nameLabel.text = friend.nickname as String
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addFriendList.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if addFriendList.count < (indexPath as NSIndexPath).row + 1 {
            return
        }
        
        let friend = addFriendList.object(at: (indexPath as NSIndexPath).row) as! User
        
        self.goToProfileDelegate?.goToProfile(friend)
    }
}
