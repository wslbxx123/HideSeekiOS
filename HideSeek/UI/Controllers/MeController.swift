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
    var dateFormatter: DateFormatter = DateFormatter()
    
    @IBAction func goToFriends(_ sender: AnyObject) {
        let tarBarController = BaseInfoUtil.getRootViewController() as! ViewController
        let item = tarBarController.uiTabBar.items![3]
        
        if item.badgeValue == nil || item.badgeValue == "0"{
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let friendController = storyboard.instantiateViewController(withIdentifier: "Friend") as! FriendController
            self.navigationController?.pushViewController(friendController, animated: true)
        } else {
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let newFriendController = storyboard.instantiateViewController(withIdentifier: "NewFriend") as! NewFriendController
            self.navigationController?.pushViewController(newFriendController, animated: true)
        }
    }
    
    @IBAction func goToLogin(_ sender: AnyObject) {
        if(UserCache.instance.ifLogin()) {
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            myProfileController = storyboard.instantiateViewController(withIdentifier: "myProfile") as! MyProfileController
            self.navigationController?.pushViewController(myProfileController, animated: true)
        } else {
            self.navigationController?.isNavigationBarHidden = true
            performSegue(withIdentifier: "GoToLogin", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        getFriendRequestManager = CustomRequestManager()
        getFriendRequestManager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setProfileInfo()
        setFriendRequests()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 700)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initView() {
        photoImageView.layoutIfNeeded()
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        photoImageView.layer.masksToBounds = true
        scrollView.delaysContentTouches = false
        scoreView.touchDownDelegate = self
        let gotoRecordGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MeController.touchDown))
        gotoRecordGestureRecognizer.numberOfTapsRequired = 1
        scoreNumLabel.isUserInteractionEnabled = true
        scoreNumLabel.addGestureRecognizer(gotoRecordGestureRecognizer)
        scoreLabel.isUserInteractionEnabled = true
        scoreLabel.addGestureRecognizer(gotoRecordGestureRecognizer)
        
        let gotoPhotoGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MeController.showPhoto))
        gotoPhotoGestureRecognizer.numberOfTapsRequired = 1
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(gotoPhotoGestureRecognizer)
        
        pushNumView.layoutIfNeeded()
        pushNumView.layer.cornerRadius = pushNumView.frame.height / 2
        pushNumView.layer.masksToBounds = true
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func showPhoto() {
        if(UserCache.instance.ifLogin()) {
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let photoController = storyboard.instantiateViewController(withIdentifier: "photo") as! PhotoController
            let user = UserCache.instance.user
            photoController.photoUrl = user?.photoUrl as! String
            photoController.smallPhotoUrl = user?.smallPhotoUrl as! String
            self.navigationController?.pushViewController(photoController, animated: true)
        }
    }
    
    func goToRecord() {
        let window = UIApplication.shared.keyWindow
        (window?.rootViewController as! UITabBarController).selectedIndex = 1
    }
    
    func setFriendRequests() {
        if !UserCache.instance.ifLogin() {
            return
        }
        
        let paramDict = NSMutableDictionary()
        _ = getFriendRequestManager.POST(UrlParam.GET_FRIEND_REQUESTS_URL, paramDict: paramDict, success: { (operation, responseObject) in
            let response = responseObject as! NSDictionary
            print("JSON: " + responseObject.debugDescription)
            
            self.setInfoFromCallback(response)
            
            }) { (operation, error) in
                print("Error: " + error.localizedDescription)
        }
    }
    
    func setInfoFromCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let friendRequests = response["result"] as! NSArray
            
            NewFriendCache.instance.setFriends(friendRequests)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
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
            photoUrl = user?.smallPhotoUrl as? String
            nameLabel.text = user?.nickname as? String
            registerDateLabel.text = dateFormatter.string(from: (user?.registerDate)!)
                + " " + NSLocalizedString("JOIN", comment: "join")
            roleImageView.image = UIImage(named: (user?.roleImageName)!)
            notLoginLabel.isHidden = true
            profileView.isHidden = false
            profileLabel.isHidden = false
            
            scoreNumLabel.text = "\(user!.record)"
            friendNumLabel.text = "\(user!.friendNum)"
            friendView.addGestureRecognizer(goToFriendGesture)
        } else {
            profileView.isHidden = true
            notLoginLabel.isHidden = false
            profileLabel.isHidden = true
            photoUrl = ""
            scoreNumLabel.text = "0"
            friendNumLabel.text = "0"
            friendView.removeGestureRecognizer(goToFriendGesture)
        }
        
        photoImageView.setWebImage(photoUrl, defaultImage: "default_photo", isCache: true)
        
        setBadgeValue()
    }
    
    func touchDown(_ tag: Int) {
        goToRecord()
    }
    
    func setBadgeValue() {
        let tarBarController = BaseInfoUtil.getRootViewController() as! ViewController
        let item = tarBarController.uiTabBar.items![3]
        
        if pushNumView == nil {
            return;
        }
        
        if item.badgeValue == nil || item.badgeValue == "0"{
            pushNumView.isHidden = true
        } else {
            pushNumView.isHidden = false
        }
    }
    
    func clearBadgeValue() {
        if pushNumView != nil {
            pushNumView.isHidden = true
        }
    }
}
