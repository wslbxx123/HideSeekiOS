//
//  RecordItem.swift
//  HideSeek
//
//  Created by apple on 7/4/16.
//  Copyright © 2016 mj. All rights reserved.
//

class RecordItem {
    var recordId: Int64
    var time: String
    var goalType: Goal.GoalTypeEnum
    var score: Int
    var scoreSum: Int
    var version: Int64
    
    init(recordId: Int64, time: String, goalType: Goal.GoalTypeEnum,
         score: Int, scoreSum: Int, version: Int64) {
        self.recordId = recordId
        self.time = time
        self.goalType = goalType
        self.score = score
        self.scoreSum = scoreSum
        self.version = version
    }
}
