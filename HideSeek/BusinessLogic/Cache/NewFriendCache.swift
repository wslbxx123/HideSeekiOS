//
//  NewFriendCache.swift
//  HideSeek
//
//  Created by apple on 8/27/16.
//  Copyright © 2016 mj. All rights reserved.
//

class NewFriendCache : BaseCache<User> {
    static let instance = NewFriendCache()
    var newFriendTableManager: NewFriendTableManager!
    
    var friendList: NSMutableArray {
        if(super.cacheList.count == 0) {
            super.cacheList = newFriendTableManager.searchFriends()
        }
        
        return cacheList
    }
    
    fileprivate override init() {
        super.init()
        newFriendTableManager = NewFriendTableManager.instance
    }
    
    func setFriend(_ friendInfo: NSDictionary, message: NSString, isFriend: Bool) {
        saveFriend(friendInfo, message: message, isFriend: isFriend)
        
        cacheList = newFriendTableManager.searchFriends()
    }
    
    func setFriends(_ friendRequests: NSArray) {
        for friendRequest in friendRequests {
            let friendInfo = friendRequest as! NSDictionary
            let isFriend = BaseInfoUtil.getIntegerFromAnyObject(friendInfo["status"]) == 1
            
            var message: NSString
            if isFriend {
                message = NSLocalizedString("ACCEPT_FRIEND_REQUEST", comment: "Accepted your friend request") as NSString
            } else {
                message = friendInfo["message"] as! NSString
            }
            
            NewFriendCache.instance.saveFriend(friendInfo,
                                               message: message,
                                               isFriend: isFriend)
        }
        
        if friendRequests.count > 0 {
            BadgeUtil.addMeBadge(friendRequests.count)
        }
        
        cacheList = newFriendTableManager.searchFriends()
    }
    
    func saveFriend(_ friendInfo: NSDictionary, message: NSString, isFriend: Bool) {
        let friendIdStr = friendInfo["pk_id"] as! NSString
        let pinyinStr = PinYinUtil.converterToPinyin(friendInfo["nickname"] as! String)
        let friend = User(
            pkId: friendIdStr.longLongValue,
            phone: friendInfo["phone"] as! NSString,
            nickname: friendInfo["nickname"] as! NSString,
            registerDateStr: friendInfo["register_date"] as! NSString,
            photoUrl: friendInfo["photo_url"] as? NSString,
            smallPhotoUrl: friendInfo["small_photo_url"] as? NSString,
            sex: User.SexEnum(rawValue: BaseInfoUtil.getIntegerFromAnyObject(friendInfo["sex"]))!,
            region: friendInfo["region"] as? NSString,
            role: User.RoleEnum(rawValue: BaseInfoUtil.getIntegerFromAnyObject(friendInfo["role"]))!,
            version: (friendInfo["version"] as! NSString).longLongValue,
            pinyin: NSString(string: pinyinStr))
        
        friend.requestMessage = message
        friend.isFriend = isFriend
        
        newFriendTableManager.updateFriends(friend)
    }
    
    func updateFriendStatus(_ friendId: Int64) {
        newFriendTableManager.updateFriendStatus(friendId)
        
        cacheList = newFriendTableManager.searchFriends()
    }
    
    func removeFriend(_ friend: User) {
        newFriendTableManager.removeFriend(friend.pkId)
        
        cacheList = newFriendTableManager.searchFriends()
    }
}
