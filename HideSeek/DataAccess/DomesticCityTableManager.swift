//
//  DomesticCityTableManager.swift
//  HideSeek
//
//  Created by apple on 7/28/16.
//  Copyright © 2016 mj. All rights reserved.
//

import SQLite

class DomesticCityTableManager {
    static let instance = DomesticCityTableManager()
    
    let id = Expression<Int>("id")
    let name = Expression<String>("name")
    let pinyin = Expression<String>("pinyin")
    let timestamp = Expression<Date>("timestamp")
    
    var database: Connection!
    var domesticCityTable: Table!
    var recentCityTable: Table!
    
    fileprivate init() {
        do {
            database = DatabaseManager.instance.database
            
            domesticCityTable = Table("domestic_city")
            recentCityTable = Table("recent_city")
            
            try database.run(recentCityTable.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(pinyin)
                t.column(timestamp, defaultValue: NSDate() as Date)
                })
        } catch let error as NSError {
            print("SQLiteDB - failed to create table race_group!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func getAllCities() -> NSMutableArray {
        let cityList = NSMutableArray()
        
        do {
            let result = domesticCityTable.order(pinyin)
            
            for item in try database.prepare(result) {
                cityList.add(DomesticCity(name: item[name], pinYin: item[pinyin]))
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table race_group!")
            print("Error - \(error.localizedDescription)")
        }
        
        return cityList
    }
    
    func insertRecentCity(_ city: DomesticCity) {
        do {
            let count = try database.run(recentCityTable.filter(name == city.name)
                .update(
                    pinyin <- city.pinYin,
                    timestamp <- Date()))
            
            if count == 0 {
                let insert = recentCityTable.insert(
                    name <- city.name,
                    pinyin <- city.pinYin,
                    timestamp <- Date())
                
                try database.run(insert)
            }
            
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table race_group!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
    
    func getRecentCities() -> NSMutableArray {
        let cityList = NSMutableArray()
        
        do {
            let result = recentCityTable.order(timestamp.desc).limit(3)
            
            for item in try database.prepare(result) {
                cityList.add(DomesticCity(name: item[name], pinYin: item[pinyin]))
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table race_group!")
            print("Error - \(error.localizedDescription)")
        }
        
        return cityList
    }
    
    func searchCities(_ keyword: String) -> NSMutableArray {
        let cityList = NSMutableArray()
        
        do {
            let result = domesticCityTable.filter(name.like("%\(keyword)%") || pinyin.like("%\(keyword)%"))
                .order(pinyin)
            
            for item in try database.prepare(result) {
                cityList.add(DomesticCity(name: item[name], pinYin: item[pinyin]))
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table race_group!")
            print("Error - \(error.localizedDescription)")
        }
        
        return cityList
    }
}
