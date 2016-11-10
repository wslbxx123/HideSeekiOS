//
//  ForeignCityTableManager.swift
//  HideSeek
//
//  Created by apple on 7/29/16.
//  Copyright © 2016 mj. All rights reserved.
//

import SQLite

class ForeignCityTableManager {
    static let instance = ForeignCityTableManager()
    
    var database: Connection!
    var foreignCityTable: Table!
    
    let name = Expression<String>("name")
    let country = Expression<String>("country")
    
    fileprivate init() {
        database = DatabaseManager.instance.database
        
        foreignCityTable = Table("foreign_city")
    }
    
    func getAllCities() -> NSMutableArray {
        let cityList = NSMutableArray()
        
        do {
            let result = foreignCityTable.order(name)
            
            for item in try database.prepare(result) {
                cityList.add(ForeignCity(name: item[name], country: item[country]))
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table foreign_city!")
            print("Error - \(error.localizedDescription)")
        }
        
        return cityList
    }
    
    func searchCities(_ keyword: String) -> NSMutableArray {
        let cityList = NSMutableArray()
        
        do {
            let result = foreignCityTable.filter(name.like("%\(keyword)%"))
                .order(name)
            
            for item in try database.prepare(result) {
                cityList.add(ForeignCity(name: item[name], country: item[country]))
            }
        }
        catch let error as NSError {
            print("SQLiteDB - failed to update table race_group!")
            print("Error - \(error.localizedDescription)")
        }
        
        return cityList
    }
}
