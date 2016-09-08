//
//  FriendController.swift
//  HideSeek
//
//  Created by apple on 8/23/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class FriendController: UIViewController, UISearchBarDelegate, GoToNewFriendDelegate, GoToProfileDelegate {
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
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        friendTableManager = FriendTableManager.instance
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "add_friends"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FriendController.addFriendBtnClicked))
        self.navigationItem.rightBarButtonItem = rightBarButton
        searchBar.delegate = self
        friendTableView.goToNewFriendDelegate = self
        friendTableView.goToProfileDelegate = self
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
    
    func setInfoFromCallback(response: NSDictionary) {
        let code = (response["code"] as! NSString).integerValue
        
        if code == CodeParam.SUCCESS {
            FriendCache.instance.setFriends(response["result"] as! NSDictionary)
            self.friendTableView.alphaIndex = self.getAlphaIndexFromList(FriendCache.instance.friendList)
            self.friendTableView.friendList = FriendCache.instance.friendList
            self.friendTableView.reloadData()
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
        }
    }
    
    func addFriendBtnClicked() {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        addFriendController = storyboard.instantiateViewControllerWithIdentifier("addFriend") as! AddFriendController
        self.navigationController?.pushViewController(addFriendController, animated: true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
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

    func getAlphaIndexFromList(friendList: NSMutableArray) -> NSMutableDictionary{
        let alphaIndex = NSMutableDictionary()
        var previewStr = ""
        
        if friendList.count == 0 {
            return alphaIndex
        }
        
        for i in 0...friendList.count - 1 {
            let friend = friendList[i] as! User
            var currentStr = friend.pinyin.substringToIndex(1).uppercaseString
            
            for char in currentStr.utf8  {
                if (char <= 64 || char >= 91) {
                    currentStr = "#"
                    break;
                }
            }
            
            if i >= 1 {
                let lastFriend = friendList[i - 1] as! User
                previewStr = (lastFriend.pinyin as NSString).substringToIndex(1).uppercaseString
                
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
        let newFriendController = storyboard.instantiateViewControllerWithIdentifier("NewFriend") as! NewFriendController
        self.navigationController?.pushViewController(newFriendController, animated: true)
    }
    
    func goToProfile(user: User) {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let profileController = storyboard.instantiateViewControllerWithIdentifier("Profile") as! ProfileController
        profileController.user = user
        self.navigationController?.pushViewController(profileController, animated: true)
    }
}
