//
//  UserCache.swift
//  HideSeek
//
//  Created by apple on 6/28/16.
//  Copyright © 2016 mj. All rights reserved.
//

class UserCache {
    static let instance = UserCache()
    var ifNeedRefresh: Bool = false
    
    fileprivate var _user: User! = nil
    var user: User! {
        get{
            if(_user != nil) {
                return _user
            }
            
            let tempUserInfo = UserDefaults.standard.object(forKey: UserDefaultParam.USER_INFO) as? NSDictionary
            
            if(tempUserInfo == nil) {
                return nil
            }
            
            return from(tempUserInfo!)
        }
        set {
            _user = newValue
        }
    }
    
    func setUser(_ userInfo: NSDictionary) {
        user = from(userInfo)
        
        NewFriendTableManager.instance.refreshTable(user.pkId)
        
        if(userInfo.object(forKey: "friend_requests") != nil) {
            let friendRequests = userInfo["friend_requests"] as! NSArray
            
            NewFriendCache.instance.setFriends(friendRequests)
        }
        
        if(user.pkId > 0) {
            UserDefaults.standard.set(userInfo["session_id"], forKey: UserDefaultParam.SESSION_TOKEN)
            let tempUserInfo = BaseInfoUtil.removeNullFromDictionary(userInfo)
            UserDefaults.standard.set(tempUserInfo, forKey: UserDefaultParam.USER_INFO)
            UserDefaults.standard.synchronize()
        }
    }
    
    func from(_ userInfo: NSDictionary)-> User {
        let user = User (pkId: (userInfo["pk_id"] as! NSString).longLongValue,
                         phone: userInfo["phone"] as! String as NSString,
                         sessionId: userInfo["session_id"] as! String as NSString,
                         nickname: userInfo["nickname"] as! String as NSString,
                         registerDateStr: userInfo["register_date"] as! String as NSString,
                         record: BaseInfoUtil.getIntegerFromAnyObject(userInfo["record"]!),
                         role: User.RoleEnum(rawValue: BaseInfoUtil.getIntegerFromAnyObject(userInfo["role"]))!,
                         version: (userInfo["version"] as! NSString).longLongValue,
                         pinyin: PinYinUtil.converterToPinyin(userInfo["nickname"] as! String) as NSString,
                         bombNum: BaseInfoUtil.getIntegerFromAnyObject(userInfo["bomb_num"]),
                         hasGuide: BaseInfoUtil.getIntegerFromAnyObject(userInfo["has_guide"]) == 1,
                         friendNum: BaseInfoUtil.getIntegerFromAnyObject(userInfo["friend_num"]),
                         sex: User.SexEnum(rawValue: BaseInfoUtil.getIntegerFromAnyObject(userInfo["sex"]))!,
                         photoUrl: userInfo["photo_url"] as? NSString,
                         smallPhotoUrl: userInfo["small_photo_url"] as? NSString,
                         region: userInfo["region"] as? NSString,
                         defaultArea: userInfo["default_area"] as? NSString,
                         defaultAddress: userInfo["default_address"] as? NSString)
        
        return user
    }
    
    func ifLogin()-> Bool {
        let userDefault = UserDefaults.standard
        let sessionToken = userDefault.object(forKey: UserDefaultParam.SESSION_TOKEN) as? NSString
        
        return sessionToken != nil
    }
}
