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
    var httpManager: AFHTTPRequestOperationManager!
    var postChanneldId = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiTabBar.tintColor = UIColor.blackColor()
        
        for item in uiTabBar.items! {
            item.image = item.image?.imageWithRenderingMode(.AlwaysOriginal)
            item.selectedImage = item.selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        }
        httpManager = AFHTTPRequestOperationManager()
        httpManager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateChannelId(channelId: String) {
        let tempChannelId = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.CHANNEL_ID) as? NSString
        
        if (tempChannelId == nil || tempChannelId! != channelId) {
            NSUserDefaults.standardUserDefaults().setObject(channelId, forKey: UserDefaultParam.CHANNEL_ID)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            if(UserCache.instance.ifLogin()) {
                postChanneldId = 0
                postChannelId(channelId)
            }
        }
    }
    
    func postChannelId(channelId: String) {
        postChanneldId += 1
        
        if postChanneldId > 5 {
            return;
        }
        
        let paramDict: NSMutableDictionary = ["channel_id": channelId]
        manager.POST(UrlParam.UPDATE_CHANNEL_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.description!)
            },
                     failure: { (operation, error) in
                        print("Error: " + error.localizedDescription)
                        self.postChannelId(channelId);
        })
    }
    
    func updateSetting() {
        httpManager.POST(UrlParam.GET_SETTINGS, parameters: [],
                         success: { (operation, responseObject) in
                            let response = responseObject as! NSDictionary
                            print("JSON: " + responseObject.description!)
            
                            self.setInfoFromCallback(response)
                },
                         failure: { (operation, error) in
                            print("Error: " + error.localizedDescription)
            })
    }
    
    func setInfoFromCallback(response: NSDictionary) {
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
                                                message: NSLocalizedString("MESSAGE_UPDATE_APP", comment: "There is a new version of this app. Go to app store to update it?"), preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("NEXT_TIME", comment: "Next Time"),
                                         style: UIAlertActionStyle.Cancel, handler: nil)
        let okAction = UIAlertAction(title: NSLocalizedString("UPDATE", comment: "Update"), style: UIAlertActionStyle.Default, handler: { (action) in
            UIApplication.sharedApplication().openURL(NSURL(string: UrlParam.APP_STORE_URL)!)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
