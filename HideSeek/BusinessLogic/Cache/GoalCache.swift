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
    var ifNeedClearMap = false
    
    var closestGoal: Goal!
    var _selectedGoal: Goal!
    var selectedGoal: Goal? {
        get {
            if _selectedGoal == nil && closestGoal != nil {
                closestGoal.isSelected = true
                _selectedGoal = closestGoal
                return closestGoal
            }
            
            return _selectedGoal
        } set {
            _selectedGoal = newValue
        }
    }
    
    func setGoals(_ goalInfo: NSDictionary, latitude: Double, longitude: Double) {
        updateList.removeAllObjects()
        saveGoals(goalInfo)
        
        ifNeedClearMap = false
    }
    
    func getGoal(_ goalId: Int64) -> Goal?{
        for goalItem in cacheList {
            let goal = goalItem as! Goal
            
            if goal.pkId == goalId {
                return goal
            }
        }
        
        return nil
    }
    
    func saveGoals(_ result: NSDictionary!) {
        let goalArray = result["goals"] as! NSArray
        
        for goalItem in goalArray {
            let goalInfo = goalItem as! NSDictionary
            
            let goal = Goal(pkId: (goalInfo["pk_id"] as! NSString).longLongValue,
                            latitude: (goalInfo["latitude"] as! NSString).doubleValue,
                            longitude: (goalInfo["longitude"] as! NSString).doubleValue,
                            orientation: BaseInfoUtil.getIntegerFromAnyObject(goalInfo["orientation"]),
                            valid: BaseInfoUtil.getIntegerFromAnyObject(goalInfo["valid"]) == 1,
                            type: Goal.GoalTypeEnum(rawValue: BaseInfoUtil.getIntegerFromAnyObject(goalInfo["type"]))!,
                            showTypeName: goalInfo["show_type_name"] as? String,
                            createBy: (goalInfo["create_by"] as! NSString).longLongValue,
                            introduction: goalInfo["introduction"] as? String,
                            score: BaseInfoUtil.getIntegerFromAnyObject(goalInfo["score"]),
                            unionType: BaseInfoUtil.getIntegerFromAnyObject(goalInfo["union_type"]))
            updateList.add(goal)
            if(goal.valid) {
                cacheList.add(goal)
            }
            NSLog("cachelist count: \(cacheList.count)")
        }
        
        version = (result["version"] as! NSString).longLongValue
    }
    
    func refreshClosestGoal(_ latitude: Double, longitude: Double) {
        var minDistance: Double = -1
        NSLog("\(cacheList.count)")
        
        for item in cacheList {
            let goal = item as! Goal
            if(!goal.valid) {
                NSLog("goalId = \(goal.pkId)")
                cacheList.remove(goal)
                NSLog("\(cacheList.count)")
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
    
    func reset() {
        if _selectedGoal != nil {
            _selectedGoal.isSelected = false
            _selectedGoal = nil
        }
        closestGoal = nil
        cacheList.removeAllObjects()
        NSLog("cachelist count: \(cacheList.count)")
        version = 0
    }
}
