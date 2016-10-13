//
//  User.swift
//  HideSeek
//
//  Created by apple on 6/28/16.
//  Copyright © 2016 mj. All rights reserved.
//

class User: NSObject {
    var pkId : Int64
    var phone : NSString
    var sessionId : NSString = ""
    var registerDate: NSDate = NSDate()
    var role: RoleEnum
    var version: Int64
    var pinyin: NSString
    var isFriend: Bool = false
    var addTime: NSString = ""
    var requestMessage: NSString = ""
    var alias: NSString = ""
    
    var _defaultArea: NSString = ""
    var defaultArea: NSString {
        get {
            return self._defaultArea
        }
        set {
            self._defaultArea = newValue
            
            let tempUserInfo = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.USER_INFO) as? NSDictionary
            
            if tempUserInfo != nil {
                let userInfo = tempUserInfo?.mutableCopy() as! NSMutableDictionary
                userInfo["default_area"] = newValue
                
                NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: UserDefaultParam.USER_INFO)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    var _defaultAddress: NSString = ""
    var defaultAddress: NSString {
        get {
            return self._defaultAddress
        }
        set {
            self._defaultAddress = newValue
            
            let tempUserInfo = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.USER_INFO) as? NSDictionary
            
            if tempUserInfo != nil {
                let userInfo = tempUserInfo?.mutableCopy() as! NSMutableDictionary
                userInfo["default_address"] = newValue
                
                NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: UserDefaultParam.USER_INFO)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    var _nickname: NSString
    var nickname: NSString {
        get {
            return self._nickname
        }
        set {
            self._nickname = newValue
            
            let tempUserInfo = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.USER_INFO) as? NSDictionary
            
            if tempUserInfo != nil {
                let userInfo = tempUserInfo?.mutableCopy() as! NSMutableDictionary
                userInfo["nickname"] = newValue
                
                NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: UserDefaultParam.USER_INFO)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }

    var _sex = SexEnum.notSet
    var sex: SexEnum {
        get {
            return self._sex
        }
        set {
            self._sex = newValue
            
            let tempUserInfo = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.USER_INFO) as? NSDictionary
            
            if tempUserInfo != nil {
                let userInfo = tempUserInfo?.mutableCopy() as! NSMutableDictionary
                userInfo["sex"] = NSString(format: "%d", newValue.rawValue)
                
                NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: UserDefaultParam.USER_INFO)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }

    var _region: NSString = ""
    var region: NSString {
        get {
            return self._region
        }
        set {
            self._region = newValue
            
            let tempUserInfo = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.USER_INFO) as? NSDictionary
            
            if tempUserInfo != nil {
                let userInfo = tempUserInfo?.mutableCopy() as! NSMutableDictionary
                userInfo["region"] = newValue
                
                NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: UserDefaultParam.USER_INFO)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    var _photoUrl: NSString = ""
    var photoUrl: NSString {
        get {
            return self._photoUrl
        }
        set {
            self._photoUrl = newValue
            
            let tempUserInfo = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.USER_INFO) as? NSDictionary
            
            if tempUserInfo != nil {
                let userInfo = tempUserInfo?.mutableCopy() as! NSMutableDictionary
                userInfo["photo_url"] = newValue
                
                NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: UserDefaultParam.USER_INFO)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    var _smallPhotoUrl: NSString = ""
    var smallPhotoUrl: NSString {
        get {
            return self._smallPhotoUrl
        }
        set {
            self._smallPhotoUrl = newValue
            
            let tempUserInfo = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.USER_INFO) as? NSDictionary
            
            if tempUserInfo != nil {
                let userInfo = tempUserInfo?.mutableCopy() as! NSMutableDictionary
                userInfo["small_photo_url"] = newValue
                
                NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: UserDefaultParam.USER_INFO)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    var _record: Int = 0
    var record: Int {
        get {
            return self._record
        }
        set {
            self._record = newValue
            
            let tempUserInfo = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.USER_INFO) as? NSDictionary
            
            if tempUserInfo != nil {
                let userInfo = tempUserInfo?.mutableCopy() as! NSMutableDictionary
                userInfo["record"] = NSString(format: "%d", newValue)
                
                NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: UserDefaultParam.USER_INFO)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    var _friendNum: Int = 0
    var friendNum: Int {
        get {
            return self._friendNum
        }
        set {
            self._friendNum = newValue
            
            let tempUserInfo = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.USER_INFO) as? NSDictionary
            
            if tempUserInfo != nil {
                let userInfo = tempUserInfo?.mutableCopy() as! NSMutableDictionary
                userInfo["friend_num"] = NSString(format: "%d", newValue)
                
                NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: UserDefaultParam.USER_INFO)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    var _bombNum: Int = 0
    var bombNum: Int {
        get {
            return self._bombNum
        }
        set {
            self._bombNum = newValue
            
            let tempUserInfo = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.USER_INFO) as? NSDictionary
            
            if tempUserInfo != nil {
                let userInfo = tempUserInfo?.mutableCopy() as! NSMutableDictionary
                userInfo["bomb_num"] = NSString(format: "%d", newValue)
                
                NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: UserDefaultParam.USER_INFO)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    var _hasGuide: Bool = false
    var hasGuide: Bool {
        get {
            return self._hasGuide
        }
        set {
            self._hasGuide = newValue
            
            let tempUserInfo = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.USER_INFO) as? NSDictionary
            
            if tempUserInfo != nil {
                let userInfo = tempUserInfo?.mutableCopy() as! NSMutableDictionary
                userInfo["has_guide"] = NSString(format: "%d", newValue ? 1 : 0)
                
                NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: UserDefaultParam.USER_INFO)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    var roleImageName: String {
        get{
            switch role {
            case RoleEnum.grassFairy:
                return "grass_fairy_role"
            case RoleEnum.waterMagician:
                return "water_magician_role"
            case RoleEnum.fireKnight:
                return "fire_knight_role";
            case RoleEnum.stoneMonster:
                return "stone_monster_role"
            case RoleEnum.lightningGiant:
                return "lightning_giant_role"
            }
        }
    }
    
    var roleName: String {
        get{
            switch role {
            case RoleEnum.grassFairy:
                return NSLocalizedString("GRASS_FAIRY", comment: "Grass Fairy")
            case RoleEnum.waterMagician:
                return NSLocalizedString("WATER_MAGICIAN", comment: "Water Magician")
            case RoleEnum.fireKnight:
                return NSLocalizedString("FIRE_KNIGHT", comment: "Fire Knight")
            case RoleEnum.stoneMonster:
                return NSLocalizedString("STONE_MONSTER", comment: "Stone Monster")
            case RoleEnum.lightningGiant:
                return NSLocalizedString("LIGHTNING_GIANT", comment: "Lightning Giant")
            }
        }
    }
    
    var sexName: String {
        get{
            switch sex {
            case SexEnum.female:
                return NSLocalizedString("FEMALE", comment: "Female")
            case SexEnum.male:
                return NSLocalizedString("MALE", comment: "Male")
            case SexEnum.notSet:
                return NSLocalizedString("NOT_SET", comment: "Not Set")
            case SexEnum.secret:
                return NSLocalizedString("SECRET", comment: "Secret")
            }
        }
    }
    
    var sexImageName: String {
        get{
            switch sex {
            case SexEnum.female:
                return "female"
            case SexEnum.male:
                return "male"
            case SexEnum.secret:
                return "secret"
            default:
                return ""
            }
        }
    }
    
    init(pkId: Int64, phone: NSString, sessionId: NSString, nickname: NSString,
         registerDateStr: NSString, record: Int, role: RoleEnum, version: Int64,
         pinyin: NSString, bombNum: Int, hasGuide: Bool, friendNum: Int, sex: SexEnum,
         photoUrl: NSString?, smallPhotoUrl: NSString?, region: NSString?,
         defaultArea: NSString?, defaultAddress: NSString?) {
        self.pkId = pkId
        self.phone = phone
        self.sessionId = sessionId
        self._nickname = nickname
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.registerDate = dateFormatter.dateFromString(registerDateStr as String)!
        self._record = record
        self.role = role
        self.version = version
        self.pinyin = pinyin
        self._bombNum = bombNum
        self._hasGuide = hasGuide
        self._friendNum = friendNum
        self._sex = sex
        
        if photoUrl != nil {
            self._photoUrl = photoUrl!
        }
        
        if smallPhotoUrl != nil {
            self._smallPhotoUrl = smallPhotoUrl!
        }
        
        if region != nil {
            self._region = region!
        }
        
        if defaultArea != nil {
            self._defaultArea = defaultArea!
        }
        
        if defaultAddress != nil {
            self._defaultAddress = defaultAddress!
        }
    }
    
    init(pkId: Int64, phone: NSString, nickname: NSString, registerDateStr: NSString,
         photoUrl: NSString?, smallPhotoUrl: NSString?, sex: SexEnum, region: NSString?,
         role: RoleEnum, version: Int64, pinyin: NSString) {
        self.pkId = pkId
        self.phone = phone
        self._nickname = nickname
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.registerDate = dateFormatter.dateFromString(registerDateStr as String)!
        
        if photoUrl != nil {
            self._photoUrl = photoUrl!
        }
        
        if smallPhotoUrl != nil {
            self._smallPhotoUrl = smallPhotoUrl!
        }
        
        if region != nil {
            self._region = region!
        }
        
        self._sex = sex
        self.role = role
        self.version = version
        self.pinyin = pinyin
    }
    
    enum SexEnum : Int {
        case notSet = 0
        case female = 1
        case male = 2
        case secret = 3
    }
    
    enum RoleEnum : Int {
        case grassFairy = 0
        case waterMagician = 1
        case fireKnight = 2
        case stoneMonster = 3
        case lightningGiant = 4
    }
}
