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
    let MAP_KEY = "293ee05942de45f4f221656ca2faa5b9"
    let AUDIO_KEY = "578cb259"
    let SMS_KEY = "156855918c1ab"
    let SMS_SECRET = "5a5efd0f24dbafa7647c7dd60fd99fed"
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        AMapServices.sharedServices().apiKey = MAP_KEY
        let initString = NSString.init(format: "appid=%@", AUDIO_KEY)
        IFlySpeechUtility.createUtility(initString as String)
        SMSSDK.registerApp(SMS_KEY, withSecret: SMS_SECRET)
        
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
                        storeController.purchaseController.close()
                    } else {
                        storeController.purchaseController.showMessage(message as String, type: HudToastFactory.MessageType.ERROR)
                    }
                } else if controller.isKindOfClass(MyOrderController){
                    let myOrderController = controller as! MyOrderController
                    if(resultStatus == 9000) {
                        myOrderController.purchaseOrderController.showMessage(message as String, type: HudToastFactory.MessageType.SUCCESS)
                         myOrderController.purchaseOrderController.close()
                    }
                    myOrderController.purchaseOrderController.showMessage(message as String, type: HudToastFactory.MessageType.ERROR)
                }
            })
        }
        return true;
    }
}

