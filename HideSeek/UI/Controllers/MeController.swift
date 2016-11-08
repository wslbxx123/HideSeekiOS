//
//  MeControllerViewController.swift
//  HideSeek
//
//  Created by apple on 6/23/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import OAStackView

class MeController: UIViewController, TouchDownDelegate {
    let HtmlType = "text/html"
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var notLoginLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var registerDateLabel: UILabel!
    @IBOutlet weak var profileView: OAStackView!
    @IBOutlet weak var roleImageView: UIImageView!
    @IBOutlet weak var friendNumLabel: UILabel!
    @IBOutlet weak var scoreNumLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scoreView: MenuView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet var goToFriendGesture: UITapGestureRecognizer!
    @IBOutlet weak var friendView: MenuView!
    @IBOutlet weak var pushNumView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var meView: UIView!
    @IBOutlet weak var friendScoreView: UIView!
    @IBOutlet weak var myOrderView: MenuView!
    @IBOutlet weak var settingView: MenuView!
    @IBOutlet weak var rewardExchangeView: MenuView!
    @IBOutlet weak var profileLabel: UILabel!
    
    var myProfileController: MyProfileController!
    var getFriendRequestManager: CustomRequestManager!
    var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    @IBAction func goToFriends(sender: AnyObject) {
        let tarBarController = BaseInfoUtil.getRootViewController() as! ViewController
        let item = tarBarController.uiTabBar.items![3]
        
        if item.badgeValue == nil || item.badgeValue == "0"{
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let friendController = storyboard.instantiateViewControllerWithIdentifier("Friend") as! FriendController
            self.navigationController?.pushViewController(friendController, animated: true)
        } else {
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let newFriendController = storyboard.instantiateViewControllerWithIdentifier("NewFriend") as! NewFriendController
            self.navigationController?.pushViewController(newFriendController, animated: true)
        }
    }
    
    @IBAction func goToLogin(sender: AnyObject) {
        if(UserCache.instance.ifLogin()) {
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            myProfileController = storyboard.instantiateViewControllerWithIdentifier("myProfile") as! MyProfileController
            self.navigationController?.pushViewController(myProfileController, animated: true)
        } else {
            self.navigationController?.navigationBarHidden = true
            performSegueWithIdentifier("GoToLogin", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        getFriendRequestManager = CustomRequestManager()
        getFriendRequestManager.responseSerializer.acceptableContentTypes = NSSet().setByAddingObject(HtmlType)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setProfileInfo()
        setFriendRequests()
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 700)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initView() {
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        photoImageView.layer.masksToBounds = true
        scrollView.delaysContentTouches = false
        scoreView.touchDownDelegate = self
        let gotoRecordGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MeController.touchDown))
        gotoRecordGestureRecognizer.numberOfTapsRequired = 1
        scoreNumLabel.userInteractionEnabled = true
        scoreNumLabel.addGestureRecognizer(gotoRecordGestureRecognizer)
        scoreLabel.userInteractionEnabled = true
        scoreLabel.addGestureRecognizer(gotoRecordGestureRecognizer)
        
        let gotoPhotoGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MeController.showPhoto))
        gotoPhotoGestureRecognizer.numberOfTapsRequired = 1
        photoImageView.userInteractionEnabled = true
        photoImageView.addGestureRecognizer(gotoPhotoGestureRecognizer)
        
        pushNumView.layer.cornerRadius = pushNumView.frame.height / 2
        pushNumView.layer.masksToBounds = true
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func showPhoto() {
        if(UserCache.instance.ifLogin()) {
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let photoController = storyboard.instantiateViewControllerWithIdentifier("photo") as! PhotoController
            let user = UserCache.instance.user
            photoController.photoUrl = user.photoUrl as String
            photoController.smallPhotoUrl = user.smallPhotoUrl as String
            self.navigationController?.pushViewController(photoController, animated: true)
        }
    }
    
    func goToRecord() {
        let window = UIApplication.sharedApplication().keyWindow
        (window?.rootViewController as! UITabBarController).selectedIndex = 1
    }
    
    func setFriendRequests() {
        if !UserCache.instance.ifLogin() {
            return
        }
        
        let paramDict = NSMutableDictionary()
        getFriendRequestManager.POST(UrlParam.GET_FRIEND_REQUESTS_URL, paramDict: paramDict, success: { (operation, responseObject) in
            let response = responseObject as! NSDictionary
            print("JSON: " + responseObject.description!)
            
            self.setInfoFromCallback(response)
            
            }) { (operation, error) in
                print("Error: " + error.localizedDescription)
        }
    }
    
    func setInfoFromCallback(response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let friendRequests = response["result"] as! NSArray
            
            NewFriendCache.instance.setFriends(friendRequests)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
    
    func setProfileInfo() {
        var photoUrl: String?
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if(UserCache.instance.ifLogin()) {
            let user = UserCache.instance.user
            photoUrl = user.smallPhotoUrl as String
            nameLabel.text = user.nickname as String
            registerDateLabel.text = dateFormatter.stringFromDate(user.registerDate)
                + " " + NSLocalizedString("JOIN", comment: "join")
            roleImageView.image = UIImage(named: user.roleImageName)
            notLoginLabel.hidden = true
            profileView.hidden = false
            profileLabel.hidden = false
            
            scoreNumLabel.text = "\(user.record)"
            friendNumLabel.text = "\(user.friendNum)"
            friendView.addGestureRecognizer(goToFriendGesture)
        } else {
            profileView.hidden = true
            notLoginLabel.hidden = false
            profileLabel.hidden = true
            photoUrl = ""
            scoreNumLabel.text = "0"
            friendNumLabel.text = "0"
            friendView.removeGestureRecognizer(goToFriendGesture)
        }
        
        photoImageView.setWebImage(photoUrl, defaultImage: "default_photo", isCache: true)
        
        setBadgeValue()
    }
    
    func touchDown(tag: Int) {
        goToRecord()
    }
    
    func setBadgeValue() {
        let tarBarController = BaseInfoUtil.getRootViewController() as! ViewController
        let item = tarBarController.uiTabBar.items![3]
        
        if pushNumView == nil {
            return;
        }
        
        if item.badgeValue == nil || item.badgeValue == "0"{
            pushNumView.hidden = true
        } else {
            pushNumView.hidden = false
        }
    }
    
    func clearBadgeValue() {
        if pushNumView != nil {
            pushNumView.hidden = true
        }
    }
}
