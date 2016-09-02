//
//  FriendTableManager.swift
//  HideSeek
//
//  Created by apple on 8/23/16.
//  Copyright © 2016 mj. All rights reserved.
//

import SQLite

class FriendTableManager {
    static let instance = FriendTableManager()
    
    let accountId = Expression<Int64>("account_id")
    let phone = Expression<String>("phone")
    let nickname = Expression<String>("nickname")
    let registerDate = Expression<String>("register_date")
    let photoUrl = Expression<String?>("photo_url")
    let smallPhotoUrl = Expression<String?>("small_photo_url")
    let sex = Expression<Int>("sex")
    let region = Expression<String?>("region")
    let role = Expression<Int>("role")
    let pullVersion = Expression<Int64>("version")
    let pinyin = Expression<String?>("pinyin")
    
    var database: Connection!
    var friendTable: Table!
    
    var version: Int64 {
        get{
            let tempVersion = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.FRIEND_VERSION) as? NSNumber
            
            if(tempVersion == nil) {
                return 0
            }
            return (tempVersion?.longLongValue)!
        }
    }
    
    private init() {
        do {
            database = DatabaseManager.instance.database
            
            friendTable = Table("friend")
            
            try database.run(friendTable.create(ifNotExists: true) { t in
                t.column(accountId)
                t.column(phone)
                t.column(nickname)
                t.column(registerDate)
                t.column(photoUrl)
                t.column(smallPhotoUrl)
                t.column(sex)
                t.column(region)
                t.column(role)
                t.column(pullVersion)
                t.column(pinyin)
                })
        } catch let error as NSError {
            print("SQLiteDB - failed to create table friend!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func searchFriends() -> NSMutableArray {
        let friendList = NSMutableArray()
        do {
            for item in try database.prepare(friendTable.order(pinyin.asc)) {
                friendList.addObject(User(
                    pkId: item[accountId],
                    phone: item[phone],
                    nickname: item[nickname],
                    registerDateStr: item[registerDate],
                    photoUrl: item[photoUrl],
                    smallPhotoUrl: item[smallPhotoUrl],
                    sex: User.SexEnum(rawValue: item[sex])!,
                    region: (item[region] == nil ? nil : item[region]),
                    role: User.RoleEnum(rawValue: item[role])!,
                    version: item[pullVersion],
                    pinyin: item[pinyin]!))
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to search table friend!")
            print("Error - \(error.localizedDescription)")
        }
        
        return friendList
    }
    
    func searchFriends(keyword: String) -> NSMutableArray {
        let friendList = NSMutableArray()
        do {
            for item in try database.prepare(friendTable.filter(nickname.like("%\(keyword)%") || pinyin.like("%\(keyword)%")).order(pinyin.asc)) {
                friendList.addObject(User(
                    pkId: item[accountId],
                    phone: item[phone],
                    nickname: item[nickname],
                    registerDateStr: item[registerDate],
                    photoUrl: item[photoUrl],
                    smallPhotoUrl: item[smallPhotoUrl],
                    sex: User.SexEnum(rawValue: item[sex])!,
                    region: (item[region] == nil ? nil : item[region]),
                    role: User.RoleEnum(rawValue: item[role])!,
                    version: item[pullVersion],
                    pinyin: item[pinyin]!))
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to search table friend!")
            print("Error - \(error.localizedDescription)")
        }
        
        return friendList
    }
    
    func updateFriends(version: Int64, friendList: NSArray) {
        do {
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(longLong:version), forKey: UserDefaultParam.FRIEND_VERSION)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            for friendItem in friendList {
                let friendInfo = friendItem as! User
                
                let count = try database.run(friendTable.filter(accountId == friendInfo.pkId)
                    .update(
                        phone <- (friendInfo.phone as String),
                        nickname <- (friendInfo.nickname as String),
                        registerDate <- dateFormatter.stringFromDate(friendInfo.registerDate),
                        photoUrl <- (friendInfo.photoUrl as String),
                        smallPhotoUrl <- (friendInfo.smallPhotoUrl as String),
                        sex <- friendInfo.sex.rawValue,
                        region <- (friendInfo.region == nil ? nil : friendInfo.region! as String),
                        role <- friendInfo.role.rawValue,
                        pullVersion <- friendInfo.version,
                        pinyin <- (friendInfo.pinyin as String)))
                
                if count == 0 {
                    let insert = friendTable.insert(
                        phone <- (friendInfo.phone as String),
                        nickname <- (friendInfo.nickname as String),
                        registerDate <- dateFormatter.stringFromDate(friendInfo.registerDate),
                        photoUrl <- (friendInfo.photoUrl as String),
                        smallPhotoUrl <- (friendInfo.smallPhotoUrl as String),
                        sex <- friendInfo.sex.rawValue,
                        region <- (friendInfo.region == nil ? nil : friendInfo.region! as String),
                        role <- friendInfo.role.rawValue,
                        pullVersion <- friendInfo.version,
                        pinyin <- (friendInfo.pinyin as String),
                        accountId <- friendInfo.pkId)
                    
                    try database.run(insert)
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table friend!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func clear() {
        do {
            let sqlStr = "delete from friend; " +
            "update sqlite_sequence SET seq = 0 where name ='friend'"
            try database.execute(sqlStr)
        }
        catch let error as NSError {
            print("SQLiteDB - failed to truncate table friend!")
            print("Error - \(error.localizedDescription)")
        }
    }
}
