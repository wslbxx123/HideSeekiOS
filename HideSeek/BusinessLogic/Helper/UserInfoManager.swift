//
//  UserInfoManager.swift
//  HideSeek
//
//  Created by apple on 9/9/16.
//  Copyright © 2016 mj. All rights reserved.
//

class UserInfoManager {
    static let instance = UserInfoManager()
    
    func clearData() {
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
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultParam.SCORE_SUM)
        
        NSUserDefaults.standardUserDefaults().synchronize()
        
        RecordCache.instance.clearList()
        RaceGroupCache.instance.clearList()
        ProductCache.instance.clearList()
        RewardCache.instance.clearList()
        PurchaseOrderCache.instance.clearList()
        FriendCache.instance.clearList()
        
        RecordTableManager.instance.clear()
        RaceGroupTableManager.instance.clear()
        ProductTableManager.instance.clear()
        RewardTableManager.instance.clear()
        PurchaseOrderTableManager.instance.clear()
        FriendTableManager.instance.clear()
        
        PushManager.instance.unRegister()
        GoalCache.instance.ifNeedClearMap = true
    }
    
    func logout(viewController: UIViewController) -> Bool {
        clearData()
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let loginController = storyboard.instantiateViewControllerWithIdentifier("Login") as! LoginController
        
        viewController.navigationController?.pushViewController(loginController, animated: true)
        
        return true
    }
    
    func checkIfGoToLogin(viewController: UIViewController) {
        let alertController = UIAlertController(title: nil,
                                                message: NSLocalizedString("NOT_LOGIN", comment: "You haven't logged in. Go to login?"), preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"),
                                         style: UIAlertActionStyle.Cancel, handler: nil)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.Default, handler: { (action) in
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let loginController = storyboard.instantiateViewControllerWithIdentifier("Login") as! WarningController
            
            viewController.navigationController?.pushViewController(loginController, animated: true)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
}
