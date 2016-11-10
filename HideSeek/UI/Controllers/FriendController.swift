//
//  FriendController.swift
//  HideSeek
//
//  Created by apple on 8/23/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import MBProgressHUD

class FriendController: UIViewController, UISearchBarDelegate, GoToNewFriendDelegate, GoToProfileDelegate, RemoveFriendDelegate {
    let HtmlType = "text/html"
    @IBOutlet weak var friendTableView: FriendTableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var friendTableManager: FriendTableManager!
    var addFriendController: AddFriendController!
    var manager: CustomRequestManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        friendTableManager = FriendTableManager.instance
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "add_friends"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(FriendController.addFriendBtnClicked))
        self.navigationItem.rightBarButtonItem = rightBarButton
        searchBar.delegate = self
        friendTableView.goToNewFriendDelegate = self
        friendTableView.goToProfileDelegate = self
        friendTableView.removeFriendDelegate = self
    }
    
    func refreshData() {
        let paramDict: NSMutableDictionary = ["version": String(friendTableManager.version)]
        manager.POST(UrlParam.GET_FRIENDS_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.description!)
                        let response = responseObject as! NSDictionary
                        
                        self.setInfoFromCallback(response)
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
        })
    }
    
    func setInfoFromCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            FriendCache.instance.setFriends(response["result"] as! NSDictionary)
            self.friendTableView.alphaIndex = self.getAlphaIndexFromList(FriendCache.instance.friendList)
            self.friendTableView.friendList = FriendCache.instance.friendList
            self.friendTableView.reloadData()
            
            if UserCache.instance.ifLogin() && UserCache.instance.user.friendNum != FriendCache.instance.friendList.count {
                UserCache.instance.user.friendNum = FriendCache.instance.friendList.count
            }
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
    
    func addFriendBtnClicked() {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        addFriendController = storyboard.instantiateViewController(withIdentifier: "addFriend") as! AddFriendController
        self.navigationController?.pushViewController(addFriendController, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (!searchText.isEmpty) {
            friendTableView.friendList = friendTableManager.searchFriends(searchText)
            friendTableView.isSearching = true
            friendTableView.reloadData()
        } else {
            let friendList = FriendCache.instance.friendList
            if friendList.count > 0 {
                self.friendTableView.alphaIndex = self.getAlphaIndexFromList(FriendCache.instance.friendList)
            }
            self.friendTableView.friendList = friendList
            friendTableView.isSearching = false
            friendTableView.reloadData()
        }
    }

    func getAlphaIndexFromList(_ friendList: NSMutableArray) -> NSMutableDictionary{
        let alphaIndex = NSMutableDictionary()
        var previewStr = ""
        
        if friendList.count == 0 {
            return alphaIndex
        }
        
        for i in 0...friendList.count - 1 {
            let friend = friendList[i] as! User
            var currentStr = friend.pinyin.substring(to: 1).uppercased()
            
            for char in currentStr.utf8  {
                if (char <= 64 || char >= 91) {
                    currentStr = "#"
                    break;
                }
            }
            
            if i >= 1 {
                let lastFriend = friendList[i - 1] as! User
                previewStr = (lastFriend.pinyin as NSString).substring(to: 1).uppercased()
                
                for char in previewStr.utf8  {
                    if (char <= 64 || char >= 91) {
                        previewStr = "#"
                        break;
                    }
                }
            }
            
            if previewStr != currentStr {
                alphaIndex[currentStr] = i
            }
        }
        
        return alphaIndex
    }
    
    func goToNewFriend() {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let newFriendController = storyboard.instantiateViewController(withIdentifier: "NewFriend") as! NewFriendController
        self.navigationController?.pushViewController(newFriendController, animated: true)
    }
    
    func goToProfile(_ user: User) {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let profileController = storyboard.instantiateViewController(withIdentifier: "Profile") as! ProfileController
        profileController.user = user
        self.navigationController?.pushViewController(profileController, animated: true)
    }
    
    func checkRemoveFriend(_ friend: User) {
        let alertController = UIAlertController(title: nil,
                                                message: NSLocalizedString("CONFIRM_REMOVE_FRIEND", comment: "Are you sure to remove this friend?"), preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"),
                                         style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.default, handler: { (action) in
            self.removeFriend(friend)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func removeFriend(_ friend: User) {
        let paramDict: NSMutableDictionary = ["friend_id": "\(friend.pkId)"]
        
        var hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
        hud.dimBackground = true
        
        manager.POST(UrlParam.REMOVE_FRIEND_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.description!)
                        let response = responseObject as! NSDictionary
                        self.setInfoFromRemoveFriendCallback(response, friend: friend)
                        
                        hud.removeFromSuperview()
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
                let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
                hud.removeFromSuperview()
        })
    }
    
    func setInfoFromRemoveFriendCallback(_ response: NSDictionary, friend: User) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let friendNum = BaseInfoUtil.getIntegerFromAnyObject(response["result"])
            UserCache.instance.user.friendNum = friendNum
            FriendCache.instance.removeFriend(friend)
            self.friendTableView.alphaIndex = self.getAlphaIndexFromList(FriendCache.instance.friendList)
            self.friendTableView.friendList = FriendCache.instance.friendList
            self.friendTableView.reloadData()
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
