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
    var isEnabled: Bool
    var showTypeName: String?
    var isSelected: Bool = false
    
    init(pkId: Int64, latitude: Double, longitude: Double, orientation: Int, valid: Bool,
         type: GoalTypeEnum, isEnabled: Bool, showTypeName: String?) {
        self.pkId = pkId
        self.latitude = latitude
        self.longitude = longitude
        self.orientation = orientation
        self.valid = valid
        self.type = type
        self.isEnabled = isEnabled
        self.showTypeName = showTypeName
    }
    enum GoalTypeEnum : Int{
        case mushroom = 1
        case monster = 2
        case bomb = 3
    }
}
