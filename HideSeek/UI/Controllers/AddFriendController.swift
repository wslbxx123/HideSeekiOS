//
//  AddContactController.swift
//  HideSeek
//
//  Created by apple on 8/23/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

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
        manager.POST(UrlParam.SEARCH_FRIENDS_URL,
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
        let result = response["result"] as! NSArray
        
        if code == CodeParam.SUCCESS {
            let userList = getUsers(result)
            
            if(userList.count > 1) {
                addFriendTableView.addFriendList = userList
                addFriendTableView.reloadData()
            } else if(userList.count == 1) {
                goToProfile(userList[0] as! User)
            }
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
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
                            sex: User.SexEnum(rawValue: (userInfo["sex"] as! NSString).integerValue)!,
                            region: userInfo["region"] as? NSString,
                            role: User.RoleEnum(rawValue: (userInfo["role"] as! NSString).integerValue)!,
                            version: (userInfo["version"] as! NSString).longLongValue,
                            pinyin: PinYinUtil.converterToPinyin(userInfo["nickname"] as! String))
            user.isFriend = (userInfo["is_friend"] as! NSString).integerValue == 1
            list.addObject(user)
        }
        
        return list
    }
    
    func goToProfile(user: User) {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let profileController = storyboard.instantiateViewControllerWithIdentifier("profile") as! ProfileController
        profileController.user = user
        self.navigationController?.pushViewController(profileController, animated: true)
    }
}