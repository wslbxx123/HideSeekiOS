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
    
    private init() {
        do {
            let fileManager = NSFileManager.defaultManager()
            let docDir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
            let path = (docDir as NSString).stringByAppendingPathComponent(DatabaseParam.HIDE_SEEK_DATABASE)
            
            if !(fileManager.fileExistsAtPath(path)) {
                let assetPath = (NSBundle.mainBundle().resourcePath! as NSString).stringByAppendingPathComponent(ASSETS_NAME)
                
                try fileManager.copyItemAtPath(assetPath, toPath: path)
            }
            
            database = try Connection(path)
        } catch let error as NSError {
            print("SQLiteDB - failed to copy writable version of DB!")
            print("Error - \(error.localizedDescription)")
            return
        }
    }
}
