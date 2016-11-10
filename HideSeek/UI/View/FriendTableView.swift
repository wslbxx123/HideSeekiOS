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
    let TAG_NICKNAME_LABEL = 5
    
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
    var removeFriendDelegate: RemoveFriendDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.friendList = NSMutableArray()
        self.screenHeight = UIScreen.main.bounds.height - 44
        self.separatorStyle = UITableViewCellSeparatorStyle.none;
        self.tintColor = UIColor.black
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        let toBeReturned = NSMutableArray()
        
        if !isSearching {
            toBeReturned.addObjects(from: alphaIndex.allKeys)
        }
        
        return toBeReturned.copy() as? [String]
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if index < 1 {
            tableView.scrollToRow(at: IndexPath(item: 0, section: index), at: UITableViewScrollPosition.top, animated: true)
        } else {
            let position = alphaIndex[title]
            
            if (position != nil) {
                tableView.scrollToRow(at: IndexPath(item: position as! Int, section: 1), at: UITableViewScrollPosition.top, animated: true)
            }
        }
        
        return index
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch((indexPath as NSIndexPath).section) {
        case 0:
            cell = self.dequeueReusableCell(withIdentifier: "newFriendTitleCell")! as UITableViewCell
            break;
        case 1:
            cell = self.dequeueReusableCell(withIdentifier: "friendCell")! as UITableViewCell
            
            if friendList.count < (indexPath as NSIndexPath).row + 1 {
                return cell
            }
            
            let friend = friendList.object(at: (indexPath as NSIndexPath).row) as! User
            
            let showAlpha = alphaIndex.allValues.contains(where: { value in
                return value as! Int == (indexPath as NSIndexPath).row
            })
            
            let alphaView = cell.viewWithTag(TAG_ALPHA_VIEW)!
            let alphaLabel = cell.viewWithTag(TAG_ALPHA_LABEL) as! UILabel
            let photoImageView = cell.viewWithTag(TAG_PHOTO_IMAGEVIEW) as! UIImageView
            let nameLabel = cell.viewWithTag(TAG_NAME_LABEL) as! UILabel
            let nicknameLabel = cell.viewWithTag(TAG_NICKNAME_LABEL) as! UILabel
            if showAlpha && !isSearching {
                alphaView.isHidden = false
                alphaLabel.text = alphaIndex.allKeys(for: (indexPath as NSIndexPath).row)[0] as? String
            } else {
                alphaView.isHidden = true
                alphaLabel.text = ""
            }
            
            photoImageView.layer.cornerRadius = 5
            photoImageView.layer.masksToBounds = true
            photoImageView.setWebImage(friend.smallPhotoUrl as String, defaultImage: "default_photo", isCache: true)
            nameLabel.text = friend.nickname as String
            
            if friend.alias != "" {
                nameLabel.text = friend.alias as String
                nicknameLabel.isHidden = false
                nicknameLabel.text = NSString(format: NSLocalizedString("NAME", comment: "Name: %s") as NSString, friend.nickname) as String
            } else {
                nicknameLabel.isHidden = true
            }
            break;
        default:
            cell = UITableViewCell()
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if isSearching {
                return 0
            } else {
                return 1
            }
        }
        
        return friendList.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch((indexPath as NSIndexPath).section) {
        case 0:
            return 62
        default:
            let showAlpha = alphaIndex.allValues.contains(where: { value in
                return value as! Int == (indexPath as NSIndexPath).row
            })
            
            
            if showAlpha && !isSearching{
                return 100
            } else {
                return 62
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            goToNewFriendDelegate?.goToNewFriend()
        } else {
            if friendList.count < (indexPath as NSIndexPath).row + 1 {
                return
            }
            
            let friend = friendList.object(at: (indexPath as NSIndexPath).row) as! User
            friend.isFriend = true
            goToProfileDelegate?.goToProfile(friend)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            if friendList.count < (indexPath as NSIndexPath).row + 1 {
                return
            }
            
            let friend = friendList.object(at: (indexPath as NSIndexPath).row) as! User
            
            removeFriendDelegate?.checkRemoveFriend(friend)
        }
    }
}
