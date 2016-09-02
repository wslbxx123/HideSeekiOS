//
//  Goal.swift
//  HideSeek
//
//  Created by apple on 7/4/16.
//  Copyright © 2016 mj. All rights reserved.
//

class Goal{
    var pkId: Int64
    var latitude: Double
    var longitude: Double
    var orientation: Int
    var valid: Bool
    var type: GoalTypeEnum
    var showTypeName: String?
    var isSelected: Bool = false
    var createBy: Int64
    var introduction: String?
    var score: Int
    var unionType: Int
    
    init(pkId: Int64, latitude: Double, longitude: Double, orientation: Int, valid: Bool,
         type: GoalTypeEnum, showTypeName: String?, createBy: Int64, introduction: String?, score: Int, unionType: Int) {
        self.pkId = pkId
        self.latitude = latitude
        self.longitude = longitude
        self.orientation = orientation
        self.valid = valid
        self.type = type
        self.showTypeName = showTypeName
        self.createBy = createBy
        self.introduction = introduction
        self.score = score
        self.unionType = unionType
    }
    enum GoalTypeEnum : Int{
        case mushroom = 1
        case monster = 2
        case bomb = 3
    }
    
    var goalName: String {
        get {
            switch type {
            case .mushroom:
                return NSLocalizedString("mushroom", comment: "mushroom")
            case .bomb:
                return NSLocalizedString("bomb", comment: "bomb")
            case .monster:
                return NSLocalizedString(showTypeName!, comment: "dragon")
            }
        }
    }
}
