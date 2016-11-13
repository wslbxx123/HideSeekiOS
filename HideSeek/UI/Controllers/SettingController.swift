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
    
    @IBAction func settingBackBtnClicked(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logOutView.addTarget(self, action: #selector(SettingController.logOutClicked), for: UIControlEvents.touchDown)
        self.automaticallyAdjustsScrollViewInsets = false
        settingScrollView.delaysContentTouches = false
        let rateGesture = UITapGestureRecognizer(target: self, action: #selector(SettingController.rateHideSeek))
        rateHideSeekView.isUserInteractionEnabled = true
        rateHideSeekView.addGestureRecognizer(rateGesture)
        let clearCacheGesture = UITapGestureRecognizer(target: self, action: #selector(SettingController.clearCache))
        clearCacheView.isUserInteractionEnabled = true
        clearCacheView.addGestureRecognizer(clearCacheGesture)
        cacheSizeLabel.text = BaseInfoUtil.cachefileSize()
        let goToManualGesture = UITapGestureRecognizer(target: self, action: #selector(SettingController.goToManual))
        manualView.isUserInteractionEnabled = true
        manualView.addGestureRecognizer(goToManualGesture)
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func goToManual() {
        UIApplication.shared.openURL(URL(string: UrlParam.MANUAL_URL)!)
    }
    
    func rateHideSeek() {
        let systemVersion: NSString = UIDevice.current.systemVersion as NSString
        
        if systemVersion.floatValue != 7.0 {
            UIApplication.shared.openURL(URL(string: UrlParam.APP_STORE_REVIEW_URL)!)
        } else {
            UIApplication.shared.openURL(URL(string: UrlParam.IOS7_APP_STORE_REVIEW_URL)!)
        }
    }
    
    func clearCache() {
        _ = BaseInfoUtil.clearCache()
        cacheSizeLabel.text = BaseInfoUtil.cachefileSize()
    }
    
    func setInfoFromCallback(_ response: NSDictionary) {
        UserInfoManager.instance.clearData()
        GoalCache.instance.ifNeedClearMap = true
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func logOutClicked() {
        let paramDict = NSMutableDictionary()

        _ = manager.POST(UrlParam.LOGOUT_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.debugDescription)
                        let response = responseObject as! NSDictionary
                        
                        self.setInfoFromCallback(response)
                        
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
                let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
        })
    }
}
