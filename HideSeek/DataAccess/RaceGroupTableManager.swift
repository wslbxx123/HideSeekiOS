//
//  RaceGroupTableManager.swift
//  HideSeek
//
//  Created by apple on 7/5/16.
//  Copyright © 2016 mj. All rights reserved.
//
import SQLite

class RaceGroupTableManager {
    static let instance = RaceGroupTableManager()
    
    let recordId = Expression<Int64>("record_id")
    let photoUrl = Expression<String?>("photo_url")
    let smallPhotoUrl = Expression<String?>("small_photo_url")
    let remark = Expression<String?>("remark")
    let nickname = Expression<String>("nickname")
    let time = Expression<String>("time")
    let goalType = Expression<Int>("goal_type")
    let score = Expression<Int>("score")
    let scoreSum = Expression<Int>("score_sum")
    let pullVersion = Expression<Int64>("version")
    let showTypeName = Expression<String?>("show_type_name")
    
    var database: Connection!
    var raceGroupTable: Table!
    var _recordMinId: Int64 = 0
    var timeFormatter: DateFormatter = DateFormatter()
    
    var recordMinId: Int64 {
        get{
            let tempRecordMinId = UserDefaults.standard.object(forKey: UserDefaultParam.RACE_GROUP_RECORD_MIN_ID) as? NSNumber
            
            if(tempRecordMinId == nil) {
                return 0
            }
            return (tempRecordMinId?.int64Value)!
        }
    }
    
    var version: Int64 {
        get{
            let tempVersion = UserDefaults.standard.object(forKey: UserDefaultParam.RACE_GROUP_VERSION) as? NSNumber
            
            if(tempVersion == nil) {
                return 0
            }
            return (tempVersion?.int64Value)!
        }
    }
    
    var updateDate: String {
        get{
            let tempUpdateDate = UserDefaults.standard.object(forKey: UserDefaultParam.RACE_GROUP_UPDATE_TIME) as? NSString
            
            if(tempUpdateDate == nil) {
                return ""
            }
            return tempUpdateDate! as String
        }
    }
    
    fileprivate init() {
        do {
            database = DatabaseManager.instance.database
            
            raceGroupTable = Table("race_group")
            timeFormatter.dateFormat = "yyyy-MM-dd"
            
            try database.run(raceGroupTable.create(ifNotExists: true) { t in
                t.column(recordId, primaryKey: true)
                t.column(photoUrl)
                t.column(smallPhotoUrl)
                t.column(remark)
                t.column(nickname)
                t.column(time)
                t.column(goalType)
                t.column(score)
                t.column(scoreSum)
                t.column(pullVersion)
                t.column(showTypeName)
                })
        } catch let error as NSError {
            print("SQLiteDB - failed to create table race_group!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func searchRaceGroup() -> NSMutableArray {
        let curDate = Date()
        let curDateStr = timeFormatter.string(from: curDate)
        
        if(curDateStr != updateDate) {
            clearMoreData()
        }
        
        UserDefaults.standard.set(curDateStr, forKey: UserDefaultParam.RACE_GROUP_UPDATE_TIME)
        UserDefaults.standard.synchronize()
        
        let raceGroupList = NSMutableArray()
        do {
            var result: Table
            if self._recordMinId == 0 {
                result = raceGroupTable.order(recordId.desc).limit(10)
            } else {
                result = raceGroupTable.filter(recordId >= self._recordMinId).order(recordId.desc)
            }
            
            for item in try database.prepare(result) {
                raceGroupList.add(RaceGroup(
                    recordId: item[recordId],
                    nickname: item[nickname],
                    photoUrl: item[photoUrl],
                    smallPhotoUrl: item[smallPhotoUrl],
                    remark: item[remark],
                    recordItem: RecordItem(recordId: item[recordId],
                        time: item[time],
                        goalType: Goal.GoalTypeEnum(rawValue: item[goalType])!,
                        score: item[score],
                        scoreSum: item[scoreSum],
                        version: item[pullVersion],
                        showTypeName: item[showTypeName])))
                
                if _recordMinId == 0 || _recordMinId > item[recordId] {
                    _recordMinId = item[recordId]
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table race_group!")
            print("Error - \(error.localizedDescription)")
        }
        
        return raceGroupList
    }
    
    func updateRaceGroup(_ recordMinId: Int64, version: Int64, raceGroupList: NSArray) {
        do {
            UserDefaults.standard.set(NSNumber(value: version as Int64), forKey: UserDefaultParam.RACE_GROUP_VERSION)
            UserDefaults.standard.set(NSNumber(value: recordMinId as Int64), forKey: UserDefaultParam.RACE_GROUP_RECORD_MIN_ID)
            UserDefaults.standard.synchronize()
            
            for raceGroupItem in raceGroupList {
                let raceGroupInfo = raceGroupItem as! RaceGroup
                
                let count = try database.run(raceGroupTable.filter(recordId == raceGroupInfo.recordId)
                    .update(
                        photoUrl <- raceGroupInfo.photoUrl,
                        smallPhotoUrl <- raceGroupInfo.smallPhotoUrl,
                        remark <- raceGroupInfo.remark,
                        nickname <- raceGroupInfo.nickname,
                        time <- raceGroupInfo.recordItem.time,
                        goalType <- raceGroupInfo.recordItem.goalType.rawValue,
                        score <- raceGroupInfo.recordItem.score,
                        scoreSum <- raceGroupInfo.recordItem.scoreSum,
                        pullVersion <- raceGroupInfo.recordItem.version,
                        showTypeName <- raceGroupInfo.recordItem.showTypeName))
                
                if count == 0 {
                    let insert = raceGroupTable.insert(
                        photoUrl <- raceGroupInfo.photoUrl,
                        smallPhotoUrl <- raceGroupInfo.smallPhotoUrl,
                        remark <- raceGroupInfo.remark,
                        nickname <- raceGroupInfo.nickname,
                        time <- raceGroupInfo.recordItem.time,
                        goalType <- raceGroupInfo.recordItem.goalType.rawValue,
                        score <- raceGroupInfo.recordItem.score,
                        scoreSum <- raceGroupInfo.recordItem.scoreSum,
                        pullVersion <- raceGroupInfo.recordItem.version,
                        showTypeName <- raceGroupInfo.recordItem.showTypeName,
                        recordId <- raceGroupInfo.recordId)
                    
                    try database.run(insert)
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table race_group!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func getMoreRaceGroup(_ count: Int, version: Int64, hasLoaded: Bool)-> NSMutableArray {
        let raceGroupList = NSMutableArray()
        
        do {
            let result = raceGroupTable.filter(pullVersion <= version && recordId < _recordMinId)
                .order(recordId.desc).limit(count)
            
            if(try database.scalar(result.count) == count || hasLoaded) {
                for item in try database.prepare(result) {
                    raceGroupList.add(RaceGroup(
                        recordId: item[recordId],
                        nickname: item[nickname],
                        photoUrl: item[photoUrl],
                        smallPhotoUrl: item[smallPhotoUrl],
                        remark: item[remark],
                        recordItem: RecordItem(recordId: item[recordId],
                            time: item[time],
                            goalType: Goal.GoalTypeEnum(rawValue: item[goalType])!,
                            score: item[score],
                            scoreSum: item[scoreSum],
                            version: item[pullVersion],
                            showTypeName: item[showTypeName])))
                    
                    if _recordMinId == 0 || _recordMinId > item[recordId] {
                        _recordMinId = item[recordId]
                    }
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table race_group!")
            print("Error - \(error.localizedDescription)")
        }
        
        return raceGroupList
    }
    
    func clearMoreData() {
        do {
            let result = raceGroupTable.order(recordId.desc).limit(20)
            
            if try database.scalar(result.count) > 0 {
                var minRecordId: Int64 = 0
                for item in try database.prepare(result) {
                    minRecordId = item[recordId]
                }
                
                if minRecordId > _recordMinId {
                    _recordMinId = minRecordId
                }
                
                UserDefaults.standard.set(NSNumber(value: recordMinId as Int64), forKey: UserDefaultParam.RACE_GROUP_RECORD_MIN_ID)
                UserDefaults.standard.synchronize()
                
                let deleteResult = raceGroupTable.filter(recordId < minRecordId)
                try database.run(deleteResult.delete())
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to clear table race_group!")
            print("Error - \(error.localizedDescription)")
        }
    }
    
    func clear() {
        do {
            let sqlStr = "delete from race_group; " +
            "update sqlite_sequence SET seq = 0 where name ='race_group'"
            try database.execute(sqlStr)
            self._recordMinId = 0
        }
        catch let error as NSError {
            print("SQLiteDB - failed to truncate table race_group!")
            print("Error - \(error.localizedDescription)")
        }
    }
}
