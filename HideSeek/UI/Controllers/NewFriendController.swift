///
//  NewFriendController.swift
//  HideSeek
//
//  Created by apple on 8/26/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import MBProgressHUD
import AFNetworking

class NewFriendController: UIViewController, AcceptDelegate {
    let HtmlType = "text/html"
    @IBOutlet weak var newFriendTableView: NewFriendTableView!
    var manager: CustomRequestManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        self.automaticallyAdjustsScrollViewInsets = false
        newFriendTableView.acceptDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        BadgeUtil.clearMeBadge()
        
        newFriendTableView.newFriendList = NewFriendCache.instance.friendList
        newFriendTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setFriendRequest(_ userInfo: NSDictionary, isFriend: Bool) {
        let friendInfo = userInfo["object"] as! NSDictionary
        var message: NSString = ""
        
        if isFriend {
            let friendNum = BaseInfoUtil.getIntegerFromAnyObject(userInfo["extra"])
            if UserCache.instance.ifLogin() {
                UserCache.instance.user.friendNum = friendNum
            }
        } else {
            message = userInfo["extra"] as! NSString
        }
        
        NewFriendCache.instance.setFriend(friendInfo, message: message, isFriend: isFriend)
    }
    
    func acceptFriend(_ friendId: Int64) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let paramDict: NSMutableDictionary = ["friend_id": "\(friendId)"]
        _ = manager.POST(UrlParam.ACCEPT_FRIEND_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        let response = responseObject as! NSDictionary
                        print("JSON: " + responseObject.debugDescription)
                        self.setInfoFromCallback(response, friendId: friendId)
                        hud.removeFromSuperview()
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
                let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
                hud.removeFromSuperview()
        })
    }
    
    func setInfoFromCallback(_ response: NSDictionary, friendId: Int64) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            UserCache.instance.user.friendNum = BaseInfoUtil.getIntegerFromAnyObject(response["result"])
            NewFriendCache.instance.updateFriendStatus(friendId)
            newFriendTableView.newFriendList = NewFriendCache.instance.friendList
            newFriendTableView.reloadData()
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
