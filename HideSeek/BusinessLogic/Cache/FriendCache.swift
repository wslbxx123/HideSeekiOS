//
//  FriendCache.swift
//  HideSeek
//
//  Created by apple on 8/23/16.
//  Copyright © 2016 mj. All rights reserved.
//

class FriendCache : BaseCache<User> {
    static let instance = FriendCache()
    var friendTableManager: FriendTableManager!
    
    var friendList: NSMutableArray {
        if(super.cacheList.count == 0) {
            super.cacheList = friendTableManager.searchFriends()
            if cacheList.count > 0 {
               resortList() 
            }
        }
        
        return cacheList
    }
    
    private override init() {
        super.init()
        friendTableManager = FriendTableManager.instance
    }
    
    func resortList() {
        let tempFriendList = NSMutableArray()
        
        for i in 0...cacheList.count - 1 {
            let friend = cacheList[i] as! User
            let currentStr = friend.pinyin.substringToIndex(1).uppercaseString
            
            for char in currentStr.utf8  {
                if (char <= 64 || char >= 91) {
                    tempFriendList.addObject(friend)
                    break;
                }
            }
        }
        
        cacheList.removeObjectsInArray(tempFriendList as [AnyObject])
        
        if tempFriendList.count > 0 {
            cacheList.addObjectsFromArray(tempFriendList as [AnyObject])
        }
    }
    
    func setFriends(friendInfo: NSDictionary!) {
        saveFriends(friendInfo)
        
        cacheList = friendTableManager.searchFriends()
    }
    
    func saveFriends(result: NSDictionary!) {
        let list = NSMutableArray()
        let version = (result["version"] as! NSString).longLongValue
        let friendArray = result["friends"] as! NSArray
        
        for friend in friendArray {
            let friendInfo = friend as! NSDictionary
            let friendIdStr = friendInfo["pk_id"] as! NSString
            let pinyinStr = PinYinUtil.converterToPinyin(friendInfo["nickname"] as! String)
            let user = User(
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
            
            if (friendInfo.objectForKey("remark") != nil && !friendInfo.objectForKey("remark")!.isKindOfClass(NSNull)) {
                user.alias = friendInfo["remark"] as! NSString
            }
            list.addObject(user)
        }
        
        friendTableManager.updateFriends(version, friendList: list)
    }
    
    func removeFriend(friend: User) {
        friendTableManager.removeFriend(friend.pkId)
        
        cacheList = friendTableManager.searchFriends()
    }
}
