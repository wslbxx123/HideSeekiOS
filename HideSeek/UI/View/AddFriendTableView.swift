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
        self.screenHeight = UIScreen.mainScreen().bounds.height - 44
        self.separatorStyle = UITableViewCellSeparatorStyle.None;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCellWithIdentifier("addFriendCell")! as UITableViewCell
        
        if addFriendList.count < indexPath.row + 1 {
            return cell
        }
        let friend = addFriendList.objectAtIndex(indexPath.row) as! User
        
        let photoImageView = cell.viewWithTag(TAG_PHOTO_IMAGEVIEW) as! UIImageView
        let nameLabel = cell.viewWithTag(TAG_NAME_LABEL) as! UILabel
        
        photoImageView.layer.cornerRadius = 5
        photoImageView.layer.masksToBounds = true
        photoImageView.setWebImage(friend.smallPhotoUrl as String, defaultImage: "default_photo", isCache: true)
        nameLabel.text = friend.nickname as String
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addFriendList.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if addFriendList.count < indexPath.row + 1 {
            return
        }
        
        let friend = addFriendList.objectAtIndex(indexPath.row) as! User
        
        self.goToProfileDelegate?.goToProfile(friend)
    }
}
