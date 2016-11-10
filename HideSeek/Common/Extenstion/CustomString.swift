//
//  CustomString.swift
//  HideSeek
//
//  Created by apple on 15/10/2016.
//  Copyright © 2016 mj. All rights reserved.
//

extension String {
    func compareTo (_ otherStr: String, separator: String) -> Int {
        let strArray = self.components(separatedBy: separator)
        let otherStrArray = otherStr.components(separatedBy: separator)
        
        let length = strArray.count > otherStrArray.count ?
            otherStrArray.count : strArray.count
        
        var num: Int = 0
        var otherNum: Int = 0
        
        for index in 0...(length - 1) {
            if strArray[index].isEmpty {
                num = -1
            } else {
                num = Int(strArray[index])!
            }
            
            if otherStrArray[index].isEmpty {
                num = -1
            } else {
                otherNum = Int(otherStrArray[index])!
            }
            
            if(num > otherNum) {
                return 1
            } else if (num < otherNum) {
                return -1
            }
        }
        return 0;
    }
}
