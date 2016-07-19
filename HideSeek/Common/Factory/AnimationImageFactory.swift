//
//  AnimationImageFactory.swift
//  HideSeek
//
//  Created by apple on 7/19/16.
//  Copyright © 2016 mj. All rights reserved.
//

class AnimationImageFactory {
    class func get(goal: Goal) -> NSArray {
        var imageArray = NSMutableArray()
        switch goal.type {
        case .mushroom:
            imageArray.addObject("mushroom")
            imageArray.addObject("mushroom_a")
            imageArray.addObject("mushroom_b")
            imageArray.addObject("mushroom_c")
            imageArray.addObject("mushroom_d")
            break;
        case .bomb:
            imageArray.addObject("bomb")
            imageArray.addObject("bomb_a")
            imageArray.addObject("bomb_b")
            imageArray.addObject("bomb_c")
            imageArray.addObject("bomb_d")
            break;
        case .monster:
            imageArray = getMonsterArray(goal.showTypeName!)
        }
        
        return imageArray
    }
    
    class func getMonsterArray(name: String)-> NSMutableArray {
        let imageArray = NSMutableArray()
        switch(name) {
        case "dragon":
            imageArray.addObject("dragon")
            imageArray.addObject("dragon_a")
            imageArray.addObject("dragon_b")
            break
        case "bird":
            imageArray.addObject("bird")
            imageArray.addObject("bird_a")
            imageArray.addObject("bird_b")
            imageArray.addObject("bird_c")
            imageArray.addObject("bird_d")
            break
        case "giraffe":
            imageArray.addObject("giraffe")
            imageArray.addObject("giraffe_a")
            imageArray.addObject("giraffe_b")
            imageArray.addObject("giraffe_c")
            imageArray.addObject("giraffe_d")
            imageArray.addObject("giraffe_e")
            break
        case "cow":
            imageArray.addObject("cow")
            imageArray.addObject("cow_a")
            imageArray.addObject("cow_b")
            imageArray.addObject("cow_c")
            break
        case "egg":
            imageArray.addObject("egg")
            imageArray.addObject("egg_a")
            break
        default:
            break;
        }
        return imageArray
    }
}
