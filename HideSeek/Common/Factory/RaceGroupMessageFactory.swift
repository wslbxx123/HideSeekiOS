//
//  RaceGroupMessageFactory.swift
//  HideSeek
//
//  Created by apple on 9/19/16.
//  Copyright © 2016 mj. All rights reserved.
//

class RaceGroupMessageFactory {
    class func get(score: Int, goalType: Goal.GoalTypeEnum, showTypeName: String?)-> String {
        switch(goalType) {
        case .mushroom:
            return NSLocalizedString("MESSAGE_GET_MUSHROOM", comment: "Throw a mushroom monster into sack easily, Rich bitch!")
        case .monster:
            return getMonsterMessage(score, showTypeName: showTypeName!)
        case .bomb:
            return NSLocalizedString("MESSAGE_GET_BOMB", comment: "Unfortunately detonated a crafty bomb monster, Give me a break!")
        default:
            return NSLocalizedString("MESSAGE_NOT_KNOWN_GOAL", comment: "An unknown liviing thing!")
        }
    }
    
    class func getMonsterMessage(score: Int, showTypeName: String) -> String {
        if score < 0 {
            return NSString(format: NSLocalizedString("MESSAGE_BEATEND_BY_MONSTER", comment: "You are beated by a %@"), NSLocalizedString(showTypeName, comment: "")) as String
        }
        
        switch(showTypeName) {
        case "egg":
            return NSLocalizedString("MESSAGE_GET_EGG", comment: "So excited! Beat an egg monster successfully")
        case "cow":
            return NSLocalizedString("MESSAGE_GET_COW", comment: "You are watched by a cow monster，how smart I am to beat it in time!")
        case "bird":
            return NSLocalizedString("MESSAGE_GET_BIRD", comment: "Dodged a bullet! Coming across a bird monster scared me!")
        case "giraffe":
            return NSLocalizedString("MESSAGE_GET_GIRAFFE", comment: "Thanks to friends,lucky to get a giraffe monster!")
        case "dragon":
            return NSLocalizedString("MESSAGE_GET_DRAGON", comment: "It is a great satisfaction to get a dragon monster, so cool!")
        default:
            return NSLocalizedString("MESSAGE_GET_UNKNOWN", comment: "You beat an unknown living")
        }
    }
}
