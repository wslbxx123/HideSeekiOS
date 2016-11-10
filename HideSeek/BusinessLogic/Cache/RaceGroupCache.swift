//
//  RaceGroupCache.swift
//  HideSeek
//
//  Created by apple on 7/4/16.
//  Copyright © 2016 mj. All rights reserved.
//

class RaceGroupCache : BaseCache<RaceGroup> {
    static let instance = RaceGroupCache()
    var raceGroupTableManager: RaceGroupTableManager!
    var version: Int64 = 0
    
    var raceGroupList: NSMutableArray {
        if(super.cacheList.count == 0) {
            super.cacheList = raceGroupTableManager.searchRaceGroup()
        }
        
        return super.cacheList
    }
    
    fileprivate override init() {
        super.init()
        raceGroupTableManager = RaceGroupTableManager.instance
    }
    
    func getMoreRaceGroup(_ count: Int, hasLoaded: Bool) -> Bool {
        let raceGroupList = raceGroupTableManager.getMoreRaceGroup(count, version: version, hasLoaded: hasLoaded)
        
        self.cacheList.addObjects(from: raceGroupList as [AnyObject])
        return raceGroupList.count > 0
    }
    
    func setRaceGroup(_ raceGroupInfo: NSDictionary!) {
        saveRaceGroup(raceGroupInfo)
        
        cacheList = raceGroupTableManager.searchRaceGroup()
        version = raceGroupTableManager.version
    }
    
    func saveRaceGroup(_ result: NSDictionary!) {
        let list = NSMutableArray()
        let temp_version = result["version"] as? NSString
        var version: Int64
        if(temp_version == nil) {
            version = raceGroupTableManager.version
        } else {
            version = (temp_version?.longLongValue)!
        }
        let recordMinId = (result["record_min_id"] as! NSString).longLongValue
        let raceGroupArray = result["race_group"] as! NSArray
        
        for raceGroup in raceGroupArray {
            let raceGroupInfo = raceGroup as! NSDictionary
            let recordIdStr = raceGroupInfo["pk_id"] as! NSString
            list.add(RaceGroup(recordId: recordIdStr.longLongValue,
                nickname: raceGroupInfo["nickname"] as! String,
                photoUrl: raceGroupInfo["photo_url"] as? String,
                smallPhotoUrl: raceGroupInfo["small_photo_url"] as? String,
                remark: raceGroupInfo["remark"] as? String,
                recordItem: RecordItem(
                    recordId: recordIdStr.longLongValue,
                    time: raceGroupInfo["time"] as! String,
                    goalType: Goal.GoalTypeEnum(rawValue: BaseInfoUtil.getIntegerFromAnyObject(raceGroupInfo["goal_type"]))!,
                    score: BaseInfoUtil.getIntegerFromAnyObject(raceGroupInfo["score"]),
                    scoreSum: BaseInfoUtil.getIntegerFromAnyObject(raceGroupInfo["score_sum"]),
                    version: (raceGroupInfo["version"] as! NSString).longLongValue,
                    showTypeName: raceGroupInfo["show_type_name"] as? String)))
        }
        
        raceGroupTableManager.updateRaceGroup(recordMinId, version: version, raceGroupList: list)
    }
    
    func addRaceGroup(_ result: NSDictionary!) {
        saveRaceGroup(result)
        
        getMoreRaceGroup(10, hasLoaded: true)
    }
}
