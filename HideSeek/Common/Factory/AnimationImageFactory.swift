//
//  AnimationImageFactory.swift
//  HideSeek
//
//  Created by apple on 7/19/16.
//  Copyright © 2016 mj. All rights reserved.
//

class AnimationImageFactory {
    class func getSwordArray() -> NSArray {
        let imageArray = NSMutableArray()
        imageArray.addObject("sword_a")
        imageArray.addObject("sword_b")
        imageArray.addObject("sword_c")
        imageArray.addObject("sword_d")
        imageArray.addObject("sword_e")
        imageArray.addObject("sword_f")
        imageArray.addObject("sword_g")
        imageArray.addObject("sword_h")
        return imageArray
    }
    
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
            
            if UserCache.instance.ifLogin() && goal.createBy != UserCache.instance.user.pkId {
                imageArray.addObject("bomb_a")
                imageArray.addObject("bomb_b")
                imageArray.addObject("bomb_c")
                imageArray.addObject("bomb_d")
            }
            break;
        case .monster:
            imageArray = getMonsterArray(goal.showTypeName!)
            break;
        default:
            break;
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
    
    class func getDuration(goal: Goal)-> NSTimeInterval {
        switch goal.type {
        case .mushroom:
            return 5
        case .bomb:
            return 5
        case .monster:
            return 5
        default:
            return 0
        }
    }
    
    class func getRoleArray()-> NSMutableArray{
        let imageArray = NSMutableArray()
        imageArray.addObject("grass_fairy")
        imageArray.addObject("water_magician")
        imageArray.addObject("fire_knight")
        imageArray.addObject("stone_monster")
        imageArray.addObject("lightning_giant")
        return imageArray
    }
}
