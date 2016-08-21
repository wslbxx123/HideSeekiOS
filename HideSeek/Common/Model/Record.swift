//
//  Record.swift
//  HideSeek
//
//  Created by apple on 7/8/16.
//  Copyright © 2016 mj. All rights reserved.
//

class Record {
    var date: String!
    var recordId: Int64
    var time: String
    var goalType: Goal.GoalTypeEnum
    var score: Int
    var scoreSum: Int
    var version: Int64
    var showTypeName: String?
    
    init(date: String, recordId: Int64, time: String, goalType: Goal.GoalTypeEnum,
         score: Int, scoreSum: Int, version: Int64, showTypeName: String?) {
        self.date = date
        self.recordId = recordId
        self.time = time
        self.goalType = goalType
        self.score = score
        self.scoreSum = scoreSum
        self.version = version
        self.showTypeName = showTypeName
    }
}
