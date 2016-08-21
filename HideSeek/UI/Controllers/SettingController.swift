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
    
    @IBAction func settingBackBtnClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logOutView.addTarget(self, action: #selector(SettingController.logOutClicked), forControlEvents: UIControlEvents.TouchDown)
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
        
        self.navigationController?.popViewControllerAnimated(true)
    }

}
