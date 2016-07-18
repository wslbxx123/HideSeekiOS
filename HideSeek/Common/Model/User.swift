//
//  User.swift
//  HideSeek
//
//  Created by apple on 6/28/16.
//  Copyright © 2016 mj. All rights reserved.
//

class User {
    var pkId : Int64!
    var phone : String!
    var sessionId : String!
    var nickname: String!
    var photoUrl: String!
    var registerDate: NSDate!
    var sex: SexEnum!
    var region: String!
    var role: RoleEnum
    var version: Int64!
    var pinyin: String!
    var bombNum: Int!
    var hasGuide: Bool!
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
    
    init(pkId: Int64, phone: String, sessionId: String, nickname: String,
         registerDateStr: String, role: RoleEnum, version: Int64, pinyin: String,
         bombNum: Int, hasGuide: Bool) {
        self.pkId = pkId
        self.phone = phone
        self.sessionId = sessionId
        self.nickname = nickname
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.registerDate = dateFormatter.dateFromString(registerDateStr)
        self.role = role
        self.version = version
        self.pinyin = pinyin
        self.bombNum = bombNum
        self.hasGuide = hasGuide
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
