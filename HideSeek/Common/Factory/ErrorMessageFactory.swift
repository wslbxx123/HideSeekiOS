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
        case CodeParam.ERROR_PHONE_OR_PASSWORD_WRONG:
            return NSLocalizedString("ERROR_PHONE_OR_PASSWORD_WRONG", comment: "Phone or password error")
        case CodeParam.ERROR_USER_ALREADY_EXIST:
            return NSLocalizedString("ERROR_USER_ALREADY_EXIST", comment: "The phone is already registered")
        case CodeParam.ERROR_GOAL_DISAPPEAR:
            return NSLocalizedString("ERROR_GOAL_DISAPPEAR", comment: "The goal is killed by others")
        case CodeParam.ERROR_SEARCH_MYSELF:
            return NSLocalizedString("ERROR_SEARCH_MYSELF", comment: "Cannot add yourself as friend")
        default:
            return ""
        }
    }
}
