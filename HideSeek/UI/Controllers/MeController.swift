//
//  MeControllerViewController.swift
//  HideSeek
//
//  Created by apple on 6/23/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class MeController: UIViewController, TouchDownDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var notLoginLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var registerDateLabel: UILabel!
    @IBOutlet weak var profileInfoStackView: UIStackView!
    @IBOutlet weak var roleImageView: UIImageView!
    @IBOutlet weak var friendNumLabel: UILabel!
    @IBOutlet weak var scoreNumLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scoreView: MenuView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var myProfileController: MyProfileController!
    var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    @IBAction func unwindToSegue (segue : UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setProfileInfo()
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        
        super.viewWillDisappear(animated)
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
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func showPhoto() {
        
    }
    
    func goToRecord() {
        let window = UIApplication.sharedApplication().keyWindow
        (window?.rootViewController as! UITabBarController).selectedIndex = 1
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
            profileInfoStackView.hidden = false
            
            scoreNumLabel.text = "\(user.record)"
        } else {
            profileInfoStackView.hidden = true
            notLoginLabel.hidden = false
            photoUrl = ""
            scoreNumLabel.text = "0"
        }
        
        photoImageView.setWebImage(photoUrl, defaultImage: "default_photo", isCache: true)
    }
    
    func touchDown(tag: Int) {
        goToRecord()
    }
}
