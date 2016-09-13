//
//  FriendTableView.swift
//  HideSeek
//
//  Created by apple on 8/23/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class FriendTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    let TAG_ALPHA_VIEW = 1
    let TAG_ALPHA_LABEL = 2
    let TAG_PHOTO_IMAGEVIEW = 3
    let TAG_NAME_LABEL = 4
    
    var friendList: NSMutableArray!
    var tabelViewCell: UITableViewCell!
    var messageWidth: CGFloat!
    var infiniteScrollingView: UIView!
    var loadMoreDelegate: LoadMoreDelegate!
    var screenHeight: CGFloat!
    var alphaIndex: NSDictionary = NSDictionary()
    var isSearching: Bool = false
    var goToNewFriendDelegate: GoToNewFriendDelegate!
    var goToProfileDelegate: GoToProfileDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.friendList = NSMutableArray()
        self.screenHeight = UIScreen.mainScreen().bounds.height - 44
        self.separatorStyle = UITableViewCellSeparatorStyle.None;
        self.tintColor = UIColor.blackColor()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        let toBeReturned = NSMutableArray()
        
        if !isSearching {
            for index in 0...25 {
                let randomNum = 65 + index
                let char = Character(UnicodeScalar(randomNum))
                toBeReturned.addObject(String(char))
            }
            toBeReturned.addObject("#")
        }
        
        return toBeReturned.copy() as? [String]
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if index < 1 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: 0, inSection: index), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        } else {
            let position = alphaIndex[title]
            
            if (position != nil) {
                tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: position as! Int, inSection: 1), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            }
        }
        
        return index
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch(indexPath.section) {
        case 0:
            cell = self.dequeueReusableCellWithIdentifier("newFriendTitleCell")! as UITableViewCell
            break;
        case 1:
            cell = self.dequeueReusableCellWithIdentifier("friendCell")! as UITableViewCell
            
            if friendList.count < indexPath.row + 1 {
                return cell
            }
            
            let friend = friendList.objectAtIndex(indexPath.row) as! User
            
            let showAlpha = alphaIndex.allValues.contains({ value in
                return value as! Int == indexPath.row
            })
            
            let alphaView = cell.viewWithTag(TAG_ALPHA_VIEW)!
            let alphaLabel = cell.viewWithTag(TAG_ALPHA_LABEL) as! UILabel
            let photoImageView = cell.viewWithTag(TAG_PHOTO_IMAGEVIEW) as! UIImageView
            let nameLabel = cell.viewWithTag(TAG_NAME_LABEL) as! UILabel
            if showAlpha && !isSearching {
                alphaView.hidden = false
                alphaLabel.text = alphaIndex.allKeysForObject(indexPath.row)[0] as? String
            } else {
                alphaView.hidden = true
                alphaLabel.text = ""
            }
            
            photoImageView.layer.cornerRadius = 5
            photoImageView.layer.masksToBounds = true
            photoImageView.setWebImage(friend.smallPhotoUrl as String, defaultImage: "default_photo", isCache: true)
            nameLabel.text = friend.nickname as String
            
            if friend.alias != "" {
                nameLabel.text = friend.alias as String
            }
            break;
        default:
            cell = UITableViewCell()
        }
    
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if isSearching {
                return 0
            } else {
                return 1
            }
        }
        
        return friendList.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch(indexPath.section) {
        case 0:
            return 62
        default:
            let showAlpha = alphaIndex.allValues.contains({ value in
                return value as! Int == indexPath.row
            })
            
            
            if showAlpha && !isSearching{
                return 100
            } else {
                return 62
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            goToNewFriendDelegate?.goToNewFriend()
        } else {
            if friendList.count < indexPath.row + 1 {
                return
            }
            
            let friend = friendList.objectAtIndex(indexPath.row) as! User
            friend.isFriend = true
            goToProfileDelegate?.goToProfile(friend)
        }
    }
}
