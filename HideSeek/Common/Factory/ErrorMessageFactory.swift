//
//  ErrorMessageFactory.swift
//  HideSeek
//
//  Created by apple on 6/28/16.
//  Copyright © 2016 mj. All rights reserved.
//

class ErrorMessageFactory {
    class func get(errorCode: Int) -> String {
        switch errorCode {
        case CodeParam.ERROR_VOLLEY_CODE:
            return NSLocalizedString("ERROR_CONNECT_NETWORK_FAILED", comment: "Failed to connect the network")
        case CodeParam.ERROR_LOGIN_FAILED:
            return NSLocalizedString("ERROR_LOGIN_FAILED", comment: "Phone or password error")
        default:
            return ""
        }
    }
}
