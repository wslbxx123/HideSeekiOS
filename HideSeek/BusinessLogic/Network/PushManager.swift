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
    
    func registerPushForIOS8() {
        let acceptAction = UIMutableUserNotificationAction()
        acceptAction.identifier = "ACCEPT_IDENTIFIER"
        acceptAction.title = "Accept"
        acceptAction.activationMode = UIUserNotificationActivationMode.Foreground;
        acceptAction.destructive = false;
        acceptAction.authenticationRequired = false;
        
        let inviteCategory = UIMutableUserNotificationCategory()
        inviteCategory.identifier = "INVITE_CATEGORY"
        inviteCategory.setActions([acceptAction], forContext: UIUserNotificationActionContext.Default)
        inviteCategory.setActions([acceptAction], forContext: UIUserNotificationActionContext.Minimal)
        
        let categories = NSSet(objects: inviteCategory)
        let mySettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: categories as! Set<UIUserNotificationCategory>)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func registerPush() {
        UIApplication.sharedApplication().registerForRemoteNotificationTypes([.Badge, .Sound, .Alert])
    }
    
    func register() {
        XGPush.initForReregister {
            NSLog("Reregister initialize successfully.")
        }
        
        let systemVersion: NSString = UIDevice.currentDevice().systemVersion
        if systemVersion.floatValue >= 8.0 {
            let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        } else {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes([.Badge, .Sound, .Alert])
        }
    }
    
    func unRegister() {
        XGPush.unRegisterDevice()
    }
    
    func startApp(launchOptions: [NSObject: AnyObject]?) {
        XGPush.startApp(TENCENT_IM_ID, appKey: TENCENT_IM_KEY)
        
        XGPush.handleLaunching(launchOptions)
        
        register()
    }
}
