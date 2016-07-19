//
//  UserCache.swift
//  HideSeek
//
//  Created by apple on 6/28/16.
//  Copyright © 2016 mj. All rights reserved.
//

class UserCache {
    static let instance = UserCache()
    
    private var _user: User! = nil
    var user: User! {
        get{
            if(_user != nil) {
                return _user
            }
            
            let tempUserInfo = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.USER_INFO) as? NSDictionary
            
            if(tempUserInfo == nil) {
                return nil
            }
            
            return from(tempUserInfo!)
        }
        set {
            _user = newValue
        }
    }
    
    func setUser(userInfo: NSDictionary!) {
        user = from(userInfo)
        
        if(user.pkId > 0) {
            NSUserDefaults.standardUserDefaults().setObject(userInfo["session_id"], forKey: UserDefaultParam.SESSION_TOKEN)
            NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: UserDefaultParam.USER_INFO)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func from(userInfo: NSDictionary)-> User {
        let user = User (pkId: (userInfo["pk_id"] as! NSString).longLongValue,
                         phone: userInfo["phone"] as! String,
                         sessionId: userInfo["session_id"] as! String,
                         nickname: userInfo["nickname"] as! String,
                         registerDateStr: userInfo["register_date"] as! String,
                         role: User.RoleEnum(rawValue: (userInfo["role"] as! NSString).integerValue)!,
                         version: (userInfo["version"] as! NSString).longLongValue,
                         pinyin: PinYinUtil.converterToFirstSpell(userInfo["nickname"] as! String),
                         bombNum: (userInfo["bomb_num"] as! NSNumber).integerValue,
                         hasGuide: (userInfo["has_guide"] as! NSString).integerValue == 1)
        
        if((userInfo.objectForKey("photo_url")) != nil) {
            user.photoUrl = userInfo["photo_url"] as! String
        }
        
        if((userInfo.objectForKey("sex")) != nil) {
            user.sex = User.SexEnum(rawValue: (userInfo["sex"] as! NSString).integerValue)
        }
        
        return user
    }
    
    func ifLogin()-> Bool {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let sessionToken = userDefault.objectForKey(UserDefaultParam.SESSION_TOKEN) as? NSString
        
        return sessionToken != nil
    }
}
