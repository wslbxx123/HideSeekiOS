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
    
    fileprivate override init() {
        super.init()
        friendTableManager = FriendTableManager.instance
    }
    
    func resortList() {
        let tempFriendList = NSMutableArray()
        
        for i in 0...cacheList.count - 1 {
            let friend = cacheList[i] as! User
            let currentStr = friend.pinyin.substring(to: 1).uppercased()
            
            for char in currentStr.utf8  {
                if (char <= 64 || char >= 91) {
                    tempFriendList.add(friend)
                    break;
                }
            }
        }
        
        cacheList.removeObjects(in: tempFriendList as [AnyObject])
        
        if tempFriendList.count > 0 {
            cacheList.addObjects(from: tempFriendList as [AnyObject])
        }
    }
    
    func setFriends(_ friendInfo: NSDictionary!) {
        saveFriends(friendInfo)
        
        cacheList = friendTableManager.searchFriends()
    }
    
    func saveFriends(_ result: NSDictionary!) {
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
                sex: User.SexEnum(rawValue: BaseInfoUtil.getIntegerFromAnyObject(friendInfo["sex"] as AnyObject))!,
                region: friendInfo["region"] as? NSString,
                role: User.RoleEnum(rawValue: BaseInfoUtil.getIntegerFromAnyObject(friendInfo["role"] as AnyObject))!,
                version: (friendInfo["version"] as! NSString).longLongValue,
                pinyin: NSString(string: pinyinStr))
            
            if (friendInfo.object(forKey: "remark") != nil && !(friendInfo.object(forKey: "remark")! as AnyObject).isKind(of: NSNull.self)) {
                user.alias = friendInfo["remark"] as! NSString
            }
            list.add(user)
        }
        
        friendTableManager.updateFriends(version, friendList: list)
    }
    
    func removeFriend(_ friend: User) {
        friendTableManager.removeFriend(friend.pkId)
        
        cacheList = friendTableManager.searchFriends()
    }
}
