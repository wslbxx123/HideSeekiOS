//
//  UrlUtil.swift
//  HideSeek
//
//  Created by apple on 9/14/16.
//  Copyright © 2016 mj. All rights reserved.
//

class UrlUtil {
    class func getDictionaryFromQuery(query: NSString) -> NSDictionary {
        let delimiterSet = NSCharacterSet(charactersInString: "&")
        let pairs = NSMutableDictionary()
        
        let scanner = NSScanner(string: query as String)
        while(!scanner.atEnd) {
            var pairStr: NSString?
            scanner.scanUpToCharactersFromSet(delimiterSet, intoString: &pairStr)
            scanner.scanCharactersFromSet(delimiterSet, intoString: nil)
            let kvPair = pairStr?.componentsSeparatedByString("=")
            
            if kvPair!.count == 2 {
                let keyStr = kvPair![0] as NSString
                let key = keyStr.stringByRemovingPercentEncoding!
                
                let valueStr = kvPair![1] as NSString
                let value = valueStr.stringByRemovingPercentEncoding!
                
                pairs.setObject(value, forKey: key)
            }
        }
        
        return NSDictionary(dictionary: pairs)
    }
}
