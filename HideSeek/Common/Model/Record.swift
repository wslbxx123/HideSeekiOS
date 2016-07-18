//
//  Record.swift
//  HideSeek
//
//  Created by apple on 7/8/16.
//  Copyright © 2016 mj. All rights reserved.
//

class Record {
    var date: String!
    var recordItems: NSArray!
    
    init(date: String, recordItems: NSArray) {
        self.date = date
        self.recordItems = recordItems
    }
}
