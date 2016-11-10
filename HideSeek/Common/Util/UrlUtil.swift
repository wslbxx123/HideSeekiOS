//
//  UrlUtil.swift
//  HideSeek
//
//  Created by apple on 9/14/16.
//  Copyright © 2016 mj. All rights reserved.
//

class UrlUtil {
    class func getDictionaryFromQuery(_ query: NSString) -> NSDictionary {
        let delimiterSet = CharacterSet(charactersIn: "&")
        let pairs = NSMutableDictionary()
        
        let scanner = Scanner(string: query as String)
        while(!scanner.isAtEnd) {
            var pairStr: NSString?
            scanner.scanUpToCharacters(from: delimiterSet, into: &pairStr)
            scanner.scanCharacters(from: delimiterSet, into: nil)
            let kvPair = pairStr?.components(separatedBy: "=")
            
            if kvPair!.count == 2 {
                let keyStr = kvPair![0] as NSString
                let key = keyStr.removingPercentEncoding!
                
                let valueStr = kvPair![1] as NSString
                let value = valueStr.removingPercentEncoding!
                
                pairs.setObject(value, forKey: key as NSCopying)
            }
        }
        
        return NSDictionary(dictionary: pairs)
    }
}
