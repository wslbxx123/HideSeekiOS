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
    
    private override init() {
        super.init()
        newFriendTableManager = NewFriendTableManager.instance
    }
    
    func setFriend(friendInfo: NSDictionary, message: NSString) {
        saveFriend(friendInfo, message: message)
        
        cacheList = newFriendTableManager.searchFriends()
    }
    
    func setFriends(friendRequests: NSArray) {
        for friendRequest in friendRequests {
            let friendInfo = friendRequest as! NSDictionary
            NewFriendCache.instance.saveFriend(friendInfo,
                                               message: friendInfo["message"] as! NSString)
        }
        
        if friendRequests.count > 0 {
            BadgeUtil.addMeBadge(friendRequests.count)
        }
        
        cacheList = newFriendTableManager.searchFriends()
    }
    
    func saveFriend(friendInfo: NSDictionary, message: NSString) {
        let friendIdStr = friendInfo["pk_id"] as! NSString
        let pinyinStr = PinYinUtil.converterToPinyin(friendInfo["nickname"] as! String)
        let friend = User(
            pkId: friendIdStr.longLongValue,
            phone: friendInfo["phone"] as! NSString,
            nickname: friendInfo["nickname"] as! NSString,
            registerDateStr: friendInfo["register_date"] as! NSString,
            photoUrl: friendInfo["photo_url"] as? NSString,
            smallPhotoUrl: friendInfo["small_photo_url"] as? NSString,
            sex: User.SexEnum(rawValue: (friendInfo["sex"] as! NSString).integerValue)!,
            region: friendInfo["region"] as? NSString,
            role: User.RoleEnum(rawValue: (friendInfo["role"] as! NSString).integerValue)!,
            version: (friendInfo["version"] as! NSString).longLongValue,
            pinyin: NSString(string: pinyinStr))
        
        friend.requestMessage = message
        friend.isFriend = false
        
        newFriendTableManager.updateFriends(friend)
    }
    
    func updateFriendStatus(friendId: Int64) {
        newFriendTableManager.updateFriendStatus(friendId)
        
        cacheList = newFriendTableManager.searchFriends()
    }
    
    func removeFriend(friend: User) {
        newFriendTableManager.removeFriend(friend.pkId)
        
        cacheList = newFriendTableManager.searchFriends()
    }
}
