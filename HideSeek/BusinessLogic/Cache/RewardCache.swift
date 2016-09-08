//
//  RewardCache.swift
//  HideSeek
//
//  Created by apple on 8/2/16.
//  Copyright © 2016 mj. All rights reserved.
//

class RewardCache : BaseCache<Reward> {
    static let instance = RewardCache()
    var rewardTableManager: RewardTableManager!
    var version: Int64 = 0
    
    var rewardList: NSMutableArray {
        get {
            if(super.cacheList.count == 0) {
                super.cacheList = rewardTableManager.searchRewards()
            }
            
            return super.cacheList
        }
    }
    
    private override init() {
        super.init()
        rewardTableManager = RewardTableManager.instance
    }
    
    func setRewards(result: NSDictionary!) {
        saveRewards(result)
        
        cacheList = rewardTableManager.searchRewards()
        version = rewardTableManager.version
    }
    
    func addRewards(result: NSDictionary!) {
        saveRewards(result)
        
        getMoreRewards(10, hasLoaded: true)
    }
    
    func saveRewards(result: NSDictionary!) {
        let list = NSMutableArray()
        let tempVersion = result["version"] as? NSString
        var version: Int64
        if(tempVersion == nil) {
            version = rewardTableManager.version
        } else {
            version = (tempVersion?.longLongValue)!
        }
        let rewardMinId = (result["reward_min_id"] as! NSString).longLongValue
        
        let rewardArray = result["reward"] as! NSArray
        
        for reward in rewardArray {
            let rewardInfo = reward as! NSDictionary
            list.addObject(Reward(pkId: (rewardInfo["pk_id"] as! NSString).longLongValue,
                name: rewardInfo["reward_name"] as! String,
                imageUrl: rewardInfo["reward_image_url"] as? String,
                record: (rewardInfo["record"] as! NSString).integerValue,
                exchangeCount: (rewardInfo["exchange_count"] as! NSString).integerValue,
                introduction: rewardInfo["introduction"] as? String,
                version: (rewardInfo["version"] as! NSString).longLongValue))
        }
        
        rewardTableManager.updateRewards(rewardMinId, version: version, rewardList: list)
    }
    
    func getMoreRewards(count: Int, hasLoaded: Bool) -> Bool {
        let rewardList = rewardTableManager.getMoreRewards(count, version: version, hasLoaded: hasLoaded)
        
        self.cacheList.addObjectsFromArray(rewardList as [AnyObject])
        
        return rewardList.count > 0
    }
}
