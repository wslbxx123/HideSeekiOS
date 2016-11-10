//
//  DatabaseManager.swift
//  HideSeek
//
//  Created by apple on 7/5/16.
//  Copyright © 2016 mj. All rights reserved.
//
import UIKit
import SQLite

class DatabaseManager {
    static let instance = DatabaseManager()
    let ASSETS_NAME = "hideseek_cities.db"
    var database: Connection!
    
    fileprivate init() {
        do {
            let fileManager = FileManager.default
            let docDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
            let path = (docDir as NSString).appendingPathComponent(DatabaseParam.HIDE_SEEK_DATABASE)
            
            if !(fileManager.fileExists(atPath: path)) {
                let assetPath = (Bundle.main.resourcePath! as NSString).appendingPathComponent(ASSETS_NAME)
                
                try fileManager.copyItem(atPath: assetPath, toPath: path)
            }
            
            database = try Connection(path)
        } catch let error as NSError {
            print("SQLiteDB - failed to copy writable version of DB!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
}
