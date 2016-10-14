//
//  SettingController.swift
//  HideSeek
//
//  Created by apple on 7/23/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class SettingController: UIViewController {
    let HtmlType = "text/html"
    @IBOutlet weak var logOutView: MenuView!
    @IBOutlet weak var settingScrollView: UIScrollView!
    @IBOutlet weak var rateHideSeekView: MenuView!
    @IBOutlet weak var clearCacheView: MenuView!
    @IBOutlet weak var manualView: MenuView!
    @IBOutlet weak var cacheSizeLabel: UILabel!
    var manager: CustomRequestManager!
    
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
        let goToManualGesture = UITapGestureRecognizer(target: self, action: #selector(SettingController.goToManual))
        manualView.userInteractionEnabled = true
        manualView.addGestureRecognizer(goToManualGesture)
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func goToManual() {
        UIApplication.sharedApplication().openURL(NSURL(string: UrlParam.MANUAL_URL)!)
    }
    
    func rateHideSeek() {
        let systemVersion: NSString = UIDevice.currentDevice().systemVersion
        
        if systemVersion.floatValue != 7.0 {
            UIApplication.sharedApplication().openURL(NSURL(string: UrlParam.APP_STORE_REVIEW_URL)!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: UrlParam.IOS7_APP_STORE_REVIEW_URL)!)
        }
    }
    
    func clearCache() {
        BaseInfoUtil.clearCache()
        cacheSizeLabel.text = BaseInfoUtil.cachefileSize()
    }
    
    func setInfoFromCallback(response: NSDictionary) {
        UserInfoManager.instance.clearData()
        GoalCache.instance.ifNeedClearMap = true
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func logOutClicked() {
        let paramDict = NSMutableDictionary()

        manager.POST(UrlParam.LOGOUT_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.description!)
                        let response = responseObject as! NSDictionary
                        
                        self.setInfoFromCallback(response)
                        
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
                let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
        })
    }
}
