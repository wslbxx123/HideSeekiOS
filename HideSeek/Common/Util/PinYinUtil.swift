//
//  PinYinUtil.swift
//  HideSeek
//
//  Created by apple on 6/30/16.
//  Copyright © 2016 mj. All rights reserved.
//

class PinYinUtil {
    class func converterToFirstSpell(chinese: String)-> String{
        let mutableString = NSMutableString(string: chinese) as CFMutableString

        CFStringTransform(mutableString, nil, kCFStringTransformMandarinLatin, false)
        return mutableString as String
    }
}
