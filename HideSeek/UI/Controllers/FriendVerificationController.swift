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

    @IBAction func clearBtnClicked(_ sender: AnyObject) {
        requestTextField.text = ""
    }
    
    @IBAction func requestChanged(_ sender: AnyObject) {
        if requestTextField == nil || (requestTextField.text?.isEmpty)! {
            navigation.rightBarButtonItem?.isEnabled = false
        } else {
            navigation.rightBarButtonItem?.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let leftBarButton = UIBarButtonItem(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(FriendVerificationController.cancelBtnClicked))
        let rightBarButton = UIBarButtonItem(title: NSLocalizedString("SEND", comment: "Send"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(FriendVerificationController.sendBtnClicked))
        
        navigation.leftBarButtonItem = leftBarButton
        navigation.rightBarButtonItem = rightBarButton
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        requestTextField.text = NSString(format: NSLocalizedString("SELF_INTRODUCTION", comment: "I am %@") as NSString, UserCache.instance.user.nickname) as String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cancelBtnClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendBtnClicked() {
        count = 0
        sendFriendRequest()
    }
    
    func sendFriendRequest() {
        count += 1
        let message = requestTextField.text == nil ? "" : requestTextField.text!
        let paramDict: NSMutableDictionary = ["friend_id": "\(user.pkId)", "message": message]
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        _ = manager.POST(UrlParam.ADD_FRIENDS_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.debugDescription)
                        let response = responseObject as! NSDictionary
                        self.setInfoFromCallback(response)
                        hud.removeFromSuperview()
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
                hud.removeFromSuperview()
        })
    }
    
    func setInfoFromCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            self.dismiss(animated: true, completion: nil)
        } else {
            if code == CodeParam.ERROR_FAIL_SEND_MESSAGE && count <= 5 {
                sendFriendRequest()
            } else {
                let errorMessage = ErrorMessageFactory.get(code)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
                    if code == CodeParam.ERROR_SESSION_INVALID {
                        UserInfoManager.instance.logout(self)
                    }
                })
            }
        }
    }
}
