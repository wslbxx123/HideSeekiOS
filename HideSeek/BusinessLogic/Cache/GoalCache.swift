//
//  GoalCache.swift
//  HideSeek
//
//  Created by apple on 7/15/16.
//  Copyright © 2016 mj. All rights reserved.
//

class GoalCache : BaseCache<Goal> {
    static let instance = GoalCache()
    var version: Int64 = 0
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
                            showTypeName: goalInfo["show_type_name"] as? String,
                            createBy: (goalInfo["create_by"] as! NSString).longLongValue,
                            introduction: goalInfo["introduction"] as? String,
                            score: (goalInfo["create_by"] as! NSString).integerValue)
            updateList.addObject(goal)
            if(goal.valid) {
                cacheList.addObject(goal)
            }
        }
        
        version = (result["version"] as! NSString).longLongValue
    }
    
    func refreshClosestGoal(latitude: Double, longitude: Double) {
        var minDistance: Double = -1
        
        for item in cacheList {
            let goal = item as! Goal
            if(!goal.valid) {
                cacheList.removeObject(goal)
                continue
            }
            
            let distance = pow(goal.latitude - latitude, 2)
                + pow(goal.longitude - longitude, 2)
            
            if minDistance == -1 || minDistance > distance {
                minDistance = distance
                closestGoal = goal
            }
        }
    }
}
