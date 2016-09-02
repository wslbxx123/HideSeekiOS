//
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
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        self.automaticallyAdjustsScrollViewInsets = false
        newFriendTableView.acceptDelegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let tarBarController = BaseInfoUtil.getRootViewController() as! ViewController
        let item = tarBarController.uiTabBar.items![3]
        item.badgeValue = nil
        newFriendTableView.newFriendList = NewFriendCache.instance.friendList
        newFriendTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setFriendRequest(userInfo: NSDictionary) {
        let friendInfo = userInfo["object"] as! NSDictionary
        let message = userInfo["extra"] as! NSString
        NewFriendCache.instance.saveFriend(friendInfo, message: message)
    }
    
    func acceptFriend(friendId: Int64) {
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.dimBackground = true
        
        let paramDict: NSMutableDictionary = ["friend_id": "\(friendId)"]
        manager.POST(UrlParam.ACCEPT_FRIEND_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        let response = responseObject as! NSDictionary
                        print("JSON: " + responseObject.description!)
                        self.setInfoFromCallback(response, friendId: friendId)
                        hud.removeFromSuperview()
                        hud = nil
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
                let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
                hud.removeFromSuperview()
                hud = nil
        })
    }
    
    func setInfoFromCallback(response: NSDictionary, friendId: Int64) {
        let code = (response["code"] as! NSString).integerValue
        
        if code == CodeParam.SUCCESS {
            NewFriendCache.instance.updateFriendStatus(friendId)
            newFriendTableView.reloadData()
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
        }
    }
}
