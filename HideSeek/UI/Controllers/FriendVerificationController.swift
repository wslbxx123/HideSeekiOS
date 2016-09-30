//
//  FriendVerificationController.swift
//  HideSeek
//
//  Created by apple on 8/27/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import MBProgressHUD
import AFNetworking

class FriendVerificationController: UIViewController {
    let HtmlType = "text/html"
    @IBOutlet weak var requestTextField: UITextField!
    @IBOutlet weak var navigation: UINavigationItem!
    var manager: CustomRequestManager!
    var user: User!
    var count: Int = 0

    @IBAction func clearBtnClicked(sender: AnyObject) {
        requestTextField.text = ""
    }
    
    @IBAction func requestChanged(sender: AnyObject) {
        if requestTextField == nil || (requestTextField.text?.isEmpty)! {
            navigation.rightBarButtonItem?.enabled = false
        } else {
            navigation.rightBarButtonItem?.enabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let leftBarButton = UIBarButtonItem(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FriendVerificationController.cancelBtnClicked))
        let rightBarButton = UIBarButtonItem(title: NSLocalizedString("SEND", comment: "Send"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FriendVerificationController.sendBtnClicked))
        
        navigation.leftBarButtonItem = leftBarButton
        navigation.rightBarButtonItem = rightBarButton
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        requestTextField.text = NSString(format: NSLocalizedString("SELF_INTRODUCTION", comment: "I am %@"), UserCache.instance.user.nickname) as String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cancelBtnClicked() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendBtnClicked() {
        count = 0
        sendFriendRequest()
    }
    
    func sendFriendRequest() {
        count += 1
        let message = requestTextField.text == nil ? "" : requestTextField.text!
        let paramDict: NSMutableDictionary = ["friend_id": "\(user.pkId)", "message": message]
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.dimBackground = true
        
        manager.POST(UrlParam.ADD_FRIENDS_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.description!)
                        let response = responseObject as! NSDictionary
                        self.setInfoFromCallback(response)
                        hud.removeFromSuperview()
                        hud = nil
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
                hud.removeFromSuperview()
                hud = nil
        })
    }
    
    func setInfoFromCallback(response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            if code == 10023 && count <= 5 {
                sendFriendRequest()
            } else {
                let errorMessage = ErrorMessageFactory.get(code)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                    if code == CodeParam.ERROR_SESSION_INVALID {
                        UserInfoManager.instance.logout(self)
                    }
                })
            }
        }
    }
}
