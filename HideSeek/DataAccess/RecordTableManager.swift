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
    
    var database: Connection!
    var recordTable: Table!

    var recordMinId: Int64 {
        get{
            let tempRecordMinId = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.RACE_GROUP_RECORD_MIN_ID) as? NSNumber
            
            if(tempRecordMinId == nil) {
                return 0
            }
            return (tempRecordMinId?.longLongValue)!
        }
    }
    
    var version: Int64 {
        get{
            let tempVersion = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.RACE_GROUP_VERSION) as? NSNumber
            
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
                
                for recordItem in recordInfo.recordItems {
                    let recordItemInfo = recordItem as! RecordItem
                    
                    let count = try database.run(recordTable.filter(recordId == recordItemInfo.recordId)
                        .update(
                            dateStr <- recordInfo.date,
                            time <- recordItemInfo.time,
                            goalType <- recordItemInfo.goalType.rawValue,
                            score <- recordItemInfo.score,
                            scoreSum <- recordItemInfo.scoreSum,
                            pullVersion <- recordItemInfo.version))
                    
                    if count == 0 {
                        let insert = recordTable.insert(
                            dateStr <- recordInfo.date,
                            time <- recordItemInfo.time,
                            goalType <- recordItemInfo.goalType.rawValue,
                            score <- recordItemInfo.score,
                            scoreSum <- recordItemInfo.scoreSum,
                            pullVersion <- recordItemInfo.version,
                            recordId <- recordItemInfo.recordId)
                        
                        try database.run(insert)
                    }
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table race_group!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func searchRecords() -> NSMutableArray {
        var recordList = NSMutableArray()
        do {
            var result: Table
            if recordMinId == 0 {
                result = recordTable.order(recordId.desc).limit(10)
            } else {
                result = recordTable.filter(recordId >= recordMinId).order(recordId.desc)
            }
            
            let count = database.scalar(result.count)
            
            recordList = getRecordList(try database.prepare(result), count: count)
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table race_group!")
            print("Error - \(error.localizedDescription)")
        }
        
        return recordList
    }
    
    func getMoreRecords(count: Int, version: Int64) -> NSMutableArray {
        var recordList = NSMutableArray()
        do {
            let result = recordTable.filter(pullVersion <= version && recordId < recordMinId).order(recordId.desc).limit(count)
            
            let count = database.scalar(result.count)
            
            recordList = getRecordList(try database.prepare(result), count: count)
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table race_group!")
            print("Error - \(error.localizedDescription)")
        }
        
        return recordList
    }
    
    func getRecordList(sequence: AnySequence<Row>, count: Int) -> NSMutableArray {
        let recordList = NSMutableArray()
        let recordItems = NSMutableArray()
        var currentDate: String!
        
        var i : Int = 0
        
        for item in sequence {
            let date = item[dateStr]
            
            if(i == count - 1) {
                recordItems.addObject(RecordItem(
                    recordId: item[recordId],
                    time: item[time],
                    goalType: Goal.GoalTypeEnum(rawValue: item[goalType])!,
                    score: item[score],
                    scoreSum: item[scoreSum],
                    version: item[pullVersion]
                ))
                
                currentDate = date
                recordList.addObject(Record(date: currentDate, recordItems: recordItems.copy() as! NSArray))
                recordItems.removeAllObjects()
            } else if(currentDate != nil && date != currentDate) {
                recordList.addObject(Record(date: currentDate, recordItems: recordItems.copy() as! NSArray))
                recordItems.removeAllObjects()
                
                recordItems.addObject(RecordItem(
                    recordId: item[recordId],
                    time: item[time],
                    goalType: Goal.GoalTypeEnum(rawValue: item[goalType])!,
                    score: item[score],
                    scoreSum: item[scoreSum], version: item[pullVersion]
                    ))

            } else {
                recordItems.addObject(RecordItem(
                    recordId: item[recordId],
                    time: item[time],
                    goalType: Goal.GoalTypeEnum(rawValue: item[goalType])!,
                    score: item[score],
                    scoreSum: item[scoreSum], version: item[pullVersion]
                    ))
            }
            
            currentDate = date
            i += 1
        }
        
        return recordList
    }
}
