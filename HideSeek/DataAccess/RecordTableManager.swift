//
//  RecordTableManager.swift
//  HideSeek
//
//  Created by apple on 7/9/16.
//  Copyright © 2016 mj. All rights reserved.
//
import SQLite

class RecordTableManager {
    static let instance = RecordTableManager()
    
    let recordId = Expression<Int64>("record_id")
    let dateStr = Expression<String>("date_str")
    let time = Expression<String>("time")
    let goalType = Expression<Int>("goal_type")
    let score = Expression<Int>("score")
    let scoreSum = Expression<Int>("score_sum")
    let pullVersion = Expression<Int64>("version")
    let showTypeName = Expression<String?>("show_type_name")
    
    var database: Connection!
    var recordTable: Table!
    var _recordMinId: Int64! = 0

    var recordMinId: Int64 {
        get{
            let tempRecordMinId = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.RECORD_MIN_ID) as? NSNumber
            
            if(tempRecordMinId == nil) {
                return 0
            }
            return (tempRecordMinId?.longLongValue)!
        }
    }
    
    var version: Int64 {
        get{
            let tempVersion = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.RECORD_VERSION) as? NSNumber
            
            if(tempVersion == nil) {
                return 0
            }
            return (tempVersion?.longLongValue)!
        }
    }
    
    var scoreSumValue: Int {
        get {
            let tempScoreSum = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.SCORE_SUM) as? NSNumber
            
            if(tempScoreSum == nil) {
                return 0
            }
            return (tempScoreSum?.integerValue)!
        }
    }
    
    private init() {
        do {
            database = DatabaseManager.instance.database
            
            recordTable = Table("record")
            
            try database.run(recordTable.create(ifNotExists: true) { t in
                t.column(recordId, primaryKey: true)
                t.column(dateStr)
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
    
    func updateRecords(sum: Int, recordMinId: Int64, version: Int64,
                       recordList: NSArray) {
        do {
            NSUserDefaults.standardUserDefaults().setObject(sum, forKey: UserDefaultParam.SCORE_SUM)
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(longLong:version), forKey: UserDefaultParam.RECORD_VERSION)
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(longLong:recordMinId), forKey: UserDefaultParam.RECORD_MIN_ID)
            
            for record in recordList {
                let recordInfo = record as! Record
                
                let count = try database.run(recordTable.filter(recordId == recordInfo.recordId)
                    .update(
                        dateStr <- recordInfo.date,
                        time <- recordInfo.time,
                        goalType <- recordInfo.goalType.rawValue,
                        score <- recordInfo.score,
                        scoreSum <- recordInfo.scoreSum,
                        pullVersion <- recordInfo.version,
                        showTypeName <- recordInfo.showTypeName))
                
                if count == 0 {
                    let insert = recordTable.insert(
                        dateStr <- recordInfo.date,
                        time <- recordInfo.time,
                        goalType <- recordInfo.goalType.rawValue,
                        score <- recordInfo.score,
                        scoreSum <- recordInfo.scoreSum,
                        pullVersion <- recordInfo.version,
                        showTypeName <- recordInfo.showTypeName,
                        recordId <- recordInfo.recordId)
                    
                    try database.run(insert)
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table record!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func searchRecords() -> NSMutableArray {
        let recordList = NSMutableArray()
        do {
            var result: Table
            if _recordMinId == 0 {
                result = recordTable.order(recordId.desc).limit(10)
            } else {
                result = recordTable.filter(recordId >= _recordMinId).order(recordId.desc)
            }
            
            for item in try database.prepare(result) {
                recordList.addObject(Record(date: item[dateStr],
                    recordId: item[recordId],
                    time: item[time],
                    goalType: Goal.GoalTypeEnum(rawValue: item[goalType])!,
                    score: item[score],
                    scoreSum: item[scoreSum],
                    version: item[pullVersion],
                    showTypeName: item[showTypeName]))
                
                if _recordMinId == 0 || _recordMinId > item[recordId] {
                    _recordMinId = item[recordId]
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table record!")
            print("Error - \(error.localizedDescription)")
        }
        
        return recordList
    }
    
    func getMoreRecords(count: Int, version: Int64, hasLoaded: Bool) -> NSMutableArray {
        let recordList = NSMutableArray()
        do {
            let result = recordTable.filter(pullVersion <= version && recordId < _recordMinId).order(recordId.desc).limit(count)
            
            let resultCount = database.scalar(result.count)
            
            if resultCount == count || hasLoaded {
                for item in try database.prepare(result) {
                    recordList.addObject(Record(date: item[dateStr],
                        recordId: item[recordId],
                        time: item[time],
                        goalType: Goal.GoalTypeEnum(rawValue: item[goalType])!,
                        score: item[score],
                        scoreSum: item[scoreSum],
                        version: item[pullVersion],
                        showTypeName: item[showTypeName]))
                    
                    if _recordMinId == 0 || _recordMinId > item[recordId] {
                        _recordMinId = item[recordId]
                    }
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table record!")
            print("Error - \(error.localizedDescription)")
        }
        
        return recordList
    }
    
    func clear() {
        do {
            let sqlStr = "delete from record; " +
            "update sqlite_sequence SET seq = 0 where name ='record'"
            try database.execute(sqlStr)
        }
        catch let error as NSError {
            print("SQLiteDB - failed to truncate table record!")
            print("Error - \(error.localizedDescription)")
        }
    }
    
}
