//
//  ViewController.swift
//  HideSeek
//
//  Created by apple on 6/14/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import AFNetworking

class ViewController: UITabBarController {
    let HtmlType = "text/html"
    @IBOutlet weak var uiTabBar: UITabBar!
    var manager: CustomRequestManager!
    var httpManager: AFHTTPSessionManager!
    var postChanneldId = 0
    var updateSettingCount = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiTabBar.tintColor = UIColor.black
        
        for item in uiTabBar.items! {
            item.image = item.image?.withRenderingMode(.alwaysOriginal)
            item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
        }
        httpManager = AFHTTPSessionManager()
        httpManager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateChannelId(_ channelId: String) {
        let tempChannelId = UserDefaults.standard.object(forKey: UserDefaultParam.CHANNEL_ID) as? NSString
        
        if (tempChannelId == nil || tempChannelId! as String != channelId) {
            UserDefaults.standard.set(channelId, forKey: UserDefaultParam.CHANNEL_ID)
            UserDefaults.standard.synchronize()
            
            if(UserCache.instance.ifLogin()) {
                postChanneldId = 0
                postChannelId(channelId)
            }
        }
    }
    
    func postChannelId(_ channelId: String) {
        postChanneldId += 1
        
        if postChanneldId > 5 {
            return;
        }
        
        let paramDict: NSMutableDictionary = ["channel_id": channelId]
        _ = manager.POST(UrlParam.UPDATE_CHANNEL_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.description!)
            },
                     failure: { (operation, error) in
                        print("Error: " + error.localizedDescription)
                        self.postChannelId(channelId);
        })
    }
    
    func refreshSetting() {
        updateSettingCount = 0
        updateSetting()
    }
    
    func updateSetting() {
        updateSettingCount += 1
        
        if updateSettingCount > 5 {
            return;
        }
        
        _ = httpManager.post(UrlParam.GET_SETTINGS, parameters: [],
                         success: { (operation, responseObject) in
                            let response = responseObject as! NSDictionary
                            print("JSON: " + (responseObject as AnyObject).description!)
            
                            self.setInfoFromCallback(response)
                },
                         failure: { (operation, error) in
                            print("Error: " + error.localizedDescription)
                            self.updateSetting()
            })
    }
    
    func setInfoFromCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let result = response["result"] as! NSDictionary
            
            Setting.IF_STORE_HIDDEN = BaseInfoUtil.getIntegerFromAnyObject(result["if_store_hidden"]) == 1
            Setting.LATEST_APP_VERSION = (result["latest_app_version"] as! String)
            
            if BaseInfoUtil.getAppVersion().compareTo(Setting.LATEST_APP_VERSION, separator: ".") < 0{
                self.showUpdateDialog()
            }
            
            let log = Setting.IF_STORE_HIDDEN ? "true" : "false"
            NSLog(log)
        }
    }
    
    func showUpdateDialog() {
        let alertController = UIAlertController(title: nil,
                                                message: NSLocalizedString("MESSAGE_UPDATE_APP", comment: "There is a new version of this app. Go to app store to update it?"), preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("NEXT_TIME", comment: "Next Time"),
                                         style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: NSLocalizedString("UPDATE", comment: "Update"), style: UIAlertActionStyle.default, handler: { (action) in
            UIApplication.shared.openURL(URL(string: UrlParam.APP_STORE_URL)!)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
