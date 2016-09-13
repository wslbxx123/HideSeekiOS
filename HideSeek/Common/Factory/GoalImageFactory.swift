//
//  GoalImageFactory.swift
//  HideSeek
//
//  Created by apple on 8/18/16.
//  Copyright © 2016 mj. All rights reserved.
//

class GoalImageFactory {
    class func get(goalType: Goal.GoalTypeEnum, showTypeName: String?) -> String {
        switch goalType {
        case .reward:
            return "reward_exchange"
        case .mushroom:
            return "mushroom"
        case .bomb:
            return "bomb"
        case .monster:
            return showTypeName!
        }
    }
}
