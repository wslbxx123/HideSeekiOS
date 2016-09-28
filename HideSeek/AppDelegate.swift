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
    
    let MAP_KEY = "293ee05942de45f4f221656ca2faa5b9"
    let AUDIO_KEY = "578cb259"
    let SMS_KEY = "156855918c1ab"
    let SMS_SECRET = "5a5efd0f24dbafa7647c7dd60fd99fed"
    let SHARE_KEY = "wx35d7e379b7472410"
    let SHARE_SECRET = "d54adfb1105f71be8099b5a803bbc92f"
    let QQ_SHARE_ID = "1105718948"
    let QQ_SHARE_KEY = "ZDFy7JnidJqj1G2a"
    var window: UIWindow?
    var isBackgroundActivateApplication: Bool = false
    var tabBarController: ViewController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        tabBarController = storyboard.instantiateViewControllerWithIdentifier("main") as! ViewController
        self.window?.rootViewController = tabBarController
        
        AMapServices.sharedServices().apiKey = MAP_KEY
        let initString = NSString.init(format: "appid=%@", AUDIO_KEY)
        IFlySpeechUtility.createUtility(initString as String)
        SMSSDK.registerApp(SMS_KEY, withSecret: SMS_SECRET)
        
        PushManager.instance.startApp(launchOptions)
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        ShareSDK.registerApp(SHARE_KEY, activePlatforms: [
            SSDKPlatformType.TypeSinaWeibo.rawValue,
            SSDKPlatformType.TypeMail.rawValue,
            SSDKPlatformType.TypeSMS.rawValue,
            SSDKPlatformType.TypeCopy.rawValue,
            SSDKPlatformType.TypeWechat.rawValue,
            SSDKPlatformType.TypeQQ.rawValue,
            SSDKPlatformType.TypeRenren.rawValue,
            SSDKPlatformType.TypeGooglePlus.rawValue],
            onImport: { (platformType) in
                switch(platformType) {
                case SSDKPlatformType.TypeWechat:
                    ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                    break;
                case SSDKPlatformType.TypeQQ:
                    ShareSDKConnector.connectQQ(QQApiInterface.self, tencentOAuthClass: TencentOAuth.classForCoder())
                    break;
                case SSDKPlatformType.TypeSinaWeibo:
                    ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
                    break;
                case SSDKPlatformType.TypeRenren:
                    ShareSDKConnector.connectRenren(RennClient.classForCoder())
                    break;
                default:
                    break;
                }
            }) { (platformType, appInfo) in
                switch(platformType) {
                case SSDKPlatformType.TypeSinaWeibo:
                    appInfo
                        .SSDKSetupSinaWeiboByAppKey("568898243",
                                                       appSecret: "38a4f8204cc784f81f9f0daaf31e02e3",
                                                       redirectUri: "http://www.sharesdk.cn",
                                                       authType: SSDKAuthTypeBoth)
                    break;
                case SSDKPlatformType.TypeWechat:
                    appInfo.SSDKSetupWeChatByAppId(self.SHARE_KEY,
                                                   appSecret: self.SHARE_SECRET)
                    break;
                case SSDKPlatformType.TypeQQ:
                    appInfo.SSDKSetupQQByAppId(self.QQ_SHARE_ID,
                                               appKey: self.QQ_SHARE_KEY,
                                               authType: SSDKAuthTypeBoth)
                    break;
                case SSDKPlatformType.TypeRenren:
                    appInfo.SSDKSetupRenRenByAppId("226427",
                                                   appKey: "fc5b8aed373c4c27a05b712acba0f8c3",
                                                   secretKey: "f29df781abdd4f49beca5a2194676ca4",
                                                   authType: SSDKAuthTypeBoth)
                    break;
                case SSDKPlatformType.TypeGooglePlus:
                    appInfo.SSDKSetupGooglePlusByClientID("232554794995.apps.googleusercontent.com",
                                                          clientSecret: "PEdFgtrMw97aCvf0joQj7EMk",
                                                          redirectUri: "http://localhost")
                    break;
                default:
                    break;
                }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let deviceTokenstr = XGPush.registerDevice(deviceToken, successCallback: {
            NSLog("[XGPush Demo]register successBlock");
            }) { 
            NSLog("[XGPush Demo]register errorBlock");
        }
        
        tabBarController.updateSetting()
        tabBarController.updateChannelId(deviceTokenstr)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog("DeviceToken 获取失败，原因：％@", error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        XGPush.handleReceiveNotification(userInfo)
        
        let result = userInfo as NSDictionary
        let type = (result["type"] as! NSString).integerValue
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let newFriendController = storyboard.instantiateViewControllerWithIdentifier("NewFriend") as! NewFriendController
        
        switch(type) {
        case SEND_FRIEND_REQUEST:
            newFriendController.setFriendRequest(result, isFriend: false)
            
            BadgeUtil.updateMeBadge()
            break;
        default:
            newFriendController.setFriendRequest(result, isFriend: true)
            
            BadgeUtil.updateMeBadge()
            break;
        }
        
        if application.applicationState != UIApplicationState.Active
            && application.applicationState == UIApplicationState.Background {
            (tabBarController.selectedViewController! as! UINavigationController).pushViewController(newFriendController, animated: true)
        }
        
        NSLog("%@", userInfo)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        NSLog("接收本地通知啦")
    }
    
    // 此方法是 用户点击了通知，应用在前台 或者开启后台并且应用在后台时调起
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.NewData)
        let result = userInfo as NSDictionary
        let type = BaseInfoUtil.getIntegerFromAnyObject(result["type"])
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let newFriendController = storyboard.instantiateViewControllerWithIdentifier("NewFriend") as! NewFriendController
        
        switch(type) {
        case SEND_FRIEND_REQUEST:
            newFriendController.setFriendRequest(result, isFriend: false)
            
            BadgeUtil.updateMeBadge()
            break;
        default:
            newFriendController.setFriendRequest(result, isFriend: true)
            
            BadgeUtil.updateMeBadge()
            break;
        }
        
        if application.applicationState == UIApplicationState.Inactive && !isBackgroundActivateApplication {
            (tabBarController.selectedViewController! as! UINavigationController).pushViewController(newFriendController, animated: true)
        }
        
        if application.applicationState == UIApplicationState.Background {
            NSLog("background is Activated Application ")
            
            isBackgroundActivateApplication = true
        }
        
        NSLog("%@", userInfo);
    }
    
    // 在 iOS8系统中，需要添加这个方法。通过新的 API 注册推送服务
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if !UserCache.instance.ifLogin() {
            let errorMessage = NSLocalizedString("ERROR_NOT_LOGIN", comment: "Please login first")
            HudToastFactory.show(errorMessage, view: tabBarController.view, type: HudToastFactory.MessageType.ERROR)
            return true
        }
        
        if userActivity.webpageURL != nil {
            let query = userActivity.webpageURL?.query
            if query != nil {
                let params = UrlUtil.getDictionaryFromQuery(query!)
                
                let goalIdStr = params.valueForKey("goal_id") as? NSString
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

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if url.host == "safepay" {
            AlipaySDK.defaultService().processOrderWithPaymentResult(url, standbyCallback: { (result) in
                NSLog("result = %@", result.description);
                
                let resultDic = result as NSDictionary
                let resultStatus = resultDic["resultStatus"]?.integerValue
                let message = AlipayManager.instance.getAlipayResult(resultStatus!)
                
                let window = UIApplication.sharedApplication().keyWindow
                let controller = window!.visibleViewController()
                
                if controller.isKindOfClass(StoreController) {
                    let storeController = controller as! StoreController
                    if(resultStatus == 9000) {
                        storeController.purchaseController.showMessage(message as String, type: HudToastFactory.MessageType.SUCCESS)
                        storeController.purchaseController.purchase()
                        storeController.purchaseController.close()
                    } else {
                        storeController.purchaseController.showMessage(message as String, type: HudToastFactory.MessageType.ERROR)
                    }
                } else if controller.isKindOfClass(MyOrderController){
                    let myOrderController = controller as! MyOrderController
                    if(resultStatus == 9000) {
                        myOrderController.purchaseOrderController.showMessage(message as String, type: HudToastFactory.MessageType.SUCCESS)
                        myOrderController.purchaseOrderController.purchase()
                        myOrderController.purchaseOrderController.close()
                    } else {
                        myOrderController.purchaseOrderController.showMessage(message as String, type: HudToastFactory.MessageType.ERROR)
                    }
                }
            })
        }
        return true;
    }
}

