//
//  GoalCache.swift
//  HideSeek
//
//  Created by apple on 7/15/16.
//  Copyright © 2016 mj. All rights reserved.
//

class GoalCache : BaseCache<Goal> {
    static let instance = GoalCache()
    var updateTime: String!
    var updateList = NSMutableArray()
    var ifNeedClearMap = true
    
    var closestGoal: Goal!
    var _selectedGoal: Goal!
    var selectedGoal: Goal? {
        get {
            if _selectedGoal == nil && closestGoal != nil {
                closestGoal.isSelected = true
                return closestGoal
            }
            
            return _selectedGoal
        } set {
            _selectedGoal = newValue
        }
    }
    
    func setGoals(goalInfo: NSDictionary!, latitude: Double, longitude: Double) {
        updateList.removeAllObjects()
        saveGoals(goalInfo)
        
        refreshClosestGoal(latitude, longitude: longitude)
        ifNeedClearMap = false
    }
    
    func saveGoals(result: NSDictionary!) {
        let goalArray = result["goals"] as! NSArray
        
        for goalItem in goalArray {
            let goalInfo = goalItem as! NSDictionary
            let goal = Goal(pkId: (goalInfo["pk_id"] as! NSString).longLongValue,
                            latitude: (goalInfo["latitude"] as! NSString).doubleValue,
                            longitude: (goalInfo["longitude"] as! NSString).doubleValue,
                            orientation: (goalInfo["orientation"] as! NSString).integerValue,
                            valid: (goalInfo["valid"] as! NSString).integerValue == 1,
                            type: Goal.GoalTypeEnum(rawValue: (goalInfo["type"] as! NSString).integerValue)!,
                            isEnabled: (goalInfo["is_enabled"] as! NSString).integerValue == 1,
                            showTypeName: goalInfo["show_type_name"] as? String)
            updateList.addObject(goal)
            if(goal.valid) {
                cacheList.addObject(goal)
            }
        }
        
        updateTime = result["update_time"] as! String
    }
    
    func refreshClosestGoal(latitude: Double, longitude: Double) {
        if cacheList.count > 0 {
            let array = cacheList.sort{pow(($0 as! Goal).latitude - latitude, 2)
                + pow(($0 as! Goal).longitude - longitude, 2)
                < pow(($1 as! Goal).latitude - latitude, 2)
                + pow(($1 as! Goal).latitude - latitude, 2)}
            cacheList = (array as NSArray).mutableCopy() as! NSMutableArray
            
            repeat {
                closestGoal = cacheList[0] as! Goal
                
                if !closestGoal.valid {
                    cacheList.removeObjectAtIndex(0)
                }
                
            } while(!closestGoal.valid && cacheList.count > 0)
        }
    }
}
