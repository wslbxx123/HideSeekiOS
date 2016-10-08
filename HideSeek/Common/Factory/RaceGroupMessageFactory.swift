//
//  RaceGroupMessageFactory.swift
//  HideSeek
//
//  Created by apple on 9/19/16.
//  Copyright © 2016 mj. All rights reserved.
//

class RaceGroupMessageFactory {
    class func get(goalType: Goal.GoalTypeEnum, showTypeName: String?)-> String {
        switch(goalType) {
        case .mushroom:
            return NSLocalizedString("MESSAGE_GET_MUSHROOM", comment: "Throw a mushroom monster into sack easily, Rich bitch!")
        case .monster:
            return getMonsterMessage(showTypeName!)
        case .bomb:
            return NSLocalizedString("MESSAGE_GET_BOMB", comment: "Unfortunately detonated a crafty bomb monster, Give me a break!")
        default:
            return ""
        }
    }
    
    class func getMonsterMessage(showTypeName: String) -> String {
        switch(showTypeName) {
        case "egg":
            return NSLocalizedString("MESSAGE_GET_EGG", comment: "So excited! Beat an egg monster successfully")
        case "cow":
            return NSLocalizedString("MESSAGE_GET_COW", comment: "You are watched by a cow monster，how smart I am to beat it in time!")
        case "bird":
            return NSLocalizedString("MESSAGE_GET_BIRD", comment: "You are watched by a cow monster，how smart I am to beat it in time!")
        case "giraffe":
            return NSLocalizedString("MESSAGE_GET_GIRAFFE", comment: "Thanks to friends,lucky to get a giraffe monster!")
        case "dragon":
            return NSLocalizedString("MESSAGE_GET_DRAGON", comment: "It is a great satisfaction to get a dragon monster, so cool!")
        default:
            return ""
        }
    }
}
