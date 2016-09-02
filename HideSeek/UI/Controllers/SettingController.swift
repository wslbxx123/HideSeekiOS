//
//  SettingController.swift
//  HideSeek
//
//  Created by apple on 7/23/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class SettingController: UIViewController {
    @IBOutlet weak var logOutView: MenuView!
    @IBOutlet weak var settingScrollView: UIScrollView!
    @IBOutlet weak var rateHideSeekView: MenuView!
    @IBOutlet weak var clearCacheView: MenuView!
    @IBOutlet weak var cacheSizeLabel: UILabel!
    
    @IBAction func settingBackBtnClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logOutView.addTarget(self, action: #selector(SettingController.logOutClicked), forControlEvents: UIControlEvents.TouchDown)
        self.automaticallyAdjustsScrollViewInsets = false
        settingScrollView.delaysContentTouches = false
        let rateGesture = UITapGestureRecognizer(target: self, action: #selector(SettingController.rateHideSeek))
        rateHideSeekView.userInteractionEnabled = true
        rateHideSeekView.addGestureRecognizer(rateGesture)
        let clearCacheGesture = UITapGestureRecognizer(target: self, action: #selector(SettingController.clearCache))
        clearCacheView.userInteractionEnabled = true
        clearCacheView.addGestureRecognizer(clearCacheGesture)
        cacheSizeLabel.text = BaseInfoUtil.cachefileSize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func rateHideSeek() {
        let systemVersion: NSString = UIDevice.currentDevice().systemVersion
        
        if systemVersion.floatValue != 7.0 {
            UIApplication.sharedApplication().openURL(NSURL(string: UrlParam.APP_STORE_URL)!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: UrlParam.IOS7_APP_STORE_URL)!)
        }
    }
    
    func clearCache() {
        BaseInfoUtil.clearCache()
        cacheSizeLabel.text = BaseInfoUtil.cachefileSize()
    }
    
    func logOutClicked() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultParam.SESSION_TOKEN)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultParam.USER_INFO)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultParam.RECORD_VERSION)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultParam.RECORD_MIN_ID)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultParam.RACE_GROUP_VERSION)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultParam.RACE_GROUP_RECORD_MIN_ID)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultParam.PRODUCT_VERSION)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultParam.PRODUCT_MIN_ID)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultParam.REWARD_VERSION)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultParam.REWARD_MIN_ID)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultParam.PURCHASE_ORDER_VERSION)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultParam.PURCHASE_ORDER_MIN_ID)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultParam.FRIEND_VERSION)

        NSUserDefaults.standardUserDefaults().synchronize()
        
        RecordCache.instance.clearList()
        RaceGroupCache.instance.clearList()
        ProductCache.instance.clearList()
        RewardCache.instance.clearList()
        PurchaseOrderCache.instance.clearList()
        
        RecordTableManager.instance.clear()
        RaceGroupTableManager.instance.clear()
        ProductTableManager.instance.clear()
        RewardTableManager.instance.clear()
        PurchaseOrderTableManager.instance.clear()
        FriendTableManager.instance.clear()
        
        self.navigationController?.popViewControllerAnimated(true)
    }

}
