//
//  WarningCache.swift
//  HideSeek
//
//  Created by apple on 8/25/16.
//  Copyright © 2016 mj. All rights reserved.
//

class WarningCache : BaseCache<Warning> {
    static let instance = WarningCache()
    var serverTime: NSDate!
    var dateFormatter: NSDateFormatter!
    
    override init() {
        super.init()
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    func setWarnings(result: NSDictionary) {
        saveWarnings(result["warnings"] as! NSArray)
        
        serverTime = dateFormatter.dateFromString(result["server_time"] as! String)
    }
    
    func saveWarnings(warnings: NSArray) {
        let list = NSMutableArray()
        
        for warningItem in warnings {
            let warningInfo = warningItem as! NSDictionary
            let warning = Warning(goal: Goal(
                pkId: (warningInfo["pk_id"] as! NSString).longLongValue,
                latitude: (warningInfo["latitude"] as! NSString).doubleValue,
                longitude: (warningInfo["longitude"] as! NSString).doubleValue,
                orientation: (warningInfo["orientation"] as! NSString).integerValue,
                valid: (warningInfo["valid"] as! NSString).integerValue == 1,
                type: Goal.GoalTypeEnum(rawValue: (warningInfo["type"] as! NSString).integerValue)!,
                showTypeName: warningInfo["show_type_name"] as? String,
                createBy: (warningInfo["create_by"] as! NSString).longLongValue,
                introduction: warningInfo["introduction"] as? String,
                score: (warningInfo["score"] as! NSString).integerValue,
                unionType: (warningInfo["union_type"] as! NSString).integerValue),
                                  createTime: warningInfo["create_time"] as! String)
            
            list.addObject(warning)
        }
        
        cacheList = list
    }
}
