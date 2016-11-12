//
//  CustomRequestManager.swift
//  HideSeek
//
//  Created by apple on 7/4/16.
//  Copyright © 2016 mj. All rights reserved.
//
import AFNetworking

class CustomRequestManager: AFHTTPSessionManager {
    var ifLock: Bool = false
    
    func POST(_ URLString: String,
              paramDict: NSMutableDictionary,
              success: ((URLSessionDataTask, Any?) -> Void)?,
              failure: ((URLSessionDataTask?, Error) -> Void)?) -> URLSessionDataTask? {
        if ifLock {
            return nil
        }
        
        let userDefault = UserDefaults.standard
        let sessionToken = userDefault.object(forKey: UserDefaultParam.SESSION_TOKEN) as? String
        
        paramDict["session_id"] = sessionToken
        paramDict["app_version"] = BaseInfoUtil.getAppVersion()
        
        return super.post(URLString, parameters: paramDict,
                          progress: nil,
                          success: success,
                          failure: failure)
    }
    
    func POST(_ URLString: String, paramDict: NSMutableDictionary, constructingBodyWithBlock block: ((AFMultipartFormData) -> Void)?, success: ((URLSessionDataTask, Any) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) -> URLSessionDataTask? {
        if ifLock {
            return nil
        }

        let userDefault = UserDefaults.standard
        let sessionToken = userDefault.object(forKey: UserDefaultParam.SESSION_TOKEN) as? String
        paramDict["session_id"] = sessionToken
        
        return super.post(URLString, parameters: paramDict,
                          constructingBodyWith: block,
                          progress: nil,
                          success: success,
                          failure: failure)
    }
}
