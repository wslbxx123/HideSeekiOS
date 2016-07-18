//
//  RecordCache.swift
//  HideSeek
//
//  Created by apple on 7/8/16.
//  Copyright © 2016 mj. All rights reserved.
//

class RecordCache : BaseCache<Record> {
    static let instance = RecordCache()
    var recordTableManager: RecordTableManager!
    let dateTimeFormatter = NSDateFormatter()
    let timeFormatter = NSDateFormatter()
    let dateFormatter = NSDateFormatter()
    var version: Int64 = 0
    private var _scoreSum: Int = 0
    var scoreSum: Int {
        get{
            if(_scoreSum > 0) {
                return _scoreSum;
            }
            
            return recordTableManager.scoreSumValue
        }
    }
    
    private override init() {
        super.init()
        recordTableManager = RecordTableManager.instance
        dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        timeFormatter.dateFormat = "HH:mm"
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    func setRecords(recordInfo: NSDictionary!) {
        saveRecords(recordInfo)
        
        cacheList = recordTableManager.searchRecords()
        version = recordTableManager.version
    }
    
    func saveRecords(result: NSDictionary!) {
        var currentDate: String!
        let list = NSMutableArray()
        let recordItems = NSMutableArray()
        let tempVersion = result["version"] as? NSString
        var version: Int64
        if(tempVersion == nil) {
            version = recordTableManager.version
        } else {
            version = (tempVersion?.longLongValue)!
        }
        let recordMinId = (result["record_min_id"] as! NSString).longLongValue
        
        let tempScoreSum = result["score_sum"] as? NSString
        
        if(tempScoreSum != nil) {
            _scoreSum = tempScoreSum!.integerValue
        }
        
        let recordArray = result["scores"] as! NSArray
        var index: Int = 0
        
        for record in recordArray{
            let recordInfo = record as! NSDictionary
            let time = recordInfo["time"] as! String
            let date = dateTimeFormatter.dateFromString(time)
            let dateStr = dateFormatter.stringFromDate(date!)
            
            if index == recordArray.count - 1 {
                recordItems.addObject(RecordItem(
                    recordId: (recordInfo["pk_id"] as! NSString).longLongValue,
                    time: timeFormatter.stringFromDate(date!),
                    goalType: Goal.GoalTypeEnum(rawValue: (recordInfo["goal_type"] as! NSString).integerValue)!,
                    score: (recordInfo["score"] as! NSString).integerValue,
                    scoreSum: (recordInfo["score_sum"] as! NSString).integerValue,
                    version: (recordInfo["version"] as! NSString).longLongValue))
                
                currentDate = dateStr
                list.addObject(Record(date: currentDate, recordItems: recordItems.copy() as! NSArray))
                recordItems.removeAllObjects()
            } else if currentDate != nil && dateStr != currentDate {
                list.addObject(Record(date: currentDate, recordItems: recordItems.copy() as! NSArray))
                recordItems.removeAllObjects()
                
                recordItems.addObject(RecordItem(
                    recordId: (recordInfo["pk_id"] as! NSString).longLongValue,
                    time: timeFormatter.stringFromDate(date!),
                    goalType: Goal.GoalTypeEnum(rawValue: (recordInfo["goal_type"] as! NSString).integerValue)!,
                    score: (recordInfo["score"] as! NSString).integerValue,
                    scoreSum: (recordInfo["score_sum"] as! NSString).integerValue,
                    version: (recordInfo["version"] as! NSString).longLongValue))
            } else {
                recordItems.addObject(RecordItem(
                    recordId: (recordInfo["pk_id"] as! NSString).longLongValue,
                    time: timeFormatter.stringFromDate(date!),
                    goalType: Goal.GoalTypeEnum(rawValue: (recordInfo["goal_type"] as! NSString).integerValue)!,
                    score: (recordInfo["score"] as! NSString).integerValue,
                    scoreSum: (recordInfo["score_sum"] as! NSString).integerValue,
                    version: (recordInfo["version"] as! NSString).longLongValue))
            }
            
            currentDate = dateStr
            index += 1
        }
        
        recordTableManager.updateRecords(scoreSum, recordMinId: recordMinId, version: version, recordList: list)
    }
    
    func getMoreRecord(count: Int) -> NSArray{
        let recordList = recordTableManager.getMoreRecords(count, version: version)
        
        if recordList.count > 0 {
            let lastRecord = cacheList[cacheList.count - 1] as! Record
            let firstRecord = cacheList[0] as! Record
            if lastRecord.date == firstRecord.date {
                lastRecord.recordItems.arrayByAddingObjectsFromArray(firstRecord.recordItems as [AnyObject])
                recordList.removeObject(firstRecord)
            }
        }
        
        return recordList
    }
}
