//
//  NewFriendTableManager.swift
//  HideSeek
//
//  Created by apple on 8/27/16.
//  Copyright © 2016 mj. All rights reserved.
//

import SQLite

class NewFriendTableManager {
    static let instance = NewFriendTableManager()
    
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
    let addTime = Expression<String>("add_time")
    let message = Expression<String>("message")
    let isFriend = Expression<Bool>("isFriend")
    
    var database: Connection!
    var friendTable: Table!
    var userId: Int64!
    
    var version: Int64 {
        get{
            let tempVersion = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.FRIEND_VERSION) as? NSNumber
            
            if(tempVersion == nil) {
                return 0
            }
            return (tempVersion?.longLongValue)!
        }
    }
    
    init() {
        if UserCache.instance.ifLogin() {
            refreshTable(UserCache.instance.user.pkId)
        }
    }
    
    func refreshTable (userId: Int64) {
        do {
            database = DatabaseManager.instance.database
            
            self.userId = userId
            friendTable = Table("new_friend_\(userId)")
            
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
                t.column(addTime)
                t.column(message)
                t.column(isFriend)})
        } catch let error as NSError {
            print("SQLiteDB - failed to create table new_friend_\(userId)!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func searchFriends() -> NSMutableArray {
        let friendList = NSMutableArray()
        do {
            for item in try database.prepare(friendTable.order(pinyin.asc)) {
                let user = User(
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
                    pinyin: item[pinyin]!)
                
                user.addTime = item[addTime]
                user.requestMessage = item[message]
                user.isFriend = item[isFriend]
                friendList.addObject(user)
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to search table new_friend_\(userId)!")
            print("Error - \(error.localizedDescription)")
        }
        
        return friendList
    }
    
    func updateFriends(friendInfo: User) {
        do {
            let date = NSDate()
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let timeStr = timeFormatter.stringFromDate(date)
            let count = try database.run(friendTable.filter(accountId == friendInfo.pkId)
                .update(
                    phone <- (friendInfo.phone as String),
                    nickname <- (friendInfo.nickname as String),
                    registerDate <- timeFormatter.stringFromDate(friendInfo.registerDate),
                    photoUrl <- (friendInfo.photoUrl as String),
                    smallPhotoUrl <- (friendInfo.smallPhotoUrl as String),
                    sex <- friendInfo.sex.rawValue,
                    region <- (friendInfo.region == nil ? nil : friendInfo.region! as String),
                    role <- friendInfo.role.rawValue,
                    pullVersion <- friendInfo.version,
                    pinyin <- (friendInfo.pinyin as String),
                    addTime <- timeStr,
                    message <- (friendInfo.requestMessage as String),
                    isFriend <- friendInfo.isFriend))
            
            if count == 0 {
                let insert = friendTable.insert(
                    phone <- (friendInfo.phone as String),
                    nickname <- (friendInfo.nickname as String),
                    registerDate <- timeFormatter.stringFromDate(friendInfo.registerDate),
                    photoUrl <- (friendInfo.photoUrl as String),
                    smallPhotoUrl <- (friendInfo.smallPhotoUrl as String),
                    sex <- friendInfo.sex.rawValue,
                    region <- (friendInfo.region == nil ? nil : friendInfo.region! as String),
                    role <- friendInfo.role.rawValue,
                    pullVersion <- friendInfo.version,
                    pinyin <- (friendInfo.pinyin as String),
                    addTime <- timeStr,
                    message <- (friendInfo.requestMessage as String),
                    isFriend <- friendInfo.isFriend,
                    accountId <- friendInfo.pkId)
                
                try database.run(insert)
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table new_friend_\(userId)!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func updateFriendStatus(friendId: Int64) {
        do {
            try database.run(friendTable.filter(accountId == friendId)
                .update(isFriend <- true))
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table new_friend_\(userId)!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func removeFriend(friendId: Int64) {
        do {
            try database.run(friendTable.filter(accountId == friendId)
                .delete())
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table new_friend_\(userId)!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func clear() {
        do {
            let sqlStr = "delete from new_friend_\(userId); " +
            "update sqlite_sequence SET seq = 0 where name ='new_friend_\(userId)'"
            try database.execute(sqlStr)
        }
        catch let error as NSError {
            print("SQLiteDB - failed to truncate table new_friend_\(userId)!")
            print("Error - \(error.localizedDescription)")
        }
    }
}
