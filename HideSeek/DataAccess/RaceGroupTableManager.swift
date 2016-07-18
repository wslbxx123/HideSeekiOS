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
    let photoUrl = Expression<String>("photo_url")
    let nickname = Expression<String>("nickname")
    let time = Expression<String>("time")
    let goalType = Expression<Int>("goal_type")
    let score = Expression<Int>("score")
    let scoreSum = Expression<Int>("score_sum")
    let pullVersion = Expression<Int64>("version")
    
    var database: Connection!
    var raceGroupTable: Table!
    var recordMinId: Int64 = 0
    
    var version: Int64 {
        get{
            let tempVersion = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.RACE_GROUP_VERSION) as? NSNumber
            
            if(tempVersion == nil) {
                return 0
            }
            return (tempVersion?.longLongValue)!
        }
    }
    
    private init() {
        do {
            database = DatabaseManager.instance.database
            
            raceGroupTable = Table("race_group")
            
            try database.run(raceGroupTable.create(ifNotExists: true) { t in
                t.column(recordId, primaryKey: true)
                t.column(photoUrl)
                t.column(nickname)
                t.column(time)
                t.column(goalType)
                t.column(score)
                t.column(scoreSum)
                t.column(pullVersion)
                })
        } catch let error as NSError {
            print("SQLiteDB - failed to create table race_group!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func searchRaceGroup() -> NSMutableArray {
        let raceGroupList = NSMutableArray()
        do {
            var result: Table
            if recordMinId == 0 {
                result = raceGroupTable.order(recordId.desc).limit(10)
            } else {
                result = raceGroupTable.filter(recordId >= recordMinId).order(recordId.desc)
            }
            
            for item in try database.prepare(result) {
                raceGroupList.addObject(RaceGroup(
                    recordId: item[recordId], nickname: item[nickname], photoUrl: item[photoUrl], recordItem: RecordItem(recordId: item[recordId], time: item[time],
                        goalType: Goal.GoalTypeEnum(rawValue: item[goalType])!,
                        score: item[score], scoreSum: item[scoreSum], version: item[pullVersion])))
                
                if recordMinId == 0 || recordMinId > item[recordId] {
                    recordMinId = item[recordId]
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table race_group!")
            print("Error - \(error.localizedDescription)")
        }
        
        return raceGroupList
    }
    
    func updateRaceGroup(recordMinId: Int64, version: Int64, raceGroupList: NSArray) {
        do {
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(longLong:version), forKey: UserDefaultParam.RACE_GROUP_VERSION)
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(longLong:recordMinId), forKey: UserDefaultParam.RACE_GROUP_RECORD_MIN_ID)
            
            for raceGroupItem in raceGroupList {
                let raceGroupInfo = raceGroupItem as! RaceGroup
                
                let count = try database.run(raceGroupTable.filter(recordId == raceGroupInfo.recordId)
                    .update(
                        photoUrl <- raceGroupInfo.photoUrl,
                        nickname <- raceGroupInfo.nickname,
                        time <- raceGroupInfo.recordItem.time,
                        goalType <- raceGroupInfo.recordItem.goalType.rawValue,
                        score <- raceGroupInfo.recordItem.score,
                        scoreSum <- raceGroupInfo.recordItem.scoreSum,
                        pullVersion <- raceGroupInfo.recordItem.version))
                
                if count == 0 {
                    let insert = raceGroupTable.insert(
                        photoUrl <- raceGroupInfo.photoUrl,
                        nickname <- raceGroupInfo.nickname,
                        time <- raceGroupInfo.recordItem.time,
                        goalType <- raceGroupInfo.recordItem.goalType.rawValue,
                        score <- raceGroupInfo.recordItem.score,
                        scoreSum <- raceGroupInfo.recordItem.scoreSum,
                        pullVersion <- raceGroupInfo.recordItem.version,
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
    
    func getMoreRaceGroup(count: Int, version: Int64)-> NSMutableArray {
        let raceGroupList = NSMutableArray()
        
        do {
            let result = raceGroupTable.filter(pullVersion <= version && recordId < recordMinId)
                .order(recordId.desc).limit(count)
            
            if(database.scalar(result.count) == count) {
                for item in try database.prepare(result) {
                    raceGroupList.addObject(RaceGroup(
                        recordId: item[recordId], nickname: item[nickname], photoUrl: item[photoUrl], recordItem: RecordItem(recordId: item[recordId], time: item[time],
                            goalType: Goal.GoalTypeEnum(rawValue: item[goalType])!,
                            score: item[score], scoreSum: item[scoreSum], version: item[pullVersion])))
                    
                    if recordMinId == 0 || recordMinId > item[recordId] {
                        recordMinId = item[recordId]
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
}
