//
//  PushManager.swift
//  HideSeek
//
//  Created by apple on 9/6/16.
//  Copyright © 2016 mj. All rights reserved.
//

class PushManager {
    static let instance = PushManager()
    let TENCENT_IM_ID: UInt32 = 2200218505
    let TENCENT_IM_KEY = "IWW9FA6G499F"
    
    func registerPush() {
        let acceptAction = UIMutableUserNotificationAction()
        acceptAction.identifier = "ACCEPT_IDENTIFIER"
        acceptAction.title = "Accept"
        acceptAction.activationMode = UIUserNotificationActivationMode.foreground;
        acceptAction.isDestructive = false;
        acceptAction.isAuthenticationRequired = false;
        
        let inviteCategory = UIMutableUserNotificationCategory()
        inviteCategory.identifier = "INVITE_CATEGORY"
        inviteCategory.setActions([acceptAction], for: UIUserNotificationActionContext.default)
        inviteCategory.setActions([acceptAction], for: UIUserNotificationActionContext.minimal)
        
        let categories = NSSet(objects: inviteCategory)
        let mySettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: categories as? Set<UIUserNotificationCategory>)
        
        UIApplication.shared.registerUserNotificationSettings(mySettings)
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func register() {
        XGPush.initForReregister {
            NSLog("Reregister initialize successfully.")
        }
        
        registerPush()
    }
    
    func unRegister() {
        XGPush.unRegisterDevice()
    }
    
    func startApp(_ launchOptions: [AnyHashable: Any]?) {
        XGPush.startApp(TENCENT_IM_ID, appKey: TENCENT_IM_KEY)
        
        XGPush.handleLaunching(launchOptions)
        
        register()
    }
}
