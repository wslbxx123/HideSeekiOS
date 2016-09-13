//
//  ProfileController.swift
//  HideSeek
//
//  Created by apple on 8/24/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sexImageView: UIImageView!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var raceLabel: UILabel!
    @IBOutlet weak var roleImageView: UIImageView!
    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var addFriendBtn: UIButton!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var rightArrowImageView: UIImageView!
    
    var user: User!
    
    @IBAction func goToRemark(sender: AnyObject) {
        if user.isFriend {
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let remarkController = storyboard.instantiateViewControllerWithIdentifier("Remark") as! RemarkController
            remarkController.aliasValue = user.alias as String
            self.navigationController?.pushViewController(remarkController, animated: true)
        }
    }
    
    @IBAction func addFriendBtn(sender: AnyObject) {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let friendVerificationController = storyboard.instantiateViewControllerWithIdentifier("friendVerification") as! FriendVerificationController
        friendVerificationController.user = user
        self.presentViewController(friendVerificationController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initView() {
        self.automaticallyAdjustsScrollViewInsets = false
        
        addFriendBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        addFriendBtn.layer.cornerRadius = 5
        addFriendBtn.layer.masksToBounds = true
        if user.isFriend {
            addFriendBtn.enabled = false
        }
        profileScrollView.delaysContentTouches = false
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        photoImageView.layer.masksToBounds = true
        photoImageView.setWebImage(user.smallPhotoUrl as String, defaultImage: "default_photo", isCache: true)
        nameLabel.text = user.nickname as String
        
        if user.sexImageName.isEmpty {
            sexImageView.hidden = true
        } else {
            sexImageView.image = UIImage(named: user.sexImageName)
            sexImageView.hidden = false
        }
        regionLabel.text = user.region == nil ? "" : user.region! as String
        raceLabel.text = user.roleName
        roleImageView.image = UIImage(named: user.roleImageName)
        
        if user.isFriend {
            remarkLabel.hidden = false
            rightArrowImageView.hidden = false
            
            if user.alias != "" {
                nameLabel.text = user.alias as String
            }
        } else {
            remarkLabel.hidden = true
            rightArrowImageView.hidden = true
        }
    }
}
