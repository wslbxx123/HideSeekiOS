//
//  AppDelegate.swift
//  HideSeek
//
//  Created by apple on 6/9/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let SEND_FRIEND_REQUEST = 1
    let ACCEPT_FRIEND = 2
    let LOGOUT = 3
    
    let MAP_KEY = "293ee05942de45f4f221656ca2faa5b9"
    let AUDIO_KEY = "578cb259"
    let SMS_KEY = "156855918c1ab"
    let SMS_SECRET = "5a5efd0f24dbafa7647c7dd60fd99fed"
    let SHARE_KEY = "wx35d7e379b7472410"
    let SHARE_SECRET = "d54adfb1105f71be8099b5a803bbc92f"
    let QQ_SHARE_ID = "1105718948"
    let QQ_SHARE_KEY = "ZDFy7JnidJqj1G2a"
    let BUGLY_ID = "900054641"
    var window: UIWindow?
    var isBackgroundActivateApplication: Bool = false
    var tabBarController: ViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        tabBarController = storyboard.instantiateViewController(withIdentifier: "main") as! ViewController
        self.window?.rootViewController = tabBarController
        
        AMapServices.shared().apiKey = MAP_KEY
        let initString = NSString.init(format: "appid=%@", AUDIO_KEY)
        IFlySpeechUtility.createUtility(initString as String)
        SMSSDK.registerApp(SMS_KEY, withSecret: SMS_SECRET)
        
        PushManager.instance.startApp(launchOptions)
        Bugly.start(withAppId: BUGLY_ID)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        ShareSDK.registerApp(SHARE_KEY, activePlatforms: [
            SSDKPlatformType.typeSinaWeibo.rawValue,
            SSDKPlatformType.typeMail.rawValue,
            SSDKPlatformType.typeSMS.rawValue,
            SSDKPlatformType.typeCopy.rawValue,
            SSDKPlatformType.typeWechat.rawValue,
            SSDKPlatformType.typeQQ.rawValue,
            SSDKPlatformType.typeRenren.rawValue,
            SSDKPlatformType.typeGooglePlus.rawValue],
            onImport: { (platformType) in
                switch(platformType) {
                case SSDKPlatformType.typeWechat:
                    ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                    break;
                case SSDKPlatformType.typeQQ:
                    ShareSDKConnector.connectQQ(QQApiInterface.self, tencentOAuthClass: TencentOAuth.classForCoder())
                    break;
                case SSDKPlatformType.typeSinaWeibo:
                    ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
                    break;
                case SSDKPlatformType.typeRenren:
                    ShareSDKConnector.connectRenren(RennClient.classForCoder())
                    break;
                default:
                    break;
                }
            }) { (platformType, appInfo) in
                switch(platformType) {
                case SSDKPlatformType.typeSinaWeibo:
                    appInfo?
                        .ssdkSetupSinaWeibo(byAppKey: "568898243",
                                                       appSecret: "38a4f8204cc784f81f9f0daaf31e02e3",
                                                       redirectUri: "http://www.sharesdk.cn",
                                                       authType: SSDKAuthTypeBoth)
                    break;
                case SSDKPlatformType.typeWechat:
                    appInfo?.ssdkSetupWeChat(byAppId: self.SHARE_KEY,
                                                   appSecret: self.SHARE_SECRET)
                    break;
                case SSDKPlatformType.typeQQ:
                    appInfo?.ssdkSetupQQ(byAppId: self.QQ_SHARE_ID,
                                               appKey: self.QQ_SHARE_KEY,
                                               authType: SSDKAuthTypeBoth)
                    break;
                case SSDKPlatformType.typeRenren:
                    appInfo?.ssdkSetupRenRen(byAppId: "226427",
                                                   appKey: "fc5b8aed373c4c27a05b712acba0f8c3",
                                                   secretKey: "f29df781abdd4f49beca5a2194676ca4",
                                                   authType: SSDKAuthTypeBoth)
                    break;
                case SSDKPlatformType.typeGooglePlus:
                    appInfo?.ssdkSetupGooglePlus(byClientID: "232554794995.apps.googleusercontent.com",
                                                          clientSecret: "PEdFgtrMw97aCvf0joQj7EMk",
                                                          redirectUri: "http://localhost")
                    break;
                default:
                    break;
                }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if UserCache.instance.ifLogin() {
            XGPush.setAccount(UserCache.instance.user.phone as String)
            var deviceTokenStr = XGPush.registerDevice(deviceToken, successCallback: {
                NSLog("[XGPush Demo]register successBlock");
            }) {
                NSLog("[XGPush Demo]register errorBlock");
            }
            
            if deviceTokenStr == nil || deviceTokenStr == "" {
                deviceTokenStr = deviceToken.description.replacingOccurrences(of: "<", with: "")
                    .replacingOccurrences(of: ">", with: "")
                    .replacingOccurrences(of: " ", with: "")
            }
            
            NSLog("[XGPush Demo]device token: " + deviceTokenStr!);
            
            tabBarController.updateChannelId(deviceTokenStr! as String)
        }
        
        tabBarController.refreshSetting()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("DeviceToken 获取失败，原因：％@", error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        XGPush.handleReceiveNotification(userInfo)
        
        let result = userInfo as NSDictionary
        let type = BaseInfoUtil.getIntegerFromAnyObject(result["type"])
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let newFriendController = storyboard.instantiateViewController(withIdentifier: "NewFriend") as! NewFriendController
        
        switch(type) {
        case SEND_FRIEND_REQUEST:
            newFriendController.setFriendRequest(result, isFriend: false)
            
            BadgeUtil.updateMeBadge()
            break;
        case ACCEPT_FRIEND:
            newFriendController.setFriendRequest(result, isFriend: true)
            
            BadgeUtil.updateMeBadge()
            break;
        case LOGOUT:
            let topController = BaseInfoUtil.topViewController()
            let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_SESSION_INVALID)
            
            HudToastFactory.show(errorMessage, view: topController!.view, type: HudToastFactory.MessageType.error, callback: {
                UserInfoManager.instance.logout(topController!)
            })
            break;
        default:
            break;
        }
        
        if application.applicationState != UIApplicationState.active
            && application.applicationState == UIApplicationState.background {
            (tabBarController.selectedViewController! as! UINavigationController).pushViewController(newFriendController, animated: true)
        }
        
        NSLog("%@", userInfo)
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        NSLog("接收本地通知啦")
    }
    
    // 此方法是 用户点击了通知，应用在前台 或者开启后台并且应用在后台时调起
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData)
        let result = userInfo as NSDictionary
        let type = BaseInfoUtil.getIntegerFromAnyObject(result["type"])
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let newFriendController = storyboard.instantiateViewController(withIdentifier: "NewFriend") as! NewFriendController
        
        switch(type) {
        case SEND_FRIEND_REQUEST:
            newFriendController.setFriendRequest(result, isFriend: false)
            
            BadgeUtil.updateMeBadge()
            break;
        case ACCEPT_FRIEND:
            newFriendController.setFriendRequest(result, isFriend: true)
            
            BadgeUtil.updateMeBadge()
            break;
        case LOGOUT:
            let topController = BaseInfoUtil.topViewController()
            let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_SESSION_INVALID)
            
            HudToastFactory.show(errorMessage, view: topController!.view, type: HudToastFactory.MessageType.error, callback: {
                UserInfoManager.instance.logout(topController!)
            })
            break;
        default:
            break;
        }
        
        if application.applicationState == UIApplicationState.inactive && !isBackgroundActivateApplication {
            (tabBarController.selectedViewController! as! UINavigationController).pushViewController(newFriendController, animated: true)
        }
        
        if application.applicationState == UIApplicationState.background {
            NSLog("background is Activated Application ")
            
            isBackgroundActivateApplication = true
        }
        
        NSLog("%@", userInfo);
    }
    
    // 在 iOS8系统中，需要添加这个方法。通过新的 API 注册推送服务
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if !UserCache.instance.ifLogin() {
            let errorMessage = NSLocalizedString("ERROR_NOT_LOGIN", comment: "Please login first")
            HudToastFactory.show(errorMessage, view: tabBarController.view, type: HudToastFactory.MessageType.error)
            return true
        }
        
        if userActivity.webpageURL != nil {
            let query = userActivity.webpageURL?.query
            if query != nil {
                let params = UrlUtil.getDictionaryFromQuery(query! as NSString)
                
                let goalIdStr = params.value(forKey: "goal_id") as? NSString
                if goalIdStr != nil {
                    let navigationController = tabBarController.viewControllers![0] as!UINavigationController
                    let homeController = navigationController.viewControllers[0] as! HomeController
                    tabBarController.selectedIndex = 0
                    homeController.updateEndGoal(goalIdStr!.longLongValue)
                }
            }
        }
        return true;
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if url.host == "safepay" {
            AlipayManager.instance.checkAlipayResult(url)
        }
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.host == "safepay" {
            AlipayManager.instance.checkAlipayResult(url)
        }
        
        return true
    }
}

