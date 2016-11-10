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
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.SESSION_TOKEN)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.USER_INFO)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.RECORD_VERSION)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.RECORD_MIN_ID)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.RACE_GROUP_VERSION)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.RACE_GROUP_RECORD_MIN_ID)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.PRODUCT_VERSION)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.PRODUCT_MIN_ID)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.REWARD_VERSION)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.REWARD_MIN_ID)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.PURCHASE_ORDER_VERSION)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.PURCHASE_ORDER_MIN_ID)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.EXCHANGE_ORDER_VERSION)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.EXCHANGE_ORDER_MIN_ID)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.FRIEND_VERSION)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.SCORE_SUM)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.CHANNEL_ID)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.RECORD_UPDATE_TIME)
        UserDefaults.standard.removeObject(forKey: UserDefaultParam.RACE_GROUP_UPDATE_TIME)
        
        UserDefaults.standard.synchronize()
        
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
        ExchangeOrderTableManager.instance.clear()
        FriendTableManager.instance.clear()
        
        PushManager.instance.unRegister()
        GoalCache.instance.ifNeedClearMap = true
        BadgeUtil.clearMeBadge()
    }
    
    func logout(_ viewController: UIViewController) {
        clearData()
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let loginController = storyboard.instantiateViewController(withIdentifier: "Login") as! LoginController
        
        viewController.navigationController?.pushViewController(loginController, animated: true)
    }
    
    func checkIfGoToLogin(_ viewController: UIViewController) {
        let alertController = UIAlertController(title: nil,
                                                message: NSLocalizedString("NOT_LOGIN", comment: "You haven't logged in. Go to login?"), preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"),
                                         style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.default, handler: { (action) in
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let loginController = storyboard.instantiateViewController(withIdentifier: "Login") as! LoginController
            
            viewController.navigationController?.pushViewController(loginController, animated: true)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
