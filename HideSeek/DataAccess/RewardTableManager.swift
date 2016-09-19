//
//  RewardTableManager.swift
//  HideSeek
//
//  Created by apple on 8/2/16.
//  Copyright © 2016 mj. All rights reserved.
//

import SQLite

class RewardTableManager {
    static let instance = RewardTableManager()
    
    let rewardId = Expression<Int64>("reward_id")
    let name = Expression<String>("name")
    let imageUrl = Expression<String?>("image_url")
    let record = Expression<Int>("record")
    let exchangeCount = Expression<Int>("exchange_count")
    let introduction = Expression<String?>("introduction")
    let pullVersion = Expression<Int64>("version")
    
    var database: Connection!
    var rewardTable: Table!
    private var _rewardMinId: Int64 = 0
    
    var rewardMinId: Int64 {
        let tempRewardMinId = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.REWARD_MIN_ID) as? NSNumber
        
        if(tempRewardMinId == nil) {
            return 0
        }
        return (tempRewardMinId?.longLongValue)!
    }
    
    var version: Int64 {
        get{
            let tempVersion = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.REWARD_VERSION) as? NSNumber
            
            if(tempVersion == nil) {
                return 0
            }
            return (tempVersion?.longLongValue)!
        }
    }
    
    private init() {
        do {
            database = DatabaseManager.instance.database
            
            rewardTable = Table("reward")
            
            try database.run(rewardTable.create(ifNotExists: true) { t in
                t.column(rewardId, primaryKey: true)
                t.column(name)
                t.column(imageUrl)
                t.column(record)
                t.column(exchangeCount)
                t.column(introduction)
                t.column(pullVersion)
                })
        } catch let error as NSError {
            print("SQLiteDB - failed to create table product!")
            print("Error - \(error.localizedDescription)")
            return
        }
        
    }
    
    func searchRewards() -> NSMutableArray {
        let productList = NSMutableArray()
        
        do {
            var result: Table
            if _rewardMinId == 0 {
                result = rewardTable.order(rewardId.desc).limit(10)
            } else {
                result = rewardTable.filter(rewardId >= _rewardMinId).order(rewardId.desc)
            }
            
            for item in try database.prepare(result) {
                productList.addObject(Reward(
                    pkId: item[rewardId],
                    name: item[name],
                    imageUrl: item[imageUrl],
                    record: item[record],
                    exchangeCount: item[exchangeCount],
                    introduction: item[introduction],
                    version: item[pullVersion]))
                
                if _rewardMinId == 0 || _rewardMinId > item[rewardId] {
                    self._rewardMinId = item[rewardId]
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table race_group!")
            print("Error - \(error.localizedDescription)")
        }
        
        return productList
    }
    
    func updateRewards(rewardMinId: Int64, version: Int64, rewardList: NSArray) {
        do {
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(longLong:version), forKey: UserDefaultParam.REWARD_VERSION)
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(longLong:rewardMinId), forKey: UserDefaultParam.REWARD_MIN_ID)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            for rewardItem in rewardList {
                let rewardInfo = rewardItem as! Reward
                
                let count = try database.run(rewardTable.filter(rewardId == rewardInfo.pkId)
                    .update(
                        name <- rewardInfo.name,
                        imageUrl <- rewardInfo.imageUrl,
                        record <- rewardInfo.record,
                        exchangeCount <- rewardInfo.exchangeCount,
                        introduction <- rewardInfo.introduction,
                        pullVersion <- rewardInfo.version))
                
                if count == 0 {
                    let insert = rewardTable.insert(
                        name <- rewardInfo.name,
                        imageUrl <- rewardInfo.imageUrl,
                        record <- rewardInfo.record,
                        exchangeCount <- rewardInfo.exchangeCount,
                        introduction <- rewardInfo.introduction,
                        pullVersion <- rewardInfo.version,
                        rewardId <- rewardInfo.pkId)
                    
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
    
    func getMoreRewards(count: Int, version: Int64, hasLoaded: Bool) -> NSMutableArray {
        let rewardList = NSMutableArray()
        do {
            let result = rewardTable.filter(pullVersion <= version && rewardId < _rewardMinId).order(rewardId.desc).limit(count)
            
            let resultCount = database.scalar(result.count)
            
            if resultCount == count || hasLoaded {
                for item in try database.prepare(result) {
                    rewardList.addObject(Reward(pkId: item[rewardId],
                        name: item[name],
                        imageUrl: item[imageUrl],
                        record: item[record],
                        exchangeCount: item[exchangeCount],
                        introduction: item[introduction],
                        version: item[pullVersion]))
                    
                    if _rewardMinId == 0 || _rewardMinId > item[rewardId] {
                        _rewardMinId = item[rewardId]
                    }
                }
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table record!")
            print("Error - \(error.localizedDescription)")
        }
        
        return rewardList
    }
    
    func clear() {
        do {
            let sqlStr = "delete from product; " +
            "update sqlite_sequence SET seq = 0 where name ='product'"
            try database.execute(sqlStr)
        }
        catch let error as NSError {
            print("SQLiteDB - failed to truncate table product!")
            print("Error - \(error.localizedDescription)")
        }
    }
}
