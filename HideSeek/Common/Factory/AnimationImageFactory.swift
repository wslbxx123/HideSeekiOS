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
        imageArray.add("sword_a")
        imageArray.add("sword_b")
        imageArray.add("sword_c")
        imageArray.add("sword_d")
        imageArray.add("sword_e")
        imageArray.add("sword_f")
        imageArray.add("sword_g")
        imageArray.add("sword_h")
        return imageArray
    }
    
    class func get(_ goal: Goal) -> NSArray {
        var imageArray = NSMutableArray()
        switch goal.type {
        case .mushroom:
            imageArray.add("mushroom")
            imageArray.add("mushroom_a")
            imageArray.add("mushroom_b")
            imageArray.add("mushroom_c")
            imageArray.add("mushroom_d")
            break;
        case .bomb:
            imageArray.add("bomb")
            
            if UserCache.instance.ifLogin() && goal.createBy != UserCache.instance.user.pkId {
                imageArray.add("bomb_a")
                imageArray.add("bomb_b")
                imageArray.add("bomb_c")
                imageArray.add("bomb_d")
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
    
    class func getMonsterArray(_ name: String)-> NSMutableArray {
        let imageArray = NSMutableArray()
        switch(name) {
        case "dragon":
            imageArray.add("dragon")
            imageArray.add("dragon_a")
            imageArray.add("dragon_b")
            break
        case "bird":
            imageArray.add("bird")
            imageArray.add("bird_a")
            imageArray.add("bird_b")
            imageArray.add("bird_c")
            imageArray.add("bird_d")
            break
        case "giraffe":
            imageArray.add("giraffe")
            imageArray.add("giraffe_a")
            imageArray.add("giraffe_b")
            imageArray.add("giraffe_c")
            imageArray.add("giraffe_d")
            imageArray.add("giraffe_e")
            break
        case "cow":
            imageArray.add("cow")
            imageArray.add("cow_a")
            imageArray.add("cow_b")
            imageArray.add("cow_c")
            break
        case "egg":
            imageArray.add("egg")
            imageArray.add("egg_a")
            break
        default:
            break;
        }
        return imageArray
    }
    
    class func getDuration(_ goal: Goal)-> TimeInterval {
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
        imageArray.add("grass_fairy")
        imageArray.add("water_magician")
        imageArray.add("fire_knight")
        imageArray.add("stone_monster")
        imageArray.add("lightning_giant")
        return imageArray
    }
}
