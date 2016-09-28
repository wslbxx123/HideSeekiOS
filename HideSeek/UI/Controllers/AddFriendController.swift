//
//  AddContactController.swift
//  HideSeek
//
//  Created by apple on 8/23/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import MBProgressHUD

class AddFriendController: UIViewController, UISearchBarDelegate, GoToProfileDelegate {
    let HtmlType = "text/html"
    @IBOutlet weak var addFriendTableView: AddFriendTableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var manager: CustomRequestManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        searchBar.delegate = self
        addFriendTableView.goToProfileDelegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if searchBar.text != nil && !searchBar.text!.isEmpty {
            refreshData()
        }
    }
    
    func refreshData() {
        let paramDict: NSMutableDictionary = ["search_word": searchBar.text!]
        
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.dimBackground = true
        
        manager.POST(UrlParam.SEARCH_FRIENDS_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.description!)
                        let response = responseObject as! NSDictionary
                        self.setInfoFromCallback(response)
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
    
    func setInfoFromCallback(response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let result = response["result"] as! NSArray
            let userList = getUsers(result)
            
            if(userList.count > 1) {
                addFriendTableView.addFriendList = userList
                addFriendTableView.reloadData()
            } else if(userList.count == 1) {
                goToProfile(userList[0] as! User)
            }
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
    
    func getUsers(result: NSArray) -> NSMutableArray {
        let list = NSMutableArray()
        
        for userItem in result {
            let userInfo = userItem as! NSDictionary
            let user = User(pkId: (userInfo["pk_id"] as! NSString).longLongValue,
                            phone: userInfo["phone"] as! String,
                            nickname: userInfo["nickname"] as! String,
                            registerDateStr: userInfo["register_date"] as! String,
                            photoUrl: userInfo["photo_url"] as? NSString,
                            smallPhotoUrl: userInfo["small_photo_url"] as? NSString,
                            sex: User.SexEnum(rawValue: BaseInfoUtil.getIntegerFromAnyObject(userInfo["sex"]))!,
                            region: userInfo["region"] as? NSString,
                            role: User.RoleEnum(rawValue: BaseInfoUtil.getIntegerFromAnyObject(userInfo["role"]))!,
                            version: (userInfo["version"] as! NSString).longLongValue,
                            pinyin: PinYinUtil.converterToPinyin(userInfo["nickname"] as! String))
            user.isFriend = BaseInfoUtil.getIntegerFromAnyObject(userInfo["is_friend"]) == 1
            list.addObject(user)
        }
        
        return list
    }
    
    func goToProfile(user: User) {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let profileController = storyboard.instantiateViewControllerWithIdentifier("Profile") as! ProfileController
        profileController.user = user
        self.navigationController?.pushViewController(profileController, animated: true)
    }
}
